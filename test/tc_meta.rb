#
# tc_meta.rb
# @author Thomas Stätter
# @date 2014/01/05
#
require './classes.rb'
require 'test/unit'

include FileStore

class TestMetaManager < FileStoreTest
    
  def test_init_shutdown
    puts "=" * 80
    puts "TestMetaManager::test_init_shutdown"
    puts "=" * 80
    
    assert_nothing_raised(FileStoreException) {
      mm = MemoryMetaFactory::create File.join(@basePathSimple, MemoryMetaManager::FILE)
    }
    assert_not_nil(MemoryMetaFactory::create File.join(@basePathSimple, MemoryMetaManager::FILE))
    assert_nothing_raised(FileStoreException) {
      mm = MemoryMetaFactory::create File.join(@basePathSimple, MemoryMetaManager::FILE)
      
      mm.shutdown
    }
  end
  
  def test_registration_observer
    puts "=" * 80
    puts "TestMetaManager::test_registration_observer"
    puts "=" * 80
    
    o1 = ObserverClass.new
    o2 = OtherObserverClass.new
    
    o1.logger = StdoutLogger
    o2.logger = StdoutLogger
    
    mm = MemoryMetaFactory::create File.join(@basePathSimple, MemoryMetaManager::FILE), true
    
    assert_nothing_raised(FileStoreException) {
      mm.register o1
      mm.register o2
    }
    assert_raise(FileStoreException) { mm.register "" }
    assert_nothing_raised(FileStoreException) {
      mm.unregister(o1)
      mm.unregister(o2)
    }
  end
   
  def test_actions_with_observer
    puts "=" * 80
    puts "TestMetaManager::test_actions_with_observer"
    puts "=" * 80
    
    o1 = ObserverClass.new    
    o1.logger = StdoutLogger
    mm = MemoryMetaFactory::create File.join(@basePathSimple, MemoryMetaManager::FILE), true
    
    mm.register o1
    
    assert_nothing_raised(FileStoreException) { mm.add_or_update "1", {} }
    assert_nothing_raised(FileStoreException) { mm.add_or_update "1", {} }
    assert_nothing_raised(FileStoreException) { mm.remove "1" }
    assert_nothing_raised(FileStoreException) { mm.restore "1" }
    assert_nothing_raised(FileStoreException) { mm.shutdown }
  end
  
end