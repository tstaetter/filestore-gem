#
# log.rb
# @author Thomas Stätter
# @date 09.07.2012
# @description Library using a file system as storage for arbitrary files
#
$:.unshift('.')

require 'filestore.rb'

module FileStore

	class Log
		FILE = 'filestore-actions.log'
		
		def initialize(path = '.')
			begin
				@logPath = File.join(path, FILE)
				@logFile = File.new(@logPath, 'a+')
			rescue StandardError => e
				raise FileStoreException, "Initialization of logger failed", e.backtrace
			end
		end
		
		def <<(action)
			return if not action.is_a? Action				
			
			@logFile.puts action.to_s
		end
		
		def close
			begin
				@logFile.close
			rescue StandardError => e
				raise FileStoreException, "Couldn't properly close the logger", e.backtrace
			end
		end
	end

end