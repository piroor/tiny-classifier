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

require "tiny-classifier/command/base"

module TinyClassifier
  module Command
    class Untrain < Base
      def initialize(argv=[])
        super
        option_parser.banner += " CATEGORY"
        *categories = parse_command_line_options(argv)
        @category = categories.first
      end

      def run
        super
        @category = prepare_category(@category)
        log("untraining as: #{@category}")
        raise NoEffectiveInput.new if input.empty?
        raise NoTrainingData.new(data_file_path) unless data_file_path.exist?

        classifier.untrain(@category, input)
        save
        true
      rescue StandardError => error
        handle_error(error)
      end
    end
  end
end
