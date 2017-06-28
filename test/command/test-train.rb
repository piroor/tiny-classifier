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

    def setup
      common_setup
      @categories = %w(positive negative)
    end

    class Success < self
      def test_long_categories
        set_input("foo bar bazz")
        assert_true TinyClassifier::Command::Train.run([
          "--categories=#{@categories.join(",")}",
          "positive",
        ])
        assert_data_file_exist
      end

      def test_short_categories
        set_input("foo bar bazz")
        assert_true TinyClassifier::Command::Train.run([
          "-c", @categories.join(","),
          "positive",
        ])
        assert_data_file_exist
      end

      def test_long_mecab
        set_input("日本語の文章")
        assert_true TinyClassifier::Command::Train.run([
          "--categories=#{@categories.join(",")}",
          "--tokenizer=mecab",
          "positive",
        ])
        assert_data_file_exist
      end

      def test_short_mecab
        set_input("日本語の文章")
        assert_true TinyClassifier::Command::Train.run([
          "--categories=#{@categories.join(",")}",
          "-t", "mecab",
          "positive",
        ])
        assert_data_file_exist
      end
    end

    class Fail < self
      def test_no_input
        assert_false TinyClassifier::Command::Train.run([
          "--categories=#{@categories.join(",")}",
          "positive",
        ])
        assert_data_file_not_exist
      end

      def test_no_categories
        set_input("foo bar bazz")
        assert_false TinyClassifier::Command::Train.run([
          "positive",
        ])
        assert_data_file_not_exist
      end

      def test_no_category
        set_input("foo bar bazz")
        assert_false TinyClassifier::Command::Train.run([
          "--categories=#{@categories.join(",")}",
        ])
        assert_data_file_not_exist
      end

      def test_unknown_category
        set_input("foo bar bazz")
        assert_false TinyClassifier::Command::Train.run([
          "--categories=#{@categories.join(",")}",
          "unknown",
        ])
        assert_data_file_not_exist
      end
    end
  end
end
