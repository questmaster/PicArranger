require_relative '../src/picarranger'
require 'test/unit'
require 'fileutils'

class PicArrangerTest < Test::Unit::TestCase

  # Called before every test method runs. Can be used
  # to set up fixture information.
  def setup
    if @default_folder == nil
      @default_folder = File.dirname(File.expand_path(__FILE__))
    end
    @temp_folder = File.join(@default_folder, 'tmp')


    FileUtils.chdir(@default_folder)
    FileUtils.mkdir(@temp_folder)
    FileUtils.cp(['data/B0019278.JPG', 'data/B0020882.NEF'], @temp_folder)
    FileUtils.chdir(@temp_folder)

    assert_true(File.exists?('B0019278.JPG'))
    assert_true(File.exists?('B0020882.NEF'))
  end

  # Called after every test method runs. Can be used to tear
  # down fixture information.

  def teardown
    FileUtils.chdir(@default_folder)
    FileUtils.rm_r('tmp')

    assert_false(File.exists?('tmp'))
  end

  # Test commandline options parser
  def test_options_parser
    input_short = '-oC:\test -v -c pass'.split(" ")
    input_long = '--output-path=C:\test --verbose --copy-only pass'.split(" ")

    [input_short, input_long].each do |input|
      options = parse_args(input)

      assert_equal('C:\test', options[:output_folder])
      assert_true(options[:verbose])
      assert_true(options[:copy_only])
      assert_equal(['pass'], input)
    end
  end

  #
  def test_find_image_files
    options = {}
    options[:verbose] = false

    expected = [File.expand_path('B0019278.JPG'), File.expand_path('B0020882.NEF')]

    actual = find_image_files(FileUtils.pwd, options)

    assert_equal(2, actual.size)
    [1..2].each do |i|
      assert_equal(expected[i], actual[i])
    end
  end

  #
  def test_extend_and_create_path
    extend_and_create_path(FileUtils.pwd, 'test')

    assert_true(File.directory?(File.expand_path('test')))
  end

  # Test file crc calculation
  def test_calc_file_crc
    input = File.expand_path('B0019278.JPG')

    crc32 = calc_file_crc(input)

    assert_equal(309668251, crc32)
  end

  #
  def test_do_move_images_jpg
    options = default_options

    image = File.expand_path('B0019278.JPG')
    do_move_images_in_structure([image], options)

    assert_false(File.exists?(image))
    assert_true(File.directory?('2010'))
    FileUtils.chdir('2010')
    assert_true(File.directory?('3'))
    FileUtils.chdir('3')
    assert_true(File.exists?('B0019278.JPG'))
  end

  #
  def test_do_move_images_tif
    options = default_options

    image = File.expand_path('B0020882.NEF')
    do_move_images_in_structure([image], options)

    assert_false(File.exists?(image))
    assert_true(File.directory?('2011'))
    FileUtils.chdir('2011')
    assert_true(File.directory?('7'))
    FileUtils.chdir('7')
    assert_true(File.exists?('B0020882.NEF'))
  end

  #
  def test_do_move_images_dest_exists
    options = default_options
    create_existing_dest_jpg

    image = File.expand_path('B0019278.JPG')
    do_move_images_in_structure([image], options)

    assert_false(File.exists?(image))
    assert_true(File.directory?('2010'))
    FileUtils.chdir('2010')
    assert_true(File.directory?('3'))
    FileUtils.chdir('3')
    assert_true(File.exists?('B0019278.JPG'))
  end

  #
  def test_do_move_images_dest_exists_copy_only
    options = default_options
    options[:copy_only] = true
    create_existing_dest_jpg

    image = File.expand_path('B0019278.JPG')
    do_move_images_in_structure([image], options)

    assert_true(File.exists?(image))
    assert_true(File.directory?('2010'))
    FileUtils.chdir('2010')
    assert_true(File.directory?('3'))
    FileUtils.chdir('3')
    assert_true(File.exists?('B0019278.JPG'))
  end

  #
  def test_do_move_images_copy_only
    options = default_options
    options[:copy_only] = true

    image = File.expand_path('B0019278.JPG')
    do_move_images_in_structure([image], options)

    assert_true(File.exists?(image))
    assert_true(File.directory?('2010'))
    FileUtils.chdir('2010')
    assert_true(File.directory?('3'))
    FileUtils.chdir('3')
    assert_true(File.exists?('B0019278.JPG'))
  end

  #
  # H E L P E R
  #

  def default_options
    options = {}
    options[:verbose] = false
    options[:copy_only] = false
    options[:output_folder] = FileUtils.pwd

    options
  end

  def create_existing_dest_jpg
    new_path = '2010/3'
    FileUtils.mkpath(new_path)
    FileUtils.cp('B0019278.JPG', File.expand_path(new_path))
  end
end