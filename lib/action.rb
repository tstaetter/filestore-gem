#
# action.rb
# @author Thomas Stätter
# @date 09.07.2012
# @description Library using a file system as storage for arbitrary files
#
$:.unshift('.')

require 'filestore.rb'

module FileStore

	class Action
		@@DATE_FORMAT = '%d.%m.%Y %H:%M:%S:%L'
		
		@@STATUS_NOT_STARTED 	= "NOT STARTED"
		@@STATUS_SUCCESS 		= "SUCCESS"
		@@STATUS_FAILURE		= "FAILURE"
		
		@type = 'UNDEFINED'
		
		def initialize(id, msg = "")
			raise FileStoreException, "No identifier given for action" if id.nil?
			raise FileStoreException, "Identifier can only be of type String or Numeric" if (not id.is_a?(String) and not id.is_a?(Numeric))
			raise FileStoreException, "Identifier can't be empty" if id.is_a?(String) and id == ''
			
			@identifier = id
			@status = @@STATUS_NOT_STARTED
			@msg = msg
		end
		
		def execute(&block)
			@start = Date.today.strftime @@DATE_FORMAT
			
			begin
				block.call
				@end = Date.today.strftime @@DATE_FORMAT
			rescue Exception => e
				@status = @@STATUS_FAILURE
				raise FileStoreException, 'Caught exception while executing action', e.backtrace
			else
				@status = @@STATUS_SUCCESS
			end
		end
		
		def to_s
			"#{@status} - #{@start} - #{self.class.name} - #{@msg} - #{@end} - #{@identifier}"
		end
	end
	
	class AddAction < Action
	end
	
	class DeleteAction < Action
	end

end