#
# memory_meta.rb
# @author Thomas Stätter
# @date 2012/11/08
# @description
#
require 'yaml'
require 'filestore.rb'
require 'meta_manager.rb'
require 'log.rb'

module FileStore
	#
	# Class implementing a memory based MetaManager
	#
	class MemoryMetaManager < MetaManager
		# Constant defining the default file path
		@@FILE = './meta.yaml'
		# Accessor for the file to store data to
		attr_reader :file
		#
		# Creates a new instance of MemoryMetaManager
		# @param persistentFile The file where the manager class is persisted to
		#
		def initialize(persistentFile = '')
			@data = Hash.new
			@removed = Hash.new
			@file = (persistentFile.nil? or persistentFile == '')? @@FILE : persistentFile
			
			begin
				if File.exists?(@file)
					Logger.instance.logger.info "loading meta yaml from #{@file}"
					@mm = YAML.load_file(@file) if File.exists?(@file)
					Logger.instance.logger.info "Loaded meta yaml: #{@mm}"
					@data = @mm[:current]
					@removed = @mm[:removed]
				else
					Logger.instance.logger.info "Creating new meta store in #{@file}"
				end
			rescue Exception => e
				raise FileStoreException, "Couldn't load meta data from file #{@file}"				
			end
				
		end
		#
		# @see MetaManager::get_data
		#
		def get_data(id)
			raise FileStoreException, "No meta data available for ID #{id}" if not @data.key?(id)
			
			return @data[id]
		end
		#
		# @see MetaManager::add_or_update
		#
		def add_or_update(id, metaData)
			raise FileStoreException, "Only hashsets can be added" if not metaData.is_a?(Hash)
			raise FileStoreException, "Only Strings can be used as keys" if not id.is_a?(String)
			
			@data[id] = (@data.key?(id) ? @data[id].merge!(metaData) : @data[id] = metaData)
		end
		#
		# @see MetaManager::remove
		#
		def remove(id)
			raise FileStoreException, "Only Strings can be used as keys" if not id.is_a?(String)
			raise FileStoreException, "ID #{id} not found in meta store" if not @data.key?(id)
			
			@removed[id] = @data[id]
			@data.delete(id)
		end
		#
		# @see MetaManager::restore
		#
		def restore(id)
			raise FileStoreException, "Only Strings can be used as keys" if not id.is_a?(String)
			raise FileStoreException, "ID #{id} not found in deleted meta store" if not @removed.key?(id)
			
			@data[id] = @removed[id]
			@removed.delete(id)
		end
		#
		# see MetaManager::shutdown
		#
		def shutdown
			begin
				File.open(@file, "w+") do |fh|
					YAML.dump({:current => @data, :removed => @removed}, fh)
				end
				
				@data = nil
			rescue Exception => e
				raise FileStoreException, "Couldn't serialize meta manager to file #{@file}.\n#{e.message}"
			end
		end
		#
		# @see MetaManager::has_id?
		#
		def has_id?(id)
			@data.key?(id)
		end
	end

end