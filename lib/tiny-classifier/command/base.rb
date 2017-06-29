# Copyright (C) 2017 YUKI "Piro" Hiroshi
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

require "pathname"
require "optparse"
require "classifier-reborn"
require "tiny-classifier/tokenizer"
require "tiny-classifier/category-manager"
require "tiny-classifier/input"
require "tiny-classifier/errors"

module TinyClassifier
  module Command
    class Base
      class << self
        def run(argv=nil)
          argv ||= ARGV.dup
          command = new(argv)
          command.run
        end
      end

      attr_reader :tokenizer
      attr_writer :classifier

      def initialize(argv=[])
        @categories = nil
        @tokenizer = Tokenizer.new
        @data_dir = Dir.pwd
        @verbose = false
      end

      def parse_command_line_options(command_line_options)
        option_parser.parse!(command_line_options)
      end

      def classifier
        @classifier ||= prepare_classifier
      end

      def data_file_name
        "tc.#{@categories.basename}.dat"
      end

      def data_file_path
        @data_file_path ||= prepare_data_file_path
      end

      private
      def option_parser
        @option_parser ||= create_option_parser
      end

      def create_option_parser
        parser = OptionParser.new

        parser.on("-d PATH", "--data-dir=PATH",
                  "Path to the directory to store training data file (default=current directory)") do |data_dir|
          @data_dir = data_dir
        end

        parser.on("-c CATEGORIES", "--categories=CATEGORIES",
                  "List of categories (comma-separated)") do |categories|
          @categories = CategoryManager.new(categories)
        end

        parser.on("-t TOKENIZER", "--tokenizer=TOKENIZER",
                  "Tokenizer (default=#{@tokenizer})") do |tokenizer|
          @tokenizer.type = tokenizer
        end

        parser.on("-v", "--verbose",
                  "Output internal information (for debugging)") do |verbose|
          @verbose = verbose
        end

        parser
      end

      def prepare_data_file_path
        path = Pathname(@data_dir)
        path += data_file_name
        log("file: #{path}")
        path
      end

      def prepare_classifier
        if data_file_path.exist?
          data = File.read(data_file_path.to_s)
          Marshal.load(data)
        else
          ClassifierReborn::Bayes.new(*@categories.all)
        end
      end

      def save
        data = Marshal.dump(classifier)
        File.open(data_file_path, "w") do |file|
          file.write(data)
        end
      end

      def input
        @input ||= prepare_input
      end

      def prepare_input
        input = Input.new
        raise NoInput.new unless input.given?
        tokenized = @tokenizer.tokenize(input.read)
        log("tokenizer: #{@tokenizer.type}")
        log("tokenized: #{tokenized}")
        tokenized
      end

      def handle_error(error)
        case error
        when NoInput
          error("Error: No input. You need to give any input via the STDIN.")
        when NoEffectiveInput
          error("Error: No effective input.")
        when NoCategory
          error("Error: You need to specify a category for the input.")
        when InvalidCategory
          error("Error: You need to specify one of valid categories: #{error.categories.join(", ")}")
        end
        false
      end

      def error(message)
        $stderr.puts(message)
      end

      def log(message)
        $stderr.puts(message) if @verbose
      end
    end
  end
end
