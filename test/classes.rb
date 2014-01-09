#
# Expand load path to the 'lib' directory
#
$LOAD_PATH << File.expand_path(File.join(File.dirname(__FILE__), '../lib'))

require 'test/unit'
require 'filestore'

include FileStore

class FileStoreTest < Test::Unit::TestCase
  
  def setup
    # create test directory and file
    @uid = Etc.getlogin
    @basePathSimple = "#{Dir.getwd}/simple_store_test"
    @basePathMulti = "#{Dir.getwd}/multi_store_test"
    @testFileSimple = File.join(@basePathSimple, "testfile.txt")
    @testFileMulti = File.join(@basePathMulti, "testfile.txt")
     
    FileUtils.mkdir(@basePathSimple) if not File.exists?(@basePathSimple)
    FileUtils.mkdir(@basePathMulti) if not File.exists?(@basePathMulti)
    FileUtils.touch(@testFileSimple)
    FileUtils.touch(@testFileMulti)
  end
  
  def teardown
    # remove test directories and file
    FileUtils.remove_dir(@basePathSimple, true) if File.exists?(@basePathSimple)
    FileUtils.remove_dir(@basePathMulti, true) if File.exists?(@basePathMulti)
  end
  
end

class ObserverClass
  include Observer
  include Logger
  
  def initialize()
  end
  
  def notify(msg, obj)
    self.logger.info "[ObserverClass] received msg '#{msg.to_s}' from observed object #{obj}"
  end
end

class OtherObserverClass
  include Observer
  include Logger
  
  def initialize
  end
  
  def notify(msg, obj)
    self.logger.info "[OtherObserverClass] received msg '#{msg.to_s}' from observed object #{obj}"
  end
end