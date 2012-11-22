#
# tc_multitenant.rb
# @author Thomas Stätter
# @date 2012/11/21
# @description Test script
#
# call: ruby -I ../lib/ tc_multitenant.rb
#
require_relative '../lib/multitenant_filestore.rb'
require 'fileutils'

include FileStore

basePath = "/Users/thomas/Documents/DEV/ruby/FileStoreGEM/test/multi_store_test"
testFile = "/Users/thomas/Documents/DEV/ruby/FileStoreGEM/test/testfile.txt"

begin
	mtfs = MultiTenantFileStore.new basePath
	tenant = mtfs.create_tenant_store
	mtfs.add_to_tenant tenant, testFile, { :hugo => "boss" }
	
	puts mtfs.stores
	mtfs.shutdown
rescue Exception => e
	puts e
	puts e.backtrace
end

FileUtils.touch testFile