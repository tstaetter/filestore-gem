#!/usr/bin/env ruby
#
# tc_action.rb
# @author Thomas Stätter
# @date 10.07.2012
# @description Unit test for classes in meta.rb
#

# execute test using: ruby -I ../lib/ tc_action.rb

require "test/unit"
require "../lib/filestore.rb"

class TestAction < Test::Unit::TestCase

	def test_init
		# initialization of an instance of FileStore::Action should raise an
		# exception if no identifier is given or the identifier is not a string or
		# numeric
		assert_raise(FileStore::FileStoreException, ArgumentError) { FileStore::Action.new }
		assert_raise(FileStore::FileStoreException, ArgumentError) { FileStore::Action.new(nil) }
		assert_raise(FileStore::FileStoreException, ArgumentError) { FileStore::Action.new([]) }
		# identifier can't be an empty string if it's a String
		assert_raise(FileStore::FileStoreException) { FileStore::Action.new('') }
		assert_nothing_raised(Exception) { FileStore::Action.new("asdf") }
		assert_nothing_raised(Exception) { FileStore::Action.new(213123) }
	end
	
	def test_execute
		# execution should fail if no block is given
		assert_raise(TypeError, FileStore::FileStoreException) {
			action = FileStore::Action.new("asdf")
			action.execute
		}
	end
	
	def test_string
		# execution shouldn't fail in any case
		assert_nothing_raised(Exception) { FileStore::Action.new("asdf").to_s }
		assert_nothing_raised(Exception) { FileStore::Action.new(123).to_s }
		assert_nothing_raised(Exception) { 
			action = FileStore::Action.new("asdf")
			action.execute {}
			action.to_s
		}
	end

end