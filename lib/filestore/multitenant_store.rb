#
# multitenant_filestore.rb
#
# author: Thomas Stätter
# date: 2012/11/21
#
module FileStore
	#
	# Class implementing a multitenant file store
	#
	class MultiTenantFileStore
	  include Logger
		# Accessors
		attr_reader :rootPath
		attr_accessor :stores
		#
		# Initializes a new instance of MultiTenantFileStore
		#
		def initialize(root_path = ".", logger = StdoutLogger)
			@rootPath = root_path
			@stores = {}
			@logger = logger
		end
		#
		# Creates a new file store for a tenant
		#
		# Arguments:
		# 	id: The optional ID of the tenant. If omitted, an ID will be created
		#			automatically
		#
		# Returns:
		#	The tenants ID
		#
		def create_tenant_store(id = '')
			id = UUIDTools::UUID.random_create.to_s if id == '' or id.nil?
			
			begin
				path = File.join(@rootPath, id)
				FileUtils.mkdir path if not File.directory?(path)
				sfs = SimpleStoreFactory::create path, self.is_a?(ObservedSubject), @logger
			
				@stores[id] = sfs
				
				inform ObserverAction.new(:type => ObserverAction::TYPE_MSTORE_CREATE, 
          :msg => "Created new tenant store") if self.is_a?(ObservedSubject)
			rescue Exception => e
				raise FileStoreException, "Couldn't create multitenant store.\n#{e.message}"
			end
			
			return id
		end
		#
		# Permanently removes a tenant's store
		#
		# Arguments:
		# 	id: The tenant's ID
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
		#
		# Arguments:
		# 	id: The tenant's ID
		#
		# Returns:
		#	An instance of FileStore::SimpleFileStore
		#
		def get_tenant_store(id)
			raise FileStoreException, "Tenant #{id} not registered. No file store given." if not @stores.key?(id)
			
			return @stores[id]
		end
		#
		# Adds a file to the tenant's store
		#
		# Arguments:
		# 	tenant: The tenant's ID
		# 	file: The file to be added
		# 	md: Optional meta data
		#
		# Returns:
		#   The file ID
		#
		def add_to_tenant(tenant, file, md = {})
			raise FileStoreException, "Tenant #{tenant} not registered. File #{file} can't be added." if not @stores.key?(tenant)
			
			f_id = @stores[tenant].add(file, md)
			
			inform ObserverAction.new(:type => ObserverAction::TYPE_MSTORE_ADD, 
          :objects => [tenant, file, f_id], :msg => "Added file to tenant #{tenant} with ID #{f_id}") if self.is_a?(ObservedSubject)
          
      return f_id
		end
		#
		# Removes a file from the tenant's store
		#
		# Arguments:
		# 	tenant: The tenant's ID
		# 	id: The ID of the file to be removed
		#
		def remove_from_tenant(tenant, id)
			raise FileStoreException, "Tenant #{tenant} not registered. File with ID {id} can't be removed." if not @stores.key?(tenant)
			
			@stores[tenant].remove(id)
		end
		#
		# Retrieves a file from the tenant's store
		#
		# Arguments:
		# 	tenant: The tenant's ID
		# 	file: The file to be retrieved
		#
		# Returns:
		#	A hash containing the file object (:path) and the corresponding meta
		# 			data (:data)
		#
		def get_from_tenant(tenant, id)
			raise FileStoreException, "Given tenant #{tenant} isn't registered" if not @stores.key?(tenant)
			
			return @stores[tenant].get(id)
		end
		#
		# Determines wether a tenant is registered
		#
		# Arguments:
		# 	tenant: The tenant's ID to be tested
		#
		def has_tenant?(id)
			return @stores.key?(id)
		end
		#
		# Shuts down this multitenant store
		#
		def shutdown
			# Shut down any tenant store
			@stores.each do |id, store|
			  @logger.info "Shutting down file store for tenant #{id}"
				store.shutdown
			end
		end
		
		private
		
	end

end