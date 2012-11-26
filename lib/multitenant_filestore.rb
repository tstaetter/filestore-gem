#
# multitenant_filestore.rb
# @author Thomas Stätter
# @date 2012/11/21
# @description
#

require 'filestore.rb'
require 'memory_meta.rb'
require 'log.rb'
require 'uuidtools'
require 'fileutils'
require 'yaml'
require 'singleton'

module FileStore
	#
	# Singleton class implementing a multitenant file store
	#
	class MultiTenantFileStore
		# Make this class a singleton class
		include Singleton
		# Accessors
		attr_reader :stores, :rootPath
		#
		# Initializes a new instance of MultiTenantFileStore
		#
		def initialize()
			@rootPath = Dir.getwd
			@stores = {}
		end
		#
		# Sets the root path of the multitenant store. As FileStore::MultiTenantFileStore
		# is a singleton class, this method must be used before any other
		# @param rootPath The path to be used
		#
		def set_root_path(rootPath)
			raise FileStoreException, "Root path #{rootPath} doesn't exist" if not File.exists?(rootPath)
			
			@rootPath = rootPath
			@stores = MultiTenantFileStore.recover(rootPath)
		end
		#
		# Creates a new file store for a tenant
		# @param id The optional ID of the tenant. If omitted, an ID will be created
		#			automatically
		# @returns The tenants ID
		#
		def create_tenant_store(id = '')
			id = UUIDTools::UUID.random_create.to_s if id == '' or id.nil?
			
			begin
				path = File.join(@rootPath, id)
				FileUtils.mkdir path
				mm = MemoryMetaManager.new(File.join(path, "meta.yaml"))
				sfs = SimpleFileStore.new(mm, path)
			
				@stores[id] = sfs
			rescue Exception => e
				raise FileStoreException, "Couldn't create multitenant store.\n#{e.message}"
			end
			
			return id
		end
		#
		# Permanently removes a tenant's store
		# @param id The tenant's ID
		#
		def remove_tenant_store(id)
			raise FileStoreException, "Tenant #{id} can't be removed. Not registered." if not @stores.key?(id)
			
			begin
				@stores.delete(id)
				FileUtils.remove_dir File.join(@rootPath, id)
			rescue Exception => e
				raise FileStoreException, "Couldn't delete tenant #{id}.\n#{e.message}"
			end
		end
		#
		# Returns the complete file store for a given tenant
		# @param id The tenant's id
		# @returns An instance of FileStore::SimpleFileStore
		#
		def get_tenant_store(id)
			raise FileStoreException, "Tenant #{id} not registered. No file store given." if not @stores.key?(id)
			
			return @stores[id]
		end
		#
		# Adds a file to the tenant's store
		# @param tenant The tenant's ID
		# @param file The file to be added
		# @param md Optional meta data
		#
		def add_to_tenant(tenant, file, md = {})
			raise FileStoreException, "Tenant #{id} not registered. File can't be added." if not @stores.key?(tenant)
			
			@stores[tenant].add(file, md)
		end
		#
		# Removes a file from the tenant's store
		# @param tenant The tenant's ID
		# @param id The ID of the file to be removed
		#
		def remove_from_tenant(tenant, id)
			raise FileStoreException, "Tenant #{id} not registered. File can't be removed." if not @stores.key?(tenant)
			
			@stores[tenant].remove(id)
		end
		#
		# Retrieves a file from the tenant's store
		# @param tenant The tenant's ID
		# @param id The file's ID
		# @returns A hash containing the file object (:path) and the corresponding meta
		# 			data (:data)
		#
		def get_from_tenant(tenant, id)
			raise FileStoreException, "Given tenant #{tenant} isn't registered" if not @stores.key?(tenant)
			
			return @stores[tenant].get(id)
		end
		#
		# Determines wether a tenant is registered
		# @param id The ID of the tenant to be tested
		#
		def has_tenant?(id)
		end
		#
		# Shuts down this multitenant store
		#
		def shutdown
			# Shut down any tenant store
			@stores.values.each do |s|
				s.shutdown
			end
		end
		
		private
		#
		# Recovers a multitenant store
		# @param rootPath The base path of the multitenant store
		#
		def self.recover(rootPath)
			raise FileStoreException, "Root path #{rootPath} isn't a valid multitenant store" if not File.directory?(rootPath)
			
			stores = {}
			
			Dir.glob(File.join(rootPath, "*")).each { |e|
				begin
					if File.directory?(e)
						tenant = File.basename(e)
						mm = MemoryMetaManager.new(File.join(e, "meta.yaml"))
						sfs = SimpleFileStore.new(mm, e)
				
						stores[tenant] = sfs
					end
				rescue Exception => e
					Logger.instance.logger.error "Couldn't create store for tenant #{tenant}.\n#{e.message}"
				end
			}
			
			return stores
		end
	end

end