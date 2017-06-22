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

module TinyClassifier
  class Base
    attr_reader :tokenizer

    def initialize
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
        @categories = normalize_categories(categories)
        log("categories: #{@categories}")
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

    def normalize_categories(categories)
      categories
        .strip
        .downcase
        .split(",")
        .collect(&:strip)
        .reject do |category|
          category.empty?
        end
        .sort
        .collect(&:capitalize)
    end

    def data_file_name
      @data_file_basename ||= prepare_data_file_name
    end

    def prepare_data_file_name
      categories = @categories.join("-").downcase
      "tc.#{categories}.dat"
    end

    def data_file_path
      @data_file_path ||= prepare_data_file_path
    end

    def prepare_data_file_path
      path = Pathname(@data_dir)
      path + data_file_name
    end

    def prepare_classifier
      if data_file_path.exist?
        data = File.read(data_file_path.to_s)
        Marshal.load(data)
      else
        ClassifierReborn::Bayes.new(*@categories)
      end
    end

    def input
      @input ||= prepare_input
    end

    def prepare_input
      unless File.pipe?(STDIN)
        error("Error: No effective input. You need to give any input via the STDIN.")
        exit(false)
      end
      @input = $stdin.readlines.join(" ")
      @tokenizer.tokenize(@input)
      @input.strip!
      log("input: #{@input}")
      @input
    end

    def error(message)
      STDERR.puts(message)
    end

    def log(message)
      STDERR.puts(message) if @verbose
    end
  end
end
