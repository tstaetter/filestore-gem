#
# filestore.rb
# @author Thomas Stätter
# @date 2012/11/26
# @description
#
module FileStore
	VERSION = '0.0.8'
	LIB_FILES = [
    #
    # Required 3rd party libs
    #
    'uuidtools',
    'fileutils',
    'yaml',
    'singleton',
    'etc',
    #
    # FileStore specific libraries. Order matters!
    #
    'lib/meta_manager.rb',
    'lib/log.rb',
    'lib/observer.rb',
    'lib/filestore.rb',
    'lib/multitenant_filestore.rb',
    'lib/memory_meta.rb'
  ]
	#
  # Loads required libs as defined in FileStore::LIB_FILES
  #  
  def self.load_required
    $LOAD_PATH << File.dirname(File.new(__FILE__))
    
    LIB_FILES.each do |l| 
      require l
    end
  end
end

FileStore::load_required