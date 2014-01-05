#
# filestore.rb
# @author Thomas Stätter
# @date 2012/11/26
# @description
#
LIBS = [
  #
  # Required 3rd party libs
  #
  'uuidtools',
  'fileutils',
  'yaml',
  'etc',
  'singleton'
]
FILESTORE_FILES = [
  #
  # FileStore specific libraries. Order matters!
  #
  'observer',
  'meta_manager',
  'log',
  'memory_meta',
  'simple_store',
  'multitenant_store'
]
#
# Loads required 3rd party libs as defined in FileStore::LIBS
#
LIBS.each do |l|
  require l
end
#
# Loads required files as defined in FileStore::FILESTORE_FILES
#
FILESTORE_FILES.each do |l|
  require File.join('filestore', l)
end
