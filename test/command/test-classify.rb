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
require "tiny-classifier/command/train"
require "tiny-classifier/command/classify"

module CommandTest
  class ClassifyTest < Test::Unit::TestCase
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
        run_command("foo bar bazz") do
          TinyClassifier::Command::Classify.run([
            "--categories=ok,ng",
          ])
        end
        assert_success
      end

      def test_short_categories
        prepare_training_data
        run_command("foo bar bazz") do
          TinyClassifier::Command::Classify.run([
            "-c", "ok,ng",
          ])
        end
        assert_success
      end

      def test_long_tokenizer_mecab
        prepare_training_data
        run_command("日本語の文章") do
          TinyClassifier::Command::Classify.run([
            "--categories=ok,ng",
            "--tokenizer=mecab",
          ])
        end
        assert_success
      end

      def test_short_tokenizer_mecab
        prepare_training_data
        run_command("日本語の文章") do
          TinyClassifier::Command::Classify.run([
            "--categories=ok,ng",
            "-t", "mecab",
          ])
        end
        assert_success
      end

      def test_no_input
        prepare_training_data
        run_command do
          TinyClassifier::Command::Classify.run([
            "--categories=ok,ng",
          ])
        end
        assert_fail
      end

      def test_no_categories
        prepare_training_data
        run_command("foo bar bazz") do
          TinyClassifier::Command::Classify.run([
          ])
        end
        assert_fail
      end
    end

    class ClassifyingResultTest < self
      def test_classify
        prepare_training_data
        command = nil
        run_command("foo bar") do
          command = TinyClassifier::Command::Classify.new([
            "--categories=ok,ng",
          ])
          command.run
        end
        assert_success
        assert_classified_as("ok")
      end

      def test_classify_with_mecab
        prepare_training_data("日本語のテキスト")
        command = nil
        run_command("日本語") do
          command = TinyClassifier::Command::Classify.new([
            "--categories=ok,ng",
            "--tokenizer=mecab",
          ])
          command.run
        end
        assert_success
        assert_classified_as("ok")
      end
    end
  end
end
