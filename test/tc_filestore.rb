#!/usr/bin/env ruby
#
# tc_filestore.rb
# @author Thomas Stätter
# @date 10.07.2012
# @description Unit test for classes in filestore.rb
#
# execute test using: ruby -I ../lib/ tc_filestore.rb

require "test/unit"
require '../lib/filestore.rb'

class TestFileStore < Test::Unit::TestCase
	BASE_PATH = "./data"
	
	def test_init
		# should work
		assert_nothing_raised { FileStore::FileStore.new(BASE_PATH, FileStore::MemoryMetaManager.new {{}}) }
		# shouldn't work, invalid path
		assert_raise(FileStore::FileStoreException) { FileStore::FileStore.new("/some/invalid/path", FileStore::MemoryMetaManager.new {{}}) }
		assert_raise(FileStore::FileStoreException) { FileStore::FileStore.new("", FileStore::MemoryMetaManager.new {{}}) }
		assert_raise(FileStore::FileStoreException) { FileStore::FileStore.new(nil, FileStore::MemoryMetaManager.new {{}}) }
		# shouldn't work, invalid MetaManager
		assert_raise(FileStore::FileStoreException) { FileStore::FileStore.new(BASE_PATH, {}) }
		assert_raise(FileStore::FileStoreException) { FileStore::FileStore.new(BASE_PATH, nil) }
	end
	
	def test_add
		mm = FileStore::MemoryMetaManager.new {
			data = {}
			
			Dir.glob(File.join(BASE_PATH, "**", "*")).each { |f|
				if not File.directory?(f) and File.basename(f) != FileStore::Log::FILE then
					data[File.basename(f)] = File.absolute_path(f)
				end
			}
			
			data
		}
		fs = FileStore::FileStore.new(BASE_PATH, mm)
		id = fs << './move_from/test-file-to-move'
	
		assert_not_nil(id, "Returned ID can't be nil")	
		assert_not_same(id, '', "Returned ID can't be empty")
		assert_instance_of(String, id, "Weird ID returned: #{id}")
		# should raise an exception
		assert_raise(FileStore::FileStoreException) { fs << '/some/invalid/file' }
		
		# restore the test file
		`touch ./move_from/test-file-to-move`
	end
	
	def test_remove
		fs = FileStore::FileStore.new(BASE_PATH, FileStore::MemoryMetaManager.new {{}})
		
		# should raise an exception
		assert_raise(FileStore::FileStoreException) { fs - 'adsfasdf' }
	end
	
end