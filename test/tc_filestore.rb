#
# tc_filestore.rb
# @author Thomas Stätter
# @date 2012/11/14
# @description Test script
#
# call: ruby -I ../lib/ tc_filestore.rb
#
require_relative '../lib/filestore.rb'
require_relative '../lib/memory_meta.rb'

include FileStore

basePath = "/Users/thomas/Documents/DEV/ruby/FileStoreGEM/test/store_test"
testFile = "/Users/thomas/Documents/DEV/ruby/FileStoreGEM/test/testfile.txt"

begin
	mm = MemoryMetaManager.new(File.join(basePath, "meta.yaml"))
	sfs = SimpleFileStore.new(mm, basePath)
	id = sfs.add(testFile, {:hugo => 'boss'}, false)

	puts id
	puts "Enter something to finish"
	enter = gets 

	sfs.remove(id)
	sfs.shutdown
rescue Exception => e
	puts e
	sfs.shutdown if not sfs.nil?
end