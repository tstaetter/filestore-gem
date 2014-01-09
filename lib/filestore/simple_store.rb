#
# filestore.rb
#
# author: Thomas Stätter
# date: 2012/11/07
#
module FileStore
	#
	# Main library class implementing a simple file store used for storing and managing 
	# arbitrary files
	#
	class SimpleFileStore
	  include Logger
	  
		# Name of the meta file describing the current file store
		META_FILE = "filestore.yaml"
		# The base name of the file store directory
		STORE_ROOT = 'filestore'
		# The base name of the directory for storing deleted files
		DELETED_ROOT = 'deleted'
		# The base name of the directory storing files extracted from file store by a 
		# rollback action 
		ROLLBACK_ROOT = 'rollback'
		#
		# Accessors for important properties
		#
		attr_accessor :meta_manager
		attr_reader :root_path, :store_path, :deleted_path, :meta_file
		#
		# Rollback path will be used in future versions
		#
		attr_reader :rollback_path
		#
		# Initializes a new instance of SimpleFileStore
		#
		# Arguments:
		# 	root_path: The path where the file store resides
		#   logger: The logging facility
		#
		def initialize(root_path, logger = StdoutLogger)
			raise FileStoreException, "FileStore root path #{root_path} doesn't exist" if not File.directory?(root_path)
			raise FileStoreException, "FileStore root path #{root_path} isn't writable" if not File.writable?(root_path)
			
			@root_path = root_path
      @store_path = File.join(@root_path, STORE_ROOT)
      @deleted_path = File.join(@root_path, DELETED_ROOT)
      @rollback_path = File.join(@root_path, ROLLBACK_ROOT)
      @meta_file = File.join(@root_path, SimpleFileStore::META_FILE)
		end
		#
		# Adds a file to the store
		#
		# Arguments:
		# 	file: The file to be stored
		# 	meta: Optional meta data to be stored along with the physical file
		# 	shouldMove: Determines wether to original file should be deleted
		#
		# Returns:
		#	  The newly created ID for the file
		#
		def add(file, meta = {}, shouldMove = true)
			raise FileStoreException, "File #{file} not found" if not File.exists?(file)
			raise FileStoreException, "File #{file} isn't readable" if not File.readable?(file)
			raise FileStoreException, "File #{file} can't be removed" if not File.writable?(file)
			
			meta = {} if meta.nil?
			id = ""
			
			begin
				dir = SimpleFileStore.get_daily_directory(@store_path)
				@logger.info "Adding file #{file} to directory #{dir}"
				id = SimpleFileStore.get_id(self)
				@logger.info "Using file id #{id}"
				dstPath = File.join(dir, id)
				@logger.info "Created destination path #{dstPath}"
				
				shouldMove ? (@logger.info("Moving file"); FileUtils.mv(file, dstPath)) : 
					(@logger.info("Copying file"); FileUtils.copy_file(file, dstPath))
				
				inform ObserverAction.new(:type => ObserverAction::TYPE_STORE_ADD, 
          :objects => { :file => file, :meta => meta }, :msg => "Added file to file store") if self.is_a?(ObservedSubject)
			rescue Exception => e
				raise FileStoreException, "Couldn't add file #{file} to store.", e.backtrace
			end
			
			meta[:path] = dstPath
			@meta_manager.add_or_update(id, meta)
			
			return id
		end
		#
		# Retrieves a file identified by it's ID
		#
		# Arguments:
		# 	id: The files ID to retrieve
		#
		# Returns: 
		#	A hash of file object (:path) and corresponding meta data (:data)
		#			representing the file in the store
		#
		def get(id)
			raise FileStoreException, "No ID given" if id.nil? or id == ''
			raise FileStoreException, "No file for ID #{id} found" if not @meta_manager.has_id?(id)
			
			md = @meta_manager.get_data(id)
			path = md[:path]

			raise FileStoreException, "No valid meta data found for ID #{id}" if md.nil? or not File.exists?(path)
			
			inform ObserverAction.new(:type => ObserverAction::TYPE_STORE_GET, 
        :objects => [id], :msg => "Returning file from file store")  if self.is_a?(ObservedSubject)
			
			return { :path => File.new(path), :data => md }
		end
		#
		# Moves a file from the current to the deleted store
		#
		# Arguments:
		# 	id: The ID identifying the file to be moved
		#
		def remove(id)
			raise FileStoreException, "No file ID given for removal" if id == '' or id.nil?
			raise FileStoreException, "File ID for removal not found in store" if not @meta_manager.has_id?(id)
			
			file = @meta_manager.get_data(id)[:path]
			
			begin
				@meta_manager.remove(id)
				
				dir = SimpleFileStore.get_daily_directory(@deleted_path)
				dstPath = File.join(dir, id)
				
				FileUtils.move(file, dstPath)
				
				inform ObserverAction.new(:type => ObserverAction::TYPE_STORE_REMOVE, 
          :objects => [id], :msg => "Deleted file from store") if self.is_a?(ObservedSubject)
			rescue Exception => e
				raise FileStoreException, "Couldn't move file #{file} to deleted store.\n#{e.message}"
			end
		end
		#
		# Restores a file identified by it's id
		#
		# Arguments:
		# 	id: The file ID
		#
		def restore(id)
			raise FileStoreException, "No file ID given for restore" if id == '' or id.nil?
			
			begin
			  md = @meta_manager.restore id
        @logger.debug "Restoring meta data #{md}"
        file = md[:path]
        
				dir = SimpleFileStore.get_daily_directory(@store_path)
				dstPath = File.join(dir, id)
				
				FileUtils.move(file, dstPath)
				
				inform ObserverAction.new(:type => ObserverAction::TYPE_STORE_RESTORE, 
          :objects => [id], :msg => "Restored file from store") if self.is_a?(ObservedSubject)
			rescue Exception => e
				raise FileStoreException, "Couldn't restore file #{file} from deleted store.\n#{e.message}"
				#
				# Delete restored entry from metaManager
				#
				@meta_manager.delete(id)
			end
		end
		#
		# Shuts down the file store
		#
		def shutdown
			@meta_manager.shutdown
			
			inform ObserverAction.new(:type => ObserverAction::TYPE_STORE_SHUTDOWN, 
        :msg => "File store shutdown")  if self.is_a?(ObservedSubject)
		end
		
		private
		#
		# Creates a new file ID
		#
		# Returns:
		# 	A string representing the file's ID
		#
		def self.get_id(store)
			for i in 0..2 do	
				id = UUIDTools::UUID.random_create.to_s
				
				return id if not store.meta_manager.has_id?(id) 
			end
			
			raise FileStoreException, "Couldn't find unique ID"
		end
		#
		# Returns the currently used directory
		#
		def self.get_daily_directory(base)
			date = Date.today
			dir = File.join(base, date.year.to_s, date.month.to_s, date.day.to_s)
			
			begin
				FileUtils.mkdir_p(dir) if not File.directory?(dir)
			rescue Exception => e
				raise FileStoreException, "Can't create daily directory #{dir}.\n#{e.message}"
			end
			
			raise FileStoreException, "Daily directory #{dir} isn't writable" if not File.writable?(dir)
			return dir
		end
		
	end

end