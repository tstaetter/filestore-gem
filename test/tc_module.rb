#
# tc_module.rb
# @author Thomas Stätter
# @date 2014/01/05
#
require 'test/unit'
require './classes.rb'

class TestModule < Test::Unit::TestCase
    
  def test_inclusion
    puts "=" * 80
    puts "TestModule::test_inclusion"
    puts "=" * 80
    assert_nothing_raised(NameError) { ObserverAction }
    assert_nothing_raised(NameError) { OberservedSubject }
    assert_nothing_raised(NameError) { Observer }
    assert_nothing_raised(NameError) { SimpleFileStore }
    assert_nothing_raised(NameError) { MultiTenantFileStore }
    assert_nothing_raised(NameError) { MemoryMetaManager }
    assert_nothing_raised(NameError) { MetaManager }
    assert_nothing_raised(NameError) { FileStoreException }
  end
end