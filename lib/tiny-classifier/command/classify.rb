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
    class Classify < Base
      def initialize(argv=[])
        super
        parse_command_line_options(argv)
      end

      def run
        super
        raise NoEffectiveInput.new if input.empty?
        raise NoTrainingData.new unless data_file_path.exist?

        category = classifier.classify(input)
        $stdout.puts(category.downcase)
        true
      rescue StandardError => error
        handle_error(error)
      end
    end
  end
end
