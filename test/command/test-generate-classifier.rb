# encoding: UTF-8

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

require "command/command-test-utils"
require "tiny-classifier/command/generate-classifier"

module CommandTest
  class GenerateClassifierTest < Test::Unit::TestCase
    include CommandTestUtils

    def teardown
      cleanup
    end

    def prepare_training_data(ok_input="foo bar bazz", ng_input="hoge fuga piyo")
      run_command(ok_input) do
        TinyClassifier::Command::Train.run([
          "--categories=ok,ng",
          "--tokenizer=mecab",
          "ok",
        ])
      end
      run_command(ng_input) do
        TinyClassifier::Command::Train.run([
          "--categories=ok,ng",
          "--tokenizer=mecab",
          "ng",
        ])
      end
      assert_file_exist(temp_dir + "tc.ng-ok.dat")
    end

    class InterfaceTest < self
      def test_long_categories
        prepare_training_data
        run_command do
          TinyClassifier::Command::GenerateClassifier.run([
            "--categories=ok,ng",
          ])
        end
        assert_success
        assert_file_exist(temp_dir + "tc-classify-ng-ok")
      end

      def test_short_categories
        prepare_training_data
        run_command do
          TinyClassifier::Command::GenerateClassifier.run([
            "-c", "ok,ng",
          ])
        end
        assert_success
        assert_file_exist(temp_dir + "tc-classify-ng-ok")
      end

      def test_long_tokenizer_mecab
        prepare_training_data
        run_command do
          TinyClassifier::Command::GenerateClassifier.run([
            "--categories=ok,ng",
            "--tokenizer=mecab",
          ])
        end
        assert_success
        assert_file_exist(temp_dir + "tc-classify-ng-ok")
      end

      def test_short_tokenizer_mecab
        prepare_training_data
        run_command do
          TinyClassifier::Command::GenerateClassifier.run([
            "--categories=ok,ng",
            "-t", "mecab",
          ])
        end
        assert_success
        assert_file_exist(temp_dir + "tc-classify-ng-ok")
      end

      def test_no_categories
        prepare_training_data
        run_command do
          TinyClassifier::Command::GenerateClassifier.run([
          ])
        end
        assert_fail
        assert_error_message(TinyClassifier::NoCategories.new.message)
        assert_file_not_exist(temp_dir + "tc-classify-ng-ok")
      end

      def test_long_data_dir
        prepare_training_data
        assert_file_exist(temp_dir + "tc.ng-ok.dat")
        data_dir = temp_dir + "sub_dir"
        FileUtils.mkdir_p(data_dir)
        FileUtils.mv(temp_dir + "tc.ng-ok.dat", data_dir)
        run_command do
          TinyClassifier::Command::GenerateClassifier.run([
            "--categories=ok,ng",
            "--data-dir=#{data_dir.to_s}",
          ])
        end
        assert_success
      end

      def test_short_data_dir
        prepare_training_data
        assert_file_exist(temp_dir + "tc.ng-ok.dat")
        data_dir = temp_dir + "sub_dir"
        FileUtils.mkdir_p(data_dir)
        FileUtils.mv(temp_dir + "tc.ng-ok.dat", data_dir)
        run_command do
          TinyClassifier::Command::GenerateClassifier.run([
            "--categories=ok,ng",
            "-d", data_dir.to_s,
          ])
        end
        assert_success
      end
    end

    class GeneratingResultTest < self
      def test_generate
        prepare_training_data
        command = nil
        run_command do
          command = TinyClassifier::Command::GenerateClassifier.new([
            "--categories=ok,ng",
          ])
          command.run
        end
        assert_success
        command_path = temp_dir + "tc-classify-ng-ok"
        assert_file_exist(command_path)

        codes = File.read(command_path)
        run_command("foo bar") do
          eval(codes)
        end
        assert_success
        assert_classified_as("ok")
      end

      def test_generate_with_mecab
        prepare_training_data("日本語のテキスト")
        command = nil
        run_command do
          command = TinyClassifier::Command::GenerateClassifier.new([
            "--categories=ok,ng",
            "--tokenizer=mecab",
          ])
          command.run
        end
        assert_success
        command_path = temp_dir + "tc-classify-ng-ok"
        assert_file_exist(command_path)

        codes = File.read(command_path)
        run_command("日本語のテキスト") do
          eval(codes)
        end
        assert_success
        assert_classified_as("ok")
      end

      def test_no_training_data
        command = nil
        run_command do
          command = TinyClassifier::Command::GenerateClassifier.new([
            "--categories=ok,ng",
          ])
          command.run
        end
        assert_fail
        assert_error_message(TinyClassifier::NoTrainingData.new(temp_dir + "tc.ng-ok.dat").message)
      end

      def test_no_output_dir
        prepare_training_data
        command = nil
        run_command do
          command = TinyClassifier::Command::GenerateClassifier.new([
            "--categories=ok,ng",
            "--tokenizer=mecab",
            "--output-dir=#{temp_dir + "missing"}"
          ])
          command.run
        end
        assert_fail
        assert_error_message(TinyClassifier::InvalidOutputDir.new(temp_dir + "missing").message)
      end
    end
  end
end
