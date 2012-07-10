#!/usr/bin/env ruby
#
# tc_log.rb
# @author Thomas Stätter
# @date 10.07.2012
# @description Unit test for classes in log.rb
#

# execute test using: ruby -I ../lib/ tc_log.rb

require "test/unit"
require "../lib/filestore.rb"

class TestLog < Test::Unit::TestCase
	
	def test_init
		# should be working, default path would be '.'
		assert_nothing_raised { FileStore::Log.new }
		# should raise an error, because the path is invalid
		assert_raise(FileStore::FileStoreException){ FileStore::Log.new('/some/invalid/path')  }
	end
	
	def test_log
		# shouldn't raise any error (but nothing will happen to the log)
		logger = FileStore::Log.new
		
		assert_nothing_raised { 
			logger << "asdf" 
			logger << 2343
			logger << []
			logger << FileStore::DeleteAction.new("asdf")
		}
	end
	
	def test_close
		logger = FileStore::Log.new
		
		assert_nothing_raised { logger.close }
	end
end