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

require "tiny-classifier/category-manager"

class CategoryMnagerTest < Test::Unit::TestCase
  data(
    single:      { expected: ["Positive"],
                   input:    "positive" },
    multiple:    { expected: ["Positive", "Negative"].sort,
                   input:    "positive,negative" },
    whitespaces: { expected: ["Positive", "Negative"].sort,
                   input:    "  positive  ,  negative  " },
    blank:       { expected: ["Positive", "Negative"].sort,
                   input:    ",positive,,negative,," },
    duplicated:  { expected: ["Positive", "Negative"].sort,
                   input:    "negative,positive,positive,negative,negative,positive" },
  )
  def test_creation(data)
    categories = TinyClassifier::CategoryManager.new(data[:input])
    assert_equal(data[:expected], categories.all)
  end

  data(
    downcase: { expected: "Positive",
                input:    "positive" },
    upcase:   { expected: "Positive",
                input:    "POSITIVE" },
    mixed:    { expected: "Positive",
                input:    "pOsItIvE" },
  )
  def test_normalize(data)
    categories = TinyClassifier::CategoryManager.new("")
    assert_equal(data[:expected], categories.normalize(data[:input]))
  end
end
