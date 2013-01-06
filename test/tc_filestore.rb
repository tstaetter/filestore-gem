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

basePath = "#{Dir.getwd}/store_test"
testFile = $*[0]

begin
	puts "Using file: #{testFile}"
	mm = MemoryMetaManager.new(File.join(basePath, "meta.yaml"))
	sfs = SimpleFileStore.new(mm, basePath)
	id = sfs.add(testFile, {:original_file => testFile}, false)

	puts id
	puts "Enter something to finish"
	enter = gets 

	sfs.remove(id)
rescue Exception => e
	puts e
ensure
	sfs.shutdown if not sfs.nil?
end