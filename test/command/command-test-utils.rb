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
  def common_setup
    @temp_dir = Pathname(Dir.mktmpdir)
    @working_dir = Dir.pwd
    Dir.chdir(@temp_dir)
    $stdout = StringIO.new
    $stderr = StringIO.new
  end

  def setup
    common_setup
  end

  def common_teardown
    Dir.chdir(@working_dir)
    FileUtils.remove_entry_secure(@temp_dir)
    @temp_dir = nil
    @working_dir = nil
    $stdin = STDIN
    $stdout = STDOUT
    $stderr = STDERR
  end

  def teardown
    common_teardown
  end

  private
  def set_input(input)
    $stdin = StringIO.new(input)
  end

  def data_file_path
    categories = @categories.collect(&:downcase).sort.join("-")
    @temp_dir + "tc.#{categories}.dat"
  end

  def assert_data_file_exist
    assert_true(data_file_path.exist?)
  end

  def assert_data_file_not_exist
    assert_false(data_file_path.exist?)
  end
end
