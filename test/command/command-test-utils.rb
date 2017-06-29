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

require "fileutils"
require "tempfile"
require "pathname"

module CommandTestUtils
  def run_command(input = nil, &block)
    @working_dir = Dir.pwd
    Dir.chdir(temp_dir)
    $stdin = StringIO.new(input) if input
    $stdout = StringIO.new
    $stderr = StringIO.new

    @exit_status = yield

    Dir.chdir(@working_dir)
    @working_dir = nil
    $stdin = STDIN
    $stdout = STDOUT
    $stderr = STDERR
  end

  def cleanup
    FileUtils.remove_entry_secure(@temp_dir) if @temp_dir
    @temp_dir = nil
  end

  private
  def temp_dir
    @temp_dir ||= Pathname(Dir.mktmpdir)
  end

  def read_training_result(command)
    data = File.read(command.data_file_path)
    classifier = Marshal.load(data)
    classifier.instance_variable_get('@categories')
  end

  def assert_success
    assert_true(@exit_status)
  end

  def assert_fail
    assert_false(@exit_status)
  end

  def assert_file_exist(path)
    assert_true(Pathname(path).exist?)
  end

  def assert_file_not_exist(path)
    assert_false(Pathname(path).exist?)
  end

  def term(term)
    term.stem.intern
  end
end
