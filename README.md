# PicArranger [![Build Status](https://travis-ci.org/questmaster/PicArranger.svg?branch=master)](https://travis-ci.org/questmaster/PicArranger)
This ruby script will look recursively for your jpg/tif/nef files in the given directories and move it to its location
and store it in a folder structure of 'year/month'. The data is extracted from the exif-data or the files timestamps,
if no exif-data is available.

# Usage
    Usage: picarranger.rb [options] <imagefolders>
    -o, --output-path=PATH           Path where to put the processed images.
    -v, --verbose                    Print verbose messages.
    -c, --copy-only                  Copy only, dont move images.
    -h, --help                       Prints this help
    
    
