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
  class Untrainer < Trainer
    def run(params)
      @label = params[:label]
      prepare_label
      if input.empty?
        STDERR.puts("Error: No effective input.")
        false
      else
        classifier.send("untrain_#{@label}", input)
        save
        true
      end
    end
  end
end