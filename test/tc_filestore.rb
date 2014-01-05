#
# tc_filestore.rb
# @author Thomas Stätter
# @date 2012/11/14
#
# require 'filestore'
require './classes.rb'
require 'test/unit'

include FileStore

class TestFileStore < FileStoreTest
  
  def test_init_shutdown
    puts "=" * 80
    puts "TestFileStore::test_init_shutdown"
    puts "=" * 80
    
    mm = MemoryMetaManager.new File.join(@basePath, "meta.yaml"), StdoutLogger
    sfs = nil
    
    assert_nothing_raised(FileStoreException) {
      sfs = SimpleFileStore.new mm, @basePath, StdoutLogger
    }
    assert_not_nil(sfs)
    assert_nothing_raised(FileStoreException) {
      sfs.shutdown
    }
  end
  
  def test_registration_observer
    puts "=" * 80
    puts "TestFileStorage::test_registration_observer"
    puts "=" * 80
    
    mm = MemoryMetaManager.new File.join(@basePath, "meta.yaml"), StdoutLogger
    sfs = SimpleFileStore.new mm, @basePath, StdoutLogger
    o1 = OtherObserverClass.new
    o2 = ObserverClass.new
    
    assert_nothing_raised(FileStoreException) { 
      sfs.register o1
      sfs.register o2
    }
    assert_raise(FileStoreException) { sfs.register o1 }
    assert_nothing_raised(FileStoreException) { 
      sfs.unregister o1
      sfs.unregister o2
    }
  end
  
  def test_actions_with_observer
    puts "=" * 80
    puts "TestFileStorage::test_actions_with_observer"
    puts "=" * 80
    
    o1 = ObserverClass.new    
    o1.logger = StdoutLogger
    mm = MemoryMetaManager.new File.join(@basePath, "meta.yaml"), StdoutLogger
    sfs = SimpleFileStore.new mm, @basePath, StdoutLogger
    id = nil
    
    sfs.register o1
    
    assert_nothing_raised(FileStoreException) { 
      id = sfs.add @testFile, { :original_file => @testFile }, false
    }
    assert_nothing_raised(FileStoreException) { file = sfs.get id }
    assert_not_nil(sfs.get(id))
    assert_nothing_raised(FileStoreException) { sfs.remove id }
    assert_nothing_raised(FileStoreException) { sfs.shutdown }
  end
  
end