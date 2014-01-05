#
# log.rb
# @author Thomas Stätter
# @date 2012/11/26
# @description
#
module FileStore
  #
  # Mix-in module for logging capabilities
  #
  module Logger
    #
    # Accessor for the logging facility. Any logging facility must
    # implement the methods 'info', 'warn', 'error' and 'debug'
    #
    attr_accessor :logger
  end
  #
  # Simple logger class for stdout logging
  #
  class StdoutLogger
    
    def StdoutLogger.log(level, msg)
      puts "[#{level}] #{msg}"
    end
    
    def StdoutLogger.info(msg)
      StdoutLogger::log("INFO", msg)
    end
    
    def StdoutLogger.warn(msg)
      StdoutLogger::log("WARN", msg)
    end
    
    def StdoutLogger.error(msg)
      StdoutLogger::log("ERROR", msg)
    end
    
    def StdoutLogger.debug(msg)
      StdoutLogger::log("DEBUG", msg)
    end
    
  end
  
end