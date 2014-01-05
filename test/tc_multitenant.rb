#
# tc_multitenant.rb
#
# @author Thomas Stätter
# @date 2012/11/21
# @description Test script
#
require_relative '../module.rb'
require './classes.rb'
require 'test/unit'

include FileStore

class TestMultiTenantFileStore < FileStoreTest
  
  def test_registration_observer
    puts "=" * 80
    puts "TestMultiTenantFileStore::test_registration_observer"
    puts "=" * 80
    
    MultiTenantFileStore.instance.set_root_path @basePath
    MultiTenantFileStore.instance.logger = StdoutLogger
    tenant = MultiTenantFileStore.instance.create_tenant_store
    o1 = OtherObserverClass.new
    o2 = ObserverClass.new
    
    assert_nothing_raised(FileStoreException) {
      MultiTenantFileStore.instance.register o1
      MultiTenantFileStore.instance.register o2
    }
  end
  
  def test_actions_with_observer
    puts "=" * 80
    puts "TestMultiTenantFileStore::test_actions_with_observer"
    puts "=" * 80
    
    MultiTenantFileStore.instance.set_root_path @basePath
    MultiTenantFileStore.instance.logger = StdoutLogger
    o1 = OtherObserverClass.new
    o1.logger = StdoutLogger
    MultiTenantFileStore.instance.register o1
    
    assert_nothing_raised(FileStoreException) {
      tenant = MultiTenantFileStore.instance.create_tenant_store
      MultiTenantFileStore.instance.add_to_tenant tenant, 
        @testFile, { :original_file => @testFile }
    }
  end
  
end