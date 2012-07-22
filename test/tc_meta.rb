#!/usr/bin/env ruby
#
# tc_meta.rb
# @author Thomas Stätter
# @date 10.07.2012
# @description Unit test for classes in meta.rb
#

# execute test using: ruby -I ../lib/ tc_meta.rb

require "test/unit"
require "../lib/filestore.rb"

# Test cases for FileStore::MetaData
class TestMetaData < Test::Unit::TestCase
	def test_init
		# arguments 'key' and 'data' must be provided
		assert_raise(ArgumentError) { FileStore::MetaData.new }
		# argument 'key' must be of type String or Numeric
		assert_raise(FileStore::FileStoreException) { FileStore::MetaData.new({},{}) }
		assert_nothing_raised(FileStore::FileStoreException) { FileStore::MetaData.new('asdf',{}) }
		assert_nothing_raised(FileStore::FileStoreException) { FileStore::MetaData.new(234,{}) }
		# identifier may not be an empty string
		assert_raise(FileStore::FileStoreException) { FileStore::MetaData.new('',{}) }
		# data argument may not be nil
		assert_raise(FileStore::FileStoreException) { FileStore::MetaData.new('asdf',nil) }
	end
	
	def test_accessors
		# attr_readers for key and data may not return nil
		md = FileStore::MetaData.new(234,{})
		
		assert_not_nil(md.key, "Key can't be nil")
		assert_not_nil(md.data, "Key can't be nil")
	end
	
	def test_path
		md = FileStore::MetaData.new(234,{ FileStore::MetaData::FIELD_PATH => '/some/path' })
		# path may only return a string
		assert_instance_of(String, md.path, "Path can only be of type string")
		
		md = FileStore::MetaData.new(234,{})
		# path may be nil
		assert_nil(md.path, "Path is not given although it should be there")
	end
end

# Test cases for FileStore::MetaManager
class TestMetaManager < Test::Unit::TestCase
	def test_init
		# should raise a type error if no initialize code is given
		assert_raise(LocalJumpError) { FileStore::MetaManager.new }
		assert_nothing_raised(Exception) { FileStore::MetaManager.new {} }
	end
end

# Test cases for FileStore::MemoryMetaManager
class TestMemoryMetaManager < Test::Unit::TestCase
	def test_init
		# the init block may only return a not nil hash object 
		assert_raise(FileStore::FileStoreException){ FileStore::MemoryMetaManager.new {""} }
		assert_raise(FileStore::FileStoreException){ FileStore::MemoryMetaManager.new { } }
		assert_nothing_raised(FileStore::FileStoreException){ FileStore::MemoryMetaManager.new {{}} }
	end
	
	def test_add
		mm = FileStore::MemoryMetaManager.new {{}}
		
		assert_raise(FileStore::FileStoreException){ mm << nil }
		assert_raise(FileStore::FileStoreException){ mm << "asdfasdf" }
		assert_nothing_raised(FileStore::FileStoreException){ 
			md = FileStore::MetaData.new(234,{})
			mm << md
		}
	end
	
	def test_remove
		mm = FileStore::MemoryMetaManager.new {{}}
		
		assert_raise(FileStore::FileStoreException){ mm - nil }
		assert_nothing_raised(Exception){ 
			mm - "asdf"
			mm - 123123
			mm - []
			mm - {}
			mm - FileStore::MetaData.new(234,{})
		}
	end
	
	def test_read
		mm = FileStore::MemoryMetaManager.new {{}}
		
		assert_raise(FileStore::FileStoreException){ mm[nil] }
		assert_nothing_raised(Exception){ 
			mm[[]] 
			mm["asdf"]
			mm[2421]
		}
		assert_nil(mm[2343], "Nil wasn't returned although the given key wasn't existing")
	end
	
	def test_serialize
		mm = FileStore::MemoryMetaManager.new {{}}
		
		md = FileStore::MetaData.new(234,{})
		mm << md
		md2 = FileStore::MetaData.new("asdf",{})
		mm << md2
		
		assert_nothing_raised { FileStore::MemoryMetaManager.serialize(".", mm) }
		assert_raise(FileStore::FileStoreException) { FileStore::MemoryMetaManager.serialize("/some/invalid/path", mm) }
		assert_raise(FileStore::FileStoreException) { FileStore::MemoryMetaManager.serialize(".", {}) }
	end
	
	def test_deserialize
		assert_nothing_raised {
			mm = FileStore::MemoryMetaManager.deserialize(".")
			puts mm
			puts "deserialized data is of type #{mm.class.name}"
		}
	end
end