#
# filestore.rb
#
# author: Thomas Stätter
# date: 2012/11/07
#
require "../module.rb"

include FileStore

module FileStore
	#
	# Base exception class used for errors occurring in this module
	#
	class FileStoreException < Exception
	end
	#
	# Main library class implementing a simple file store used for storing and managing 
	# arbitrary files
	#
	class SimpleFileStore
	  include Logger
	  include OberservedSubject
	  
		# Name of the lock file
		STORE_LOCK_FILE = ".locked"
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
		attr_reader :metaManager, :rootPath, :storePath, :deletedPath, :rollbackPath, :metaFile
		#
		# Initializes a new instance of SimpleFileStore
		#
		# Arguments:
		# 	metaManager: The meta data manager instance to be used by this store
		# 	rootPath: The path where the file store resides
		#
		def initialize(metaManager, rootPath = '.', logger)
			raise FileStoreException, "Root path already locked" if SimpleFileStore.is_directory_locked?(rootPath)		
			raise FileStoreException, "FileStore root path #{rootPath} doesn't exist" if not File.directory?(rootPath)
			raise FileStoreException, "FileStore root path #{rootPath} isn't writable" if not File.writable?(rootPath)
			raise FileStoreException, "No meta data manager given" if metaManager.nil?
			raise FileStoreException, "Meta data manager must be of type FileStore::MetaManager" if not metaManager.is_a?(MetaManager)
			
			@metaManager = metaManager
			@rootPath = rootPath
			@storePath = File.join(@rootPath, STORE_ROOT)
			@deletedPath = File.join(@rootPath, DELETED_ROOT)
			@rollbackPath = File.join(@rootPath, ROLLBACK_ROOT)
			@metaFile = File.join(@rootPath, META_FILE)
			@locked = false
			@logger = logger
			
			self.initialize_obs
			
			begin
				# Try to recover existing store
				SimpleFileStore.recover_store(self)
			rescue FileStoreException => e
				# Recovery failed, trying to create the store
				SimpleFileStore.create_store(self)
			end
			
			lock
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
				dir = SimpleFileStore.get_daily_directory(@storePath)
				@logger.info "Adding file #{file} to directory #{dir}"
				id = SimpleFileStore.get_id(self)
				@logger.info "Using file id #{id}"
				dstPath = File.join(dir, id)
				@logger.info "Created destination path #{dstPath}"
				
				shouldMove ? (@logger.info("Moving file"); FileUtils.mv(file, dstPath)) : 
					(@logger.info("Copying file"); FileUtils.copy_file(file, dstPath))
				
				self.inform ObserverAction.new(:type => ObserverAction::TYPE_STORE_ADD, 
          :objects => [file, meta], :msg => "Added file to file store")
			rescue Exception => e
				raise FileStoreException, "Couldn't add file #{file} to store.", e.backtrace
			end
			
			meta[:path] = dstPath
			@metaManager.add_or_update(id, meta)
			
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
			raise FileStoreException, "No file for ID #{id} found" if not @metaManager.has_id?(id)
			
			md = @metaManager.get_data(id)
			path = md[:path]

			raise FileStoreException, "No valid meta data found for ID #{id}" if md.nil? or not File.exists?(path)
			
			self.inform ObserverAction.new :type => ObserverAction::TYPE_STORE_GET, 
        :objects => [id], :msg => "Returning file from file store"
			
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
			raise FileStoreException, "File ID for removal not found in store" if not @metaManager.has_id?(id)
			
			file = @metaManager.get_data(id)[:path]
			
			begin
				@metaManager.remove(id)
				
				dir = SimpleFileStore.get_daily_directory(@deletedPath)
				dstPath = File.join(dir, id)
				
				FileUtils.move(file, dstPath)
				
				self.inform ObserverAction.new :type => ObserverAction::TYPE_STORE_REMOVE, 
          :objects => [id], :msg => "Deleted file from store"
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
			  md = @metaManager.restore id
        @logger.debug "Restoring meta data #{md}"
        file = md[:path]
        
				dir = SimpleFileStore.get_daily_directory(@storePath)
				dstPath = File.join(dir, id)
				
				FileUtils.move(file, dstPath)
				
				self.inform ObserverAction.new :type => ObserverAction::TYPE_STORE_RESTORE, 
          :objects => [id], :msg => "Restored file from store"
			rescue Exception => e
				raise FileStoreException, "Couldn't restore file #{file} from deleted store.\n#{e.message}"
				#
				# Delete restored entry from metaManager
				@metaManager.delete(id)
			end
		end
		#
		# Shuts down the file store
		#
		def shutdown
			@metaManager.shutdown
			
			release_lock
			
			self.inform ObserverAction.new :type => ObserverAction::TYPE_STORE_SHUTDOWN, 
        :msg => "File store shutdown"
		end
		#
		# Determines wether this store is locked
		#
		def locked?
			return @locked
		end
		
		private
		
		#
		# Release the lock from the store
		#
		def release_lock
			begin
				File.delete File.join(@rootPath, STORE_LOCK_FILE)
				@locked = false
			rescue Exception => e
				raise FileStoreException, "Couldn't release lock from #{@storePath}.\n#{e.message}"
			end
		end
		#
		# Locks the current instance of file store as well as the corresponding path on
		# the file system using a hidden file
		#
		def lock
			begin
				FileUtils.touch File.join(@rootPath, STORE_LOCK_FILE)
				@locked = true
			rescue Exception => e
				raise FileStoreException, "Couldn't lock the store in path #{@storePath}.\n#{e.message}"
			end
		end
		#
		# Determines wether the store path is already locked by another instance
		# of SimpleFileStore
		#
		def self.is_directory_locked?(rootPath)
			return File.exists?(File.join(rootPath, SimpleFileStore::STORE_LOCK_FILE))
		end
		#
		# Creates a new file ID
		#
		# Returns:
		# 	A string representing the file's ID
		#
		def self.get_id(store)
			for i in 0..2 do	
				id = UUIDTools::UUID.random_create.to_s
				
				return id if not store.metaManager.has_id?(id) 
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
		#
		# Setup for a new file store directory
		#
		# Arguments:
		# 	store: The file store instance to set up
		#
		def self.create_store(store)
			# Try to create needed directories
			begin
				FileUtils.mkdir [store.storePath, store.deletedPath, store.rollbackPath]
			rescue Errno::ENOENT => e
				raise FileStoreException, "One ore more system directories couldn't be created.\n#{e.message}"
			end
			# Try to create hidden meta file
			begin
				meta = { :created_at => Date.today.strftime('%d.%m.%Y %H:%M:%S:%L'), 
					:storePath => store.storePath,
					:deletedPath => store.deletedPath,
					:rollbackPath => store.rollbackPath,
					:created_by => Etc.getlogin
				}
				
				File.open(store.metaFile, "w+") do |fh|
					YAML.dump(meta, fh)
				end
				
				#
				# Creation was successful
				#
			rescue Exception => e
				raise FileStoreException, "Meta file #{store.metaFile} couldn't be created.\n#{e.message}"
			end
		end
		#
		# Recover an existing file store
		#
		# Arguments:
		# 	store: The file store instance to recover
		#
		def self.recover_store(store)
			# trying to recover existing file store
			begin
				meta = YAML.load_file(store.metaFile)
				
				raise FileStoreException, "Store directory not found" if not File.directory?(meta[:storePath])
				raise FileStoreException, "Deleted directory not found" if not File.directory?(meta[:deletedPath])
				raise FileStoreException, "Rollback directory not found" if not File.directory?(meta[:rollbackPath])
				
				#
				# Recovery was successful
				#
			rescue Exception => e
				raise FileStoreException, "Unable to recover file store from path #{store.rootPath}.\n#{e.message}"
			end
		end
		
	end

end