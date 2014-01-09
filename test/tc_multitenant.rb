#
# tc_multitenant.rb
#
# @author Thomas Stätter
# @date 2012/11/21
# @description Test script
#
require './classes.rb'
require 'test/unit'

include FileStore

class TestMultiTenantFileStore < FileStoreTest
  
  def test_init_shutdown
    puts "=" * 80
    puts "TestMultiTenantFileStore::test_init"
    puts "=" * 80
    
    assert_nothing_raised(FileStoreException) {
      MultiTenantStoreFactory::create @basePathMulti
    }
    assert_not_nil(MultiTenantStoreFactory::create @basePathMulti)
    assert(MultiTenantStoreFactory::create(@basePathMulti).is_a?(MultiTenantFileStore))
    assert_nothing_raised(FileStoreException) {
      m_store = MultiTenantStoreFactory::create @basePathMulti
      
      m_store.shutdown
    }
  end
  
  def test_observer_registration
    puts "=" * 80
    puts "TestMultiTenantFileStore::test_observer_registration"
    puts "=" * 80
    
    assert_nothing_raised(Exception) {
      o1 = ObserverClass.new
      o1.logger = StdoutLogger
      m_store = MultiTenantStoreFactory::create @basePathMulti, true
      
      m_store.register o1
      m_store.inform "Some test message"
      m_store.shutdown
    }
  end

  def test_actions_with_observer
    puts "=" * 80
    puts "TestMultiTenantFileStore::test_actions_with_observer"
    puts "=" * 80
    
    o1 = OtherObserverClass.new
    o1.logger = StdoutLogger

    m_store = MultiTenantStoreFactory::create @basePathMulti, true
    m_store.register o1
    
    assert_nothing_raised(FileStoreException) {
      tenant_id = m_store.create_tenant_store @uid
      f_id = m_store.add_to_tenant tenant_id, 
        @testFileMulti, { :original_file => @testFileMulti }
      m_store.remove_from_tenant tenant_id, f_id
      m_store.shutdown
    }
  end
  
end