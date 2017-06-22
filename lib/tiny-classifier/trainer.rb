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

require "tiny-classifier/base"

class Trainer < TinyClassifierBase
  class << self
    def run(argv=nil)
      argv ||= ARGV.dup
      trainer = new
      *labels = trainer.parse_command_line_options(argv)
      input = $stdin.readlines.join("\n")
      trainer.run(label: labels.first,
                  input: input)
    end
  end

  def run(params)
    @label = params[:label]
    @input = params[:input]
    prepare_input
    if @input.empty?
      exit(1)
    else
      classifier.send("train_#{@label.downcase}", @input)
      save
      exit(0)
    end
  end

  private
  def save
    data = Marshal.dump(classifier)
    File.open(data_file_path, "w") do |file|
      file.write(data)
    end
  end
end
