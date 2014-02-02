#
# tc_webdav_store.rb
#
# @author Thomas Stätter
# @date 2014/02/01
# @description Test script
#
require './classes.rb'
require 'test/unit'

include FileStore::WebDAV

class TestWebDAVStore < FileStoreTest
  
  def test_01_init_shutdown
    puts "=" * 80
    puts "TestWebDAVStore::test_init_shutdown"
    puts "=" * 80
    
    store = nil
    
    assert_nothing_raised(FileStoreException) {
      store = WebDAVStoreFactory::create 'files', 'owncloud.strawanzen.at', '/remote.php/webdav/', 80, 'demo', 'demo'
    }
    assert_nothing_raised(FileStoreException) {
      store.shutdown
    }
  end
  
  def test_02_observer_registration
    puts "=" * 80
    puts "TestWebDAVStore::test_observer_registration"
    puts "=" * 80
    
    store = nil
    
    assert_nothing_raised(FileStoreException) {
      o1 = ObserverClass.new
      o1.logger = StdoutLogger
      
      store = WebDAVStoreFactory::create 'files/', 'owncloud.strawanzen.at', '/remote.php/webdav/', 80, 'demo', 'demo', true
      
      store.register o1
      store.inform "Some test message"
      store.shutdown
    }
  end

  def test_03_actions_with_observer
    # puts "=" * 80
    # puts "TestWebDAVStore::test_actions_with_observer"
    # puts "=" * 80
  end
  
  def test_04_upload
    puts "=" * 80
    puts "TestWebDAVStore::test_upload"
    puts "=" * 80
    
    assert_nothing_raised(FileStoreException) {
      open(@testFileSimple, 'w') do |f|
        f.write "lorem ipsum"
      end
      
      store = WebDAVStoreFactory::create 'files', 'owncloud.strawanzen.at', '/remote.php/webdav/', 80, 'demo', 'demo'
      puts "[TestWebDAVStore::test_upload] Trying to upload '#{@testFileSimple}' to remote store"
      file = store.add @testFileSimple
      
      store.shutdown
      
      puts "[TestWebDAVStore::test_upload] Added file '#{file}'"
    }
  end
  
  def test_05_get
    puts "=" * 80
    puts "TestWebDAVStore::test_get"
    puts "=" * 80
    
    remote_file = 'files/testfile.txt'
    
    assert_nothing_raised(FileStoreException) {
      store = WebDAVStoreFactory::create 'files', 'owncloud.strawanzen.at', '/remote.php/webdav/', 80, 'demo', 'demo'
      puts "[TestWebDAVStore::test_get] Trying to upload '#{remote_file}' to remote store"
      file = store.get remote_file
      
      store.shutdown
      
      puts "[TestWebDAVStore::test_upload] Got file '#{file}'"
    }
  end
  
  def test_06_remove
    puts "=" * 80
    puts "TestWebDAVStore::test_remove"
    puts "=" * 80
    
    remote_file = 'files/testfile.txt'
    
    assert_nothing_raised(FileStoreException) {
      store = WebDAVStoreFactory::create 'files', 'owncloud.strawanzen.at', '/remote.php/webdav/', 80, 'demo', 'demo'
      puts "[TestWebDAVStore::test_remove] Trying to delete '#{remote_file}' from remote store"
      store.remove remote_file
      
      store.shutdown
    }
  end
  
end