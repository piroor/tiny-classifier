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

module TinyClassifier
  class CategoryManager
    attr_reader :chosen

    def initialize(categories)
      @categories = categories.strip.split(",")
      normalize_all
      clanup
    end

    def all
      @categories
    end

    def valid?(category)
      category = normalize(category)
      @categories.include?(category)
    end

    def basename
      @categories.join("-").downcase
    end

    def normalize(category)
      category
        .downcase
        .strip
        .capitalize
    end

    private
    def normalize_all
      @categories.collect! do |category|
        normalize(category)
      end
    end

    def clanup
      @categories.reject! do |category|
          category.empty?
      end
      @categories.uniq!
      @categories.sort!
    end
  end
end
