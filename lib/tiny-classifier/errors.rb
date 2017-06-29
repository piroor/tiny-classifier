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
  class TinyClassifierError < StandardError
  end

  class NoInput < TinyClassifierError
    def message
      "No input. You need to give any input via the STDIN."
    end
  end

  class NoEffectiveInput < TinyClassifierError
    def message
      "No effective input."
    end
  end

  class NoCategories < TinyClassifierError
    def message
      "You need to specify categories."
    end
  end

  class NoCategory < TinyClassifierError
    def message
      "You need to specify a category for the input."
    end
  end

  class NoWrongCategory < NoCategory
  end

  class NoCorrectCategory < NoCategory
  end

  class InvalidCategory < TinyClassifierError
    attr_reader :category, :categories

    def initialize(category, categories)
      @category = category
      @categories = categories
    end

    def message
      "You need to specify one of valid categories: #{@categories.join(", ")}"
    end
  end

  class InvalidWrongCategory < InvalidCategory
  end

  class InvalidCorrectCategory < InvalidCategory
  end

  class NoTrainingData < TinyClassifierError
    attr_reader :data_dir

    def initialize(data_dir)
      @data_dir = data_dir
    end

    def message
      "There is no training data at #{@data_dir}."
    end
  end

  class InvalidOutputDir < TinyClassifierError
    attr_reader :output_dir

    def initialize(output_dir)
      @output_dir = output_dir
    end

    def message
      "#{@output_dir} is not available as the output directory."
    end
  end
end
