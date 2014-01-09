#
# memory_meta.rb
#
# author: Thomas Stätter
# date: 2012/11/08
#
module FileStore
	#
	# Class implementing a memory based MetaManager
	#
	class MemoryMetaManager
	  include Logger

		# Constant defining the default file path
		FILE = 'meta.yaml'
		# Accessor for the file to store data to
		attr_reader :file
		#
		# Creates a new instance of MemoryMetaManager
		#
		# Arguments:
		# 	persistentFile: The file where the manager class is persisted to
		#   logger: The logging facility
		#
		def initialize(persistent_file = MemoryMetaManager::FILE, logger = StdoutLogger)
		  @logger = logger
			@data = Hash.new
			@removed = Hash.new
			@file = (persistent_file.nil? or persistent_file == '') ? MemoryMetaManager::FILE : persistent_file
			
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
			
			inform ObserverAction.new(:type => ObserverAction::TYPE_META_ADD, 
       :objects => [id, metaData], :msg => "Added/Updated file to meta store")  if self.is_a?(ObservedSubject)
		end
		#
		# see: MetaManager::remove
		#
		def remove(id)
			raise FileStoreException, "Only Strings can be used as keys" if not id.is_a?(String)
			raise FileStoreException, "ID #{id} not found in meta store" if not @data.key?(id)
			
			@removed[id] = @data[id]
			@data.delete(id)
			
			inform ObserverAction.new(:type => ObserverAction::TYPE_META_REMOVE, 
       :objects => [id], :msg => "Removed file to meta store") if self.is_a?(ObservedSubject)
		end
		#
		# see: MetaManager::restore
		#
		def restore(id)
			raise FileStoreException, "Only Strings can be used as keys" if not id.is_a?(String)
			raise FileStoreException, "ID #{id} not found in deleted meta store" if not @removed.key?(id)
			
			@data[id] = @removed[id]
			@removed.delete(id)
			
			inform ObserverAction.new(:type => ObserverAction::TYPE_META_RESTORE, 
       :objects => [id], :msg => "Restored file in meta store") if self.is_a?(ObservedSubject)
		end
		#
		# see: MetaManager::save
		#
		def save
		  begin
        @logger.info "Persisting meta store to #{@file}"
        
        File.open(@file, "wb+") do |fh|
          YAML.dump({:current => @data, :removed => @removed}, fh)
        end
                
        inform ObserverAction.new(:type => ObserverAction::TYPE_META_SHUTDOWN, 
          :msg => "Shut down meta manager") if self.is_a?(ObservedSubject)
      rescue Exception => e
        raise FileStoreException, "Couldn't persist meta manager to file #{@file}.\n#{e.message}"
      end
    end
    #
    # see: MetaManager::shutdown
    #
    def shutdown
      save
      
      @data = @removed = nil
    end
		#
		# see: MetaManager::has_id?
		#
		def has_id?(id)
			@data.key?(id)
		end
	end

end