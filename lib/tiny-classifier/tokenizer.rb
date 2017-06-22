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

class Tokenizer
  TOKENIZERS = [:none, :mecab]

  attr_accessor :type

  def initialize
    @type = :none
  end

  def tokenize(input)
    case @tokenizer
    when :mecab
      tokenize_by_mecab(input)
    else
      input
    end
  end

  private
  def tokenize_by_mecab(input)
    require "natto"
    natto = Natto::MeCab.new
    terms = []
    natto.parse(input) do |term|
      if term.feature =~ /\A(名詞|形容詞|動詞)/
        terms << term.surface
      end
    end
    terms.join(" ").strip
  end
end
