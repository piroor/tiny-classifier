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
    class Train < Base
      class << self
        def run(argv=nil)
          argv ||= ARGV.dup
          trainer = new(argv)
          trainer.run
        end
      end

      def initialize(argv=[])
        super
        option_parser.banner += " CATEGORY"
        *categories = parse_command_line_options(argv)
        @category = categories.first
      end

      def run
        prepare_category
        raise NoEffectiveInput.new if input.empty?

        classifier.train(@category, input)
        save
        true
      rescue StandardError => error
        handle_error(error)
      end

      private
      def prepare_category
        raise NoCategory.new unless @category

        @category = @categories.normalize(@category)

        unless @categories.valid?(@category)
          raise InvalidCategory.new(@category, @categories.all)
        end

        log("training as: #{@category}")
      end

      def save
        data = Marshal.dump(classifier)
        File.open(data_file_path, "w") do |file|
          file.write(data)
        end
      end
    end
  end
end
