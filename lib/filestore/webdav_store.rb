#
# webdav_store.rb
#
# author: Thomas Stätter
# date: 2014/02/01
#
module FileStore::WebDAV
	#
	# Main library class implementing a WebDAV file store used for storing and managing 
	# arbitrary files
	#
	class WebDAVStore
	  include FileStore::Logger
		#
		# Accessors for important properties
		#
		attr_reader :host, :port, :root_path, :connection, :user, :password
		#
		# Initializes a new instance of SimpleFileStore
		#
		# Arguments:
		# 	root_path: The path where the file store resides
		#   logger: The logging facility
		#
		def initialize(host, port, user, password, root_path = '/', logger = StdoutLogger)
			@host = host
			@port = port
			@user = user
			@password = password
			@root_path = root_path
			
			initialize_connection
		end
		#
		# Adds a file to the store
		#
		# Arguments:
		# 	file: The file to be stored
		#
		# Returns:
		#	  The file path or nil
		#
		def add(file)
			raise FileStoreException, "File #{file} not found" if not File.exists?(file)
			raise FileStoreException, "File #{file} isn't readable" if not File.readable?(file)
			
			f_path = File.basename file
			remote_path = File.join @root_path, f_path
			
			begin
				result = @connection.put remote_path, file

				raise "Couldn't upload file, response code isn't of type 2xx" unless (result[:header].status.to_s =~ /2\d{2}/)
				
				inform ObserverAction.new(:type => ObserverAction::TYPE_DAV_ADD, 
          :objects => { :file => remote_path, :meta => meta }, :msg => "Added file to remote file store") if self.is_a?(ObservedSubject)
			rescue Exception => e
				raise FileStoreException, "Couldn't put file '#{file}' to remote store URL '#{remote_path}'.\n#{e.backtrace.join("\n")}"
			end
			
			return remote_path
		end
		#
		# Retrieves a file identified by it's path
		#
		# Arguments:
		# 	file: The file path to get from the remote store
		#
		# Returns: 
		#	A hash of file object (:path) and corresponding meta data (:data)
		#			representing the file in the store
		#
		def get(file)
			raise FileStoreException, "No file given" if file.nil? or file == ''
			
			# Retrieve data from the store
			result = @connection.get file
			
			unless result[:body].nil?
  			inform ObserverAction.new(:type => ObserverAction::TYPE_DAV_GET, 
          :objects => [file], :msg => "Returning file from the remote store")  if self.is_a?(ObservedSubject)
          
        return { :path => file, :data => result[:body] }
			else
			  return {}
			end
			
		end
		#
		# Deletes a file from the remote store
		#
		# Arguments:
		# 	file: The remote file path
		#
		def remove(file)
			raise FileStoreException, "No file given for removal" if (file == '' or file.nil?)
			
			begin
				result = @connection.delete file
				
				if result[:header].status.to_s =~ /2\d{2}/
  				inform ObserverAction.new(:type => ObserverAction::TYPE_DAV_REMOVE, 
            :objects => [id], :msg => "Deleted file from remote store") if self.is_a?(ObservedSubject)
        else
          raise "Response code isn't of class 2xx"
        end
			rescue Exception => e
				raise FileStoreException, "Couldn't remove file '#{file}' from remote store.\n#{e.message}"
			end
		end
		#
		# Shuts down the file store
		#
		def shutdown
			@connection.close
			
			inform ObserverAction.new(:type => ObserverAction::TYPE_DAV_SHUTDOWN, 
        :msg => "WebDAV store shutdown")  if self.is_a?(ObservedSubject)
		end
		
		private
		#
		# Initialize the HTTP connection
		#
		def initialize_connection
		  @connection = WebDAV.new @host, @port
		  @connection.credentials = { :user => @user, :password => @password }
		end
		#
		# Creates the directory if it doesn't exist
		#
		# Arguments:
		#   path: The path to be tested or created
		#
		def ensure_path(path)
		  ret = false
		  remote_path = File.join(@root_path, path)
		  result = @connection.propfind(remote_path)
		  
		  if result[:header].status.to_s =~ /2\d{2}/
		    # Directory exists
		    ret = true
		  else
		    # Directory must be created
		    result = @connection.mkcol remote_path
		    ret = true if (result[:header].status.to_s =~ /2\d{2}/)
		  end
		  
		  ret
		end
	end

end