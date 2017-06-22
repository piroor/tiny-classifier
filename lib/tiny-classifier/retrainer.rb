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

require "tiny-classifier/trainer"

module TinyClassifier
  class Retrainer < Trainer
    class << self
      def run(argv=nil)
        argv ||= ARGV.dup
        retrainer = new
        *categories = retrainer.parse_command_line_options(argv)
        retrainer.run(wrong: categories[0],
                      correct: categories[1])
      end
    end

    def run(params)
      if input.empty?
        STDERR.puts("Error: No effective input.")
        false
      else
        @category = params[:wrong]
        prepare_category
        classifier.send("untrain_#{@category}", input)
        @category = params[:correct]
        prepare_category
        classifier.send("train_#{@category}", input)
        save
        true
      end
    end
  end
end
