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

module CommandTest
  class TrainTest < Test::Unit::TestCase
    include CommandTestUtils

    def teardown
      cleanup
    end

    class InterfaceTest < self
      def test_long_categories
        run_command("foo bar bazz") do
          TinyClassifier::Command::Train.run([
            "--categories=ok,ng",
            "ok",
          ])
        end
        assert_success
        assert_file_exist(last_temp_dir + "tc.ng-ok.dat")
      end

      def test_short_categories
        run_command("foo bar bazz") do
          TinyClassifier::Command::Train.run([
            "-c", "ok,ng",
            "ok",
          ])
        end
        assert_success
        assert_file_exist(last_temp_dir + "tc.ng-ok.dat")
      end

      def test_long_tokenizer_mecab
        run_command("日本語の文章") do
          TinyClassifier::Command::Train.run([
            "--categories=ok,ng",
            "--tokenizer=mecab",
            "ok",
          ])
        end
        assert_success
        assert_file_exist(last_temp_dir + "tc.ng-ok.dat")
      end

      def test_short_tokenizer_mecab
        run_command("日本語の文章") do
          TinyClassifier::Command::Train.run([
            "--categories=ok,ng",
            "-t", "mecab",
            "ok",
          ])
        end
        assert_success
        assert_file_exist(last_temp_dir + "tc.ng-ok.dat")
      end

      def test_no_input
        run_command do
          TinyClassifier::Command::Train.run([
            "--categories=ok,ng",
            "ok",
          ])
        end
        assert_fail
        assert_file_not_exist(last_temp_dir + "tc.ng-ok.dat")
      end

      def test_no_categories
        run_command("foo bar bazz") do
          TinyClassifier::Command::Train.run([
            "ok",
          ])
        end
        assert_fail
        assert_file_not_exist(last_temp_dir + "tc.ng-ok.dat")
      end

      def test_no_category
        run_command("foo bar bazz") do
          TinyClassifier::Command::Train.run([
            "--categories=ok,ng",
          ])
        end
        assert_fail
        assert_file_not_exist(last_temp_dir + "tc.ng-ok.dat")
      end

      def test_unknown_category
        run_command("foo bar bazz") do
          TinyClassifier::Command::Train.run([
            "--categories=ok,ng",
            "unknown",
          ])
        end
        assert_fail
        assert_file_not_exist(last_temp_dir + "tc.ng-ok.dat")
      end
    end

    class TrainingResultTest < self
      def test_trained
        command = nil
        run_command("foo bar bazz") do
          command = TinyClassifier::Command::Train.new([
            "--categories=ok,ng",
            "ok",
          ])
          command.run
        end
        assert_success
        assert_equal({ Ok: {foo: 1, bar: 1, bazz: 1 },
                       Ng: {} },
                    read_training_result(command))
      end

      def test_trained_with_mecab
        command = nil
        run_command("日本語のテキスト") do
          command = TinyClassifier::Command::Train.new([
            "--categories=ok,ng",
            "--tokenizer=mecab",
            "ok",
          ])
          command.run
        end
        assert_success
        assert_equal({ Ok: {term("日本語") => 1,
                            term("テキスト") => 1},
                       Ng: {} },
                    read_training_result(command))
      end

      def test_not_trained
        command = nil
        run_command("foo bar bazz") do
          command = TinyClassifier::Command::Train.new([
            "--categories=ok,ng",
            "invalid",
          ])
          command.run
        end
        assert_fail
        assert_file_not_exist(last_temp_dir + "tc.ng-ok.dat")
      end
    end
  end
end
