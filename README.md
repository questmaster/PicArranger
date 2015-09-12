# PicArranger [![Build Status](https://travis-ci.org/questmaster/PicArranger.png)](https://travis-ci.org/questmaster/PicArranger)
This ruby script will look recursively for your jpg/tif/nef files in the given directories and move it to its location and store it in a folderstructure of 'year/month'. The data is extracted from the exif-data.

# Usage
Usage: picarranger.rb [options] <imagefolders>
    -o, --output-path=PATH           Path where to put the processed images.
    -v, --verbose                    Print verbose messages.
    -c, --copy-only                  Copy only, dont move images.
    -h, --help                       Prints this help
    
    
