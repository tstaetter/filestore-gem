#
# memory_meta.rb
#
# author: Thomas Stätter
# date: 2012/11/08
#
require "../module.rb"

module FileStore
	#
	# Class implementing a memory based MetaManager
	#
	class MemoryMetaManager < MetaManager
	  include Logger
	  include OberservedSubject
	  
		# Constant defining the default file path
		FILE = 'meta.yaml'
		# Accessor for the file to store data to
		attr_reader :file
		#
		# Creates a new instance of MemoryMetaManager
		#
		# Arguments:
		# 	persistentFile: The file where the manager class is persisted to
		#
		def initialize(persistentFile = '', logger)
		  @logger = logger
			@data = Hash.new
			@removed = Hash.new
			@file = (persistentFile.nil? or persistentFile == '')? MemoryMetaManager::FILE : persistentFile
			
			self.initialize_obs
			
			begin
				if File.exists?(@file)
					@logger.info "loading meta yaml from #{@file}"
					@mm = YAML.load_file(@file) if File.exists?(@file)
					@logger.info "Loaded meta yaml: #{@mm}"
					@data = @mm[:current]
					@removed = @mm[:removed]
				else
					@logger.info "Creating new meta store in #{@file}"
				end
			rescue Exception => e
				raise FileStoreException, "Couldn't load meta data from file #{@file}.\nCause: #{e}"				
			end
				
		end
		#
		# see: MetaManager::get_data
		#
		def get_data(id)
			raise FileStoreException, "No meta data available for ID #{id}" if not @data.key?(id)
			
			return @data[id]
		end
		#
		# see: MetaManager::add_or_update
		#
		def add_or_update(id, metaData)
			raise FileStoreException, "Only hashsets can be added" if not metaData.is_a?(Hash)
			raise FileStoreException, "Only Strings can be used as keys" if not id.is_a?(String)
			
			@data[id] = (@data.key?(id) ? @data[id].merge!(metaData) : @data[id] = metaData)
			
			self.inform ObserverAction.new(:type => ObserverAction::TYPE_META_ADD, 
       :objects => [id, metaData], :msg => "Added/Updated file to meta store")
		end
		#
		# see: MetaManager::remove
		#
		def remove(id)
			raise FileStoreException, "Only Strings can be used as keys" if not id.is_a?(String)
			raise FileStoreException, "ID #{id} not found in meta store" if not @data.key?(id)
			
			@removed[id] = @data[id]
			@data.delete(id)
			
			self.inform ObserverAction.new(:type => ObserverAction::TYPE_META_REMOVE, 
       :objects => [id], :msg => "Removed file to meta store")
		end
		#
		# see: MetaManager::restore
		#
		def restore(id)
			raise FileStoreException, "Only Strings can be used as keys" if not id.is_a?(String)
			raise FileStoreException, "ID #{id} not found in deleted meta store" if not @removed.key?(id)
			
			@data[id] = @removed[id]
			@removed.delete(id)
			
			self.inform ObserverAction.new(:type => ObserverAction::TYPE_META_RESTORE, 
       :objects => [id], :msg => "Restored file in meta store")
		end
		#
		# see: MetaManager::shutdown
		#
		def shutdown
			begin
				File.open(@file, "wb+") do |fh|
					YAML.dump({:current => @data, :removed => @removed}, fh)
				end
				
				@data = nil
				
				self.inform ObserverAction.new(:type => ObserverAction::TYPE_META_SHUTDOWN, 
          :msg => "Restored file in meta store")
			rescue Exception => e
				raise FileStoreException, "Couldn't serialize meta manager to file #{@file}.\n#{e.message}"
			end
		end
		#
		# see: MetaManager::has_id?
		#
		def has_id?(id)
			@data.key?(id)
		end
	end

end