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
require "tiny-classifier/command/untrain"

module CommandTest
  class UntrainTest < Test::Unit::TestCase
    include CommandTestUtils

    def teardown
      cleanup
    end

    def prepare_training_data(input="foo bar bazz")
      run_command(input) do
        TinyClassifier::Command::Train.run([
          "--categories=ok,ng",
          "--tokenizer=mecab",
          "ok",
        ])
      end
      assert_file_exist(temp_dir + "tc.ng-ok.dat")
    end

    class InterfaceTest < self
      def test_long_categories
        prepare_training_data
        run_command("foo bar bazz") do
          TinyClassifier::Command::Untrain.run([
            "--categories=ok,ng",
            "ok",
          ])
        end
        assert_success
      end

      def test_short_categories
        prepare_training_data
        run_command("foo bar bazz") do
          TinyClassifier::Command::Untrain.run([
            "-c", "ok,ng",
            "ok",
          ])
        end
        assert_success
      end

      def test_long_tokenizer_mecab
        prepare_training_data
        run_command("日本語の文章") do
          TinyClassifier::Command::Untrain.run([
            "--categories=ok,ng",
            "--tokenizer=mecab",
            "ok",
          ])
        end
        assert_success
      end

      def test_short_tokenizer_mecab
        prepare_training_data
        run_command("日本語の文章") do
          TinyClassifier::Command::Untrain.run([
            "--categories=ok,ng",
            "-t", "mecab",
            "ok",
          ])
        end
        assert_success
      end

      def test_no_input
        prepare_training_data
        run_command do
          TinyClassifier::Command::Untrain.run([
            "--categories=ok,ng",
            "ok",
          ])
        end
        assert_fail
        assert_error_message(TinyClassifier::NoInput.new.message)
      end

      def test_no_categories
        prepare_training_data
        run_command("foo bar bazz") do
          TinyClassifier::Command::Untrain.run([
            "ok",
          ])
        end
        assert_fail
        assert_error_message(TinyClassifier::NoCategories.new.message)
      end

      def test_no_category
        prepare_training_data
        run_command("foo bar bazz") do
          TinyClassifier::Command::Untrain.run([
            "--categories=ok,ng",
          ])
        end
        assert_fail
        assert_error_message(TinyClassifier::NoCategory.new.message)
      end

      def test_unknown_category
        prepare_training_data
        run_command("foo bar bazz") do
          TinyClassifier::Command::Untrain.run([
            "--categories=ok,ng",
            "unknown",
          ])
        end
        assert_fail
        assert_error_message(TinyClassifier::InvalidCategory.new("unknown", %w(Ng Ok)).message)
      end

      def test_long_data_dir
        prepare_training_data
        assert_file_exist(temp_dir + "tc.ng-ok.dat")
        data_dir = temp_dir + "sub_dir"
        FileUtils.mkdir_p(data_dir)
        FileUtils.mv(temp_dir + "tc.ng-ok.dat", data_dir)
        run_command("foo bar bazz") do
          TinyClassifier::Command::Train.run([
            "--categories=ok,ng",
            "--data-dir=#{data_dir.to_s}",
            "ok",
          ])
        end
        assert_success
        assert_file_exist(data_dir + "tc.ng-ok.dat")
        assert_file_not_exist(temp_dir + "tc.ng-ok.dat")
      end

      def test_short_data_dir
        prepare_training_data
        assert_file_exist(temp_dir + "tc.ng-ok.dat")
        data_dir = temp_dir + "sub_dir"
        FileUtils.mkdir_p(data_dir)
        FileUtils.mv(temp_dir + "tc.ng-ok.dat", data_dir)
        run_command("foo bar bazz") do
          TinyClassifier::Command::Train.run([
            "--categories=ok,ng",
            "-d", data_dir.to_s,
            "ok",
          ])
        end
        assert_success
        assert_file_exist(data_dir + "tc.ng-ok.dat")
        assert_file_not_exist(temp_dir + "tc.ng-ok.dat")
      end
    end

    class UntrainingResultTest < self
      def test_untrained
        prepare_training_data
        command = nil
        run_command("foo bar") do
          command = TinyClassifier::Command::Untrain.new([
            "--categories=ok,ng",
            "ok",
          ])
          command.run
        end
        assert_success
        assert_equal({ Ok: {bazz: 1 },
                       Ng: {} },
                    read_training_result(command))
      end

      def test_untrained_with_mecab
        prepare_training_data("日本語のテキスト")
        command = nil
        run_command("日本語") do
          command = TinyClassifier::Command::Untrain.new([
            "--categories=ok,ng",
            "--tokenizer=mecab",
            "ok",
          ])
          command.run
        end
        assert_success
        assert_equal({ Ok: {term("テキスト") => 1},
                       Ng: {} },
                    read_training_result(command))
      end

      def test_not_untrained
        prepare_training_data
        command = nil
        run_command("foo bar bazz") do
          command = TinyClassifier::Command::Untrain.new([
            "--categories=ok,ng",
            "invalid",
          ])
          command.run
        end
        assert_equal({ Ok: {foo: 1, bar: 1, bazz: 1 },
                       Ng: {} },
                    read_training_result(command))
      end

      def test_no_training_data
        command = nil
        run_command("foo bar bazz") do
          command = TinyClassifier::Command::Untrain.new([
            "--categories=ok,ng",
            "ok",
          ])
          command.run
        end
        assert_fail
        assert_error_message(TinyClassifier::NoTrainingData.new(temp_dir + "tc.ng-ok.dat").message)
      end
    end
  end
end
