require 'test/unit'

class FileStoreTest < Test::Unit::TestCase
  
  def setup
    # create test directory and file
    @basePath = "#{Dir.getwd}/store_test"
    @testFile = File.join(@basePath, "testfile.txt")
     
    FileUtils.mkdir(@basePath) if not File.exists?(@basePath)
    FileUtils.touch(@testFile) if not File.exists?(@testFile)
  end
  
  def teardown
    # remove test directory and file
    FileUtils.remove_dir(@basePath, true) if File.exists?(@basePath)
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