#
# multitenant_filestore.rb
# @author Thomas Stätter
# @date 22.07.2012
# @description Library using a file system as storage for arbitrary files
#

$:.unshift('.')

require 'filestore.rb'
require 'tenant.rb'

module FileStore

	class MultiTenantFileStore < FileStore
		META_TENANT = "tenant"
		
		def initialize(metaManager, tenantManager, basePath = ".")
			super(metaManager, basePath)
			
			raise FileStoreException, "No tenant manager given" if not tenantManager.is_a? TenantManager
			@tenantManager = tenantManager
		end
		
		def add_file(tenant, path)
			raise FileStoreException, "Given tenant is not registered" if not @tenantManager.tenant_exists?(tenant)
			
			id = ''
			
			if File.exists?(path) and File.readable?(path) then
				id = UUIDTools::UUID.random_create.to_s
				action = AddAction.new(id, "Origin: #{path}")
				
				action.execute {
					dstPath = move(File.join(@storePath,tenant.key), id, path)
					
					raise "Couldn't move file" if dstPath == ''
					
					@metaManager << MetaData.new(id, { MetaData::FIELD_PATH => dstPath, META_TENANT => tenant.key })
				}
				
				@logger << action
			else
				raise FileStoreException, "File is not readable"
			end
			
			id
		end
		
		def get_files_by_tenant(tenant)
			return @metaManager.get_metadata_by_field_and_value(META_TENANT, tenant.key)
		end
	end

end