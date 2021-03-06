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

require "tiny-classifier/command/base"
require "fileutils"
require "base64"

module TinyClassifier
  module Command
    class GenerateClassifier < Base
      def initialize(argv=[])
        super

        @output_dir = Dir.pwd
        option_parser.on("-o PATH", "--output-dir=PATH",
                         "Path to the classifier command to be saved (default=current directory)") do |output_dir|
          @output_dir = output_dir
        end

        parse_command_line_options(argv)
      end
  
      def run
        super
        unless data_file_path.exist?
          raise NoTrainingData.new(data_file_path)
        end
        unless prepare_output_file_path.parent.exist?
          raise InvalidOutputDir.new(prepare_output_file_path.parent)
        end

        FileUtils.mkdir_p(output_file_path.parent)
        File.open(output_file_path, "w") do |file|
          file.puts("#!/usr/bin/env ruby")
          file.puts("require \"base64\"")
          file.puts("require \"classifier-reborn\"")
          file.puts("require \"tiny-classifier/command/classify\"")
          file.puts("classifier_code = Base64.strict_decode64(\"#{encoded_classifier}\")")
          file.puts("command = TinyClassifier::Command::Classify.new([")
          file.puts("  \"--categories=#{@categories.all.join(",")}\",")
          file.puts("  \"--tokenizer=#{@tokenizer.type}\",")
          file.puts("])")
          file.puts("command.classifier = Marshal.load(classifier_code)")
          file.puts("command.run")
        end
        FileUtils.chmod("a+x", output_file_path)
        true
      rescue StandardError => error
        handle_error(error)
      end

      def classifier_name
        @classifier_name ||= "tc-classify-#{@categories.basename}"
      end

      def output_file_path
        @output_file_path ||= prepare_output_file_path
      end

      private
      def encoded_classifier
        @encoded_classifier ||= prepare_encoded_classifier
      end
  
      def prepare_encoded_classifier
        classifier_code = Marshal.dump(classifier)
        Base64.strict_encode64(classifier_code)
      end
  
      def prepare_output_file_path
        path = Pathname(@output_dir)
        path + classifier_name
      end
    end
  end
end
