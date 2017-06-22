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

  def initialize
    super
    option_parser.banner += "LABEL"
  end

  def run(params)
    @label = params[:label]
    @input = params[:input]
    prepare_label
    prepare_input
    if @input.empty?
      STDERR.puts("Error: No effective input.")
      false
    else
      classifier.send("train_#{@label}", @input)
      save
      true
    end
  end

  private
  def prepare_label
    unless @label
      STDERR.puts("Error: You need to specify the label for the input.")
      exit(false)
    end

    @label = @label.downcase.strip

    if @label.empty?
      STDERR.puts("Error: You need to specify the label for the input.")
      exit(false)
    end

    unless @labels.include?(@label.capitalize)
      STDERR.puts("Error: You need to specify one of valid labels: #{@labels.join(', ')}")
      exit(false)
    end
  end

  def save
    data = Marshal.dump(classifier)
    File.open(data_file_path, "w") do |file|
      file.write(data)
    end
  end
end
