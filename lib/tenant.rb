#
# tenant.rb
# @author Thomas Stätter
# @date 22.07.2012
# @description Library using a file system as storage for arbitrary files
#

$:.unshift('.')

require 'yaml'
require 'filestore.rb'

module FileStore
	
	class Tenant
		TAG_NAME	=	"name"
		
		attr_reader :key
		
		def initialize(key = '', tenantData = {})
			(key == '' or key.nil?) ? 
				@key = UUIDTools::UUID.random_create.to_s :
				@key = key.to_s
			
			@tenantData = tenantData
		end
		
		def add_tag(tag, data)
			raise FileStore::FileStoreException, "Arguments 'tag' and 'data' must be provided" if (tag.nil? or data.nil?)
			
			@tenantData[tag] = data
		end
		
		def modify_tag(tag, data)
			raise FileStore::FileStoreException, "Arguments 'tag' and 'data' must be provided" if (tag.nil? or data.nil?)
			raise FileStore::FileStoreException, "Given tag is not registered" if not @tenantData.has_key?(tag)
			
			@tenantData[tag] = data
		end
		
		def remove_tag(tag)
			raise FileStore::FileStoreException, "Given tag is either nil or invalid" if (tag.nil? or 
				not @tenantData.has_key?(tag))
			
			@tenantData.delete tag
		end
		
		def has_tag_value(tag, value)
			return @tenantData[tag].equals value
		end
	end
	
	class TenantManager
		TENANTS_FILE = "tenants.yaml"
		
		attr_reader :basePath
		
		def self.serialize(tm)
			path = ''
			
			begin
				path = File.join(tm.basePath, TENANTS_FILE)
				puts path
				
				File.open(path, 'w+') do |f|
    				YAML.dump(tm, f)
    			end
			rescue Exception => e
				raise FileStoreException, "Couldn't serialize tenant data to file #{path}", e.backtrace
			end
		end
		
		def self.deserialize(path_from)
			tm = nil
			path = File.join(path_from, TENANTS_FILE)
			
			begin
				tm = YAML.load_file(path)
				
				raise FileStoreException, "Given file is invalid" if not tm.is_a?(TenantManager)
			rescue Exception => e
				raise FileStoreException, "Couldn't load tenant data from #{path}", e.backtrace
			ensure
				return tm
			end
		end
		
		def self.load_manager(path_from)
			path = File.join(path_from, TENANTS_FILE)
			
			tm = (File.exists?(path) and File.readable?(path)) ? 
				TenantManager.deserialize(path_from) : 
				TenantManager.new(path_from)
				
			return tm
		end
		
		def initialize(basePath = ".")
			@basePath = basePath
			@tenants = {}
		end
		
		#
		# Registers a new tenant
		#
		def <<(tenant)
			raise FileStore::FileStoreException, "Given object is not a valid tenant" if not tenant.is_a?(Tenant)
			
			@tenants[tenant.key] = tenant
		end
		
		#
		# Removes the given tenant
		#
		def -(tenant)
			raise FileStore::FileStoreException, "Given tenant is invalid" if (tenant.nil? or 
				not tenant.is_a?(Tenant))
			
			@tenants.remove tenant.key
		end
		
		def register_if_exists(tenant)
			if not tenant_exists?(tenant) then self << tenant end
		end
		
		def unregister_if_exists(tenant)
			if tenant_exists?(tenant) then self - tenant end
		end
		
		def tenant_exists?(tenant)
			raise FileStore::FileStoreException, "Given object is not a valid tenant" if (tenant.nil? or 
				not tenant.is_a?(Tenant))
				
			@tenants.has_key? tenant.key
		end
		#
		# Returns a tenant identified by the given tag and corresponding value or nil if 
		# not found
		#
		def find_tenant_by_tag(tag, value)
			found = nil
			
			@tenants.each_value { |t| 
				(found = t; break) if t.has_tag_value(tag, value)
			}
			
			return found
		end
		
		def get_tenant_by_key(key)
			return @tenants[key]
		end
	end

end