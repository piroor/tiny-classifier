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
    temp_dirs << Pathname(Dir.mktmpdir)
    @working_dir = Dir.pwd
    Dir.chdir(last_temp_dir)
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
    temp_dirs.each do |dir|
      FileUtils.remove_entry_secure(dir)
    end
    temp_dirs.clear
  end

  private
  def temp_dirs
    @temp_dirs ||= []
  end

  def last_temp_dir
    temp_dirs.last
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
end
