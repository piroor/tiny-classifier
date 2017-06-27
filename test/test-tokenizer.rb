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

require "tiny-classifier/tokenizer"

class TokenizerTest < Test::Unit::TestCase
  class DefaultTokenizerTest < self
    def setup
      @tokenizer = TinyClassifier::Tokenizer.new
    end

    def test_space_separated
      input = "This is space separated text"
      assert_equal(input, @tokenizer.tokenize(input))
    end

    def test_not_separated
      input = "ThisTextIsNotSeparated"
      assert_equal(input, @tokenizer.tokenize(input))
    end
  end

  class MeCabTokenizerTest < self
    def setup
      @tokenizer = TinyClassifier::Tokenizer.new(:type => :mecab)
    end

    def test_space_separated
      input = "This is space separated text"
      assert_equal(input, @tokenizer.tokenize(input))
    end

    def test_not_separated
      input = "ThisTextIsNotSeparated"
      assert_equal(input, @tokenizer.tokenize(input))
    end
  end
end
