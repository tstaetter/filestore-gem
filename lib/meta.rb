#
# meta.rb
# @author Thomas Stätter
# @date 10.07.2012
# @description Library using a file system as storage for arbitrary files
#
$:.unshift('.')

require 'filestore.rb'

module FileStore

	class MetaManager
		
		def initialize 
			yield 
		end
		
		def <<(md)
		end
		
		def -(id)
		end
		
	end
	
	class MemoryMetaManager < MetaManager
		
		def initialize
			# must be a hash object
			@mgmt = super
			
			raise FileStoreException, "MemoryMetamanager needs a not nil hash object for initialization" if not @mgmt.is_a?(Hash) or @mgmt.nil?
		end
		
		def <<(md)
			raise FileStoreException, "Can't add 'nil' to the store" if md.nil?
			raise FileStoreException, "Only objects of type 'FileStore::MetaData' can be added to the store" if not md.instance_of?(MetaData)
			
			@mgmt[md.key] = md
		end
		
		def -(id)
			raise FileStoreException, "Can't remove 'nil' from the store" if id.nil?
			
			@mgmt.delete(id) if @mgmt.has_key?(id)
		end
		
		def [](id)
			raise FileStoreException, "Can't read 'nil' from the store" if id.nil?
			
			return @mgmt[id] if @mgmt.has_key?(id)
			nil
		end
		
	end
	
	class MetaData
		FIELD_PATH 		= 'path'
		FIELD_FILENAME 	= 'filename'
	
		attr_reader :key, :data
	
		def initialize(key, data)
			raise FileStoreException, "No identifier given for meta data" if key.nil?
			raise FileStoreException, "Identifier can only be of type String or Numeric" if (not key.is_a?(String) and not key.is_a?(Numeric))
			raise FileStoreException, "No data given" if data.nil?
			raise FileStoreException, "Data can only be of type Hash" if not data.is_a?(Hash)
			raise FileStoreException, "Identifier can't be empty" if key.is_a?(String) and key == ''
			
			@key = key
			@data = data
		end
		
		def path
			@data[FIELD_PATH]
		end
				
	end

end