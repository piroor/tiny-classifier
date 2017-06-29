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

require "tiny-classifier/command/train"

module TinyClassifier
  module Command
    class Retrain < Base
      def initialize(argv=[])
        super
        option_parser.banner += " WRONG CORRECT"
        *categories = parse_command_line_options(argv)
        @wrong_category = categories.shift
        @correct_category = categories.shift
      end

      def run
        prepare_categories
        raise NoEffectiveInput.new if input.empty?

        classifier.untrain(@wrong_category, input)
        classifier.train(@correct_category, input)
        save
        true
      rescue StandardError => error
        handle_error(error)
      end

      private
      def prepare_categories
        raise NoWrongCategory.new unless @wrong_category
        @wrong_category = @categories.normalize(@wrong_category)
        unless @categories.valid?(@wrong_category)
          raise InvalidWrongCategory.new(@wrong_category, @categories.all)
        end

        raise NoCorrectCategory.new unless @correct_category
        @correct_category = @categories.normalize(@correct_category)
        unless @categories.valid?(@correct_category)
          raise InvalidCorrectCategory.new(@correct_category, @categories.all)
        end

        log("training as: #{@wrong_category} => #{@correct_category}")
      end
    end
  end
end
