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

module TinyClassifier::Command
  class Train < Base
    class << self
      def run(argv=nil)
        argv ||= ARGV.dup
        trainer = new
        *categories = trainer.parse_command_line_options(argv)
        trainer.run(category: categories.first)
      end
    end

    def initialize
      super
      option_parser.banner += " CATEGORY"
    end

    def run(params)
      @category = params[:category]
      prepare_category
      if input.empty?
        error("Error: No effective input.")
        false
      else
        classifier.train(@category, input)
        save
        true
      end
    end

    private
    def prepare_category
      unless @category
        error("Error: You need to specify the category for the input.")
        exit(false)
      end

      @category = @categories.normalize(@category)

      if @category.empty?
        error("Error: You need to specify the category for the input.")
        exit(false)
      end

      unless @categories.valid?(@category)
        error("Error: You need to specify one of valid categories: #{@categories.all.join(", ")}")
        exit(false)
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
