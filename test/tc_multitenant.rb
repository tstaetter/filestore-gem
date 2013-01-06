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

basePath = "#{Dir.getwd}/multi_store_test"
testFile = "#{Dir.getwd}/testfile.txt"

begin
	MultiTenantFileStore.instance.set_root_path basePath
	tenant = MultiTenantFileStore.instance.create_tenant_store
	MultiTenantFileStore.instance.add_to_tenant tenant, testFile, { :original_file => testFile }
	
	puts MultiTenantFileStore.instance.stores
	MultiTenantFileStore.instance.shutdown
rescue Exception => e
	puts e
	puts e.backtrace
end

FileUtils.touch testFile