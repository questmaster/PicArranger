require 'exifr'
require 'date'
require 'optparse'
require 'fileutils'
require 'zlib'


def parse_args (options)
  args = {}
  args[:verbose] = false
  args[:output_folder] = File.expand_path(File.dirname(__FILE__))
  args[:copy_only] = false

  opt_parser = OptionParser.new do |opts|
    opts.banner = "Usage: picarranger.rb [options] <imagefolders>"

    opts.on("-oPATH", "--output-path=PATH", "Path where to put the processed images.") do |path|
      args[:output_folder] = path
    end

    opts.on("-v", "--verbose", "Print verbose messages.") do
      args[:verbose] = true
    end

    opts.on("-c", "--copy-only", "Copy only, dont move images.") do
      args[:copy_only] = true
    end

    opts.on("-h", "--help", "Prints this help") do
      puts opts
      #exit
    end
  end

  opt_parser.parse!(options)

  args
end

def find_image_files (path, options)
  files = []
  extensions = %w(jpg jpeg nef tif tiff)

  extensions.each do |extension|
    puts "  Process extension: #{extension}..." if options[:verbose]

# Sucht nach jpg's im aktuellen und darunter liegenden Verzeichnissen
    Dir.chdir(path)
    Dir.glob("**/*.#{extension}", File::FNM_CASEFOLD) do |thefile|
      puts "    Found: #{thefile}" if options[:verbose]

      files << File.expand_path(thefile, path)
    end
  end

  files
end

def extend_and_create_path(path, folder)
  destination_dir = File.join(path, folder)
  Dir.mkdir(destination_dir) unless File.exists?(destination_dir)

  destination_dir
end

def calc_file_crc(image)
  File.open(image, "rb") { |f| Zlib.crc32 f.read }
end

def do_move_images_in_structure (images, options)
  script_path = options[:output_folder]
  verbose = options[:verbose]
  copy_only = options[:copy_only]

  Dir.chdir(script_path)

  images.each do |image|
# datum aus exif extrahieren (Jahr/Monat)
    image_filename = File.basename(image)

    case image
      when /\.(jpg|jpeg)$/i; date_str = EXIFR::JPEG.new(image).date_time_original
      when /\.(tif|tiff|nef)$/i; date_str = EXIFR::TIFF.new(image).date_time_original
      else
        raise 'Image #{image} has unsupported extension.'
    end

    # no exif data found; get oldest file timestamp
    if date_str == nil
      image_atime = File.atime(image)
      image_ctime = File.ctime(image)
      image_mtime = File.mtime(image)

      date_str = [image_atime, image_ctime, image_mtime].min
    end

    image_year = date_str.year.to_s
    image_month = date_str.month.to_s

    destination_dir = extend_and_create_path(script_path, image_year)
    destination_dir = extend_and_create_path(destination_dir, image_month)

    destination_file = File.join(destination_dir, image_filename)

    puts "  Image: #{image_filename} transfer to #{destination_file}" if verbose

    crc32_source = calc_file_crc(image)
    if not File.exists? destination_file

      FileUtils.cp(image, destination_file)

      if not copy_only
        crc32_destination = calc_file_crc(destination_file)
        if crc32_source == crc32_destination
          puts "   File #{image_filename} moved." if verbose
          FileUtils.rm_f(image)
        else
          puts "   File #{image_filename}, error at copying, reverting." if verbose
          FileUtils.rm_f(destination_file)
        end
      else
        puts "   File #{image_filename} copied." if verbose
      end

    else
      crc32_destination = calc_file_crc(destination_file)
      if (crc32_source == crc32_destination) and not copy_only
        puts "   File #{image_filename} already exists. Removing source."
        FileUtils.rm_f(image)
      else
        puts "   File #{image_filename} already exists. Leaving in #{File.dirname(image)}."
      end
    end
  end
end



# Main code
args  = ARGV

## Parse CMD-Line commands
options = parse_args (args)
puts args if options[:verbose]

## Check for image path
if args.length > 0
  args.each do |a_path|
    path = File.expand_path(a_path)
    if File.directory? path
      puts "Process folder #{path}..."

## Find all image files
      image_file = find_image_files(path, options)
      puts image_file  if options[:verbose]

## Move images in Folder-Structure
### Check integrity
### Move file
      do_move_images_in_structure(image_file, options)
      
      puts "...done."
    end
  end
else
  parse_args(["-h"])
end


