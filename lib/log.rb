#
# log.rb
#
# author: Thomas Stätter
# date: 2012/11/07 
#
require 'date'
require 'log4r'
require 'singleton'

module FileStore
	#
	# Singleton logging facility class
	#
	class Logger
		include Singleton
		
		attr_reader :logger
		#
		# Creates a new logging facility
		#
		def initialize
			@logger = Log4r::Logger.new 'FileStore'
			@logger.outputters = Log4r::StdoutOutputter.new(:level => Log4r::WARN, 
                    	:formatter => Log4r::PatternFormatter.new(:pattern => "[%l] %d - %m"))
		end
	end

end