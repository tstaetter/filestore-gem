#
# observer.rb
#
# author: Thomas Stätter
# date: 2014/01/05
#
require "../module.rb"

module FileStore
  #
  # Class FileStore::ObserverAction is used to encapsulate information 
  # describing actions occurring in an observed subject 
  #
  class ObserverAction
    TYPE_DEFAULT        = "DEFAULT"
    TYPE_STORE_ADD      = "STORE_ADD_FILE"
    TYPE_STORE_REMOVE   = "STORE_REMOVE_FILE"
    TYPE_STORE_GET      = "STORE_GET_FILE"
    TYPE_STORE_RESTORE  = "STORE_RESTORE_FILE"
    TYPE_STORE_SHUTDOWN = "STORE_SHUTDOWN"
    TYPE_MSTORE_CREATE  = "MSTORE_CREATE_TENANT"
    TYPE_MSTORE_ADD     = "MSTORE_ADD_FILE"
    TYPE_MSTORE_REMOVE  = "MSTORE_REMOVE_TENANT"
    TYPE_META_ADD       = "META_ADD_FILE"
    TYPE_META_REMOVE    = "META_REMOVE_FILE"
    TYPE_META_RESTORE   = "META_RESTORE_FILE"
    TYPE_META_SHUTDOWN  = "META_SHUTDOWN"
    #
    # Attribute accessors for instance variable defining the type of
    # action
    #
    attr_accessor :type
    #
    # Attribute accessors for instance variable containing references
    # to affected objects
    #
    attr_accessor :objects
    #
    # Attribute accessors for instance variable containing a message
    # providing useful information
    #
    attr_accessor :message
    
    def initialize(type = TYPE_DEFAULT, objects = [], message = "")
      @type = type
      @objects = objects
      @message = message
    end
    
    def to_s
      return "(ActionType) #{@type} || (Objects) #{@objects} || (Message) #{@message}"
    end
  end
  #
  # Module FileStore::OberservedSubject can be mixed in to implement an 
  # observed object. 
  #
  module OberservedSubject
    #
    # Reader for collection of observers
    #
    attr_reader :observers
    #
    # Module hook executed after the inclusion. Currently nothing
    # happens here
    #
    def self.included(klass)
    end
    #
    # Initializes needed attributes for implementing observer. Should
    # be called in any constructor including this module
    #
    def initialize_obs
      @observers = []
      self.logger.debug "Initialized ObservedStore, added observers array" if not self.logger.nil?
    end
    #
    # Registers an concrete observer
    #
    # Arguments:
    #   obj: The object added as an observer. Must be an instance of
    #       FileStore::Observer
    #
    def register(obj)
      if obj.is_a?(Observer) and not obj.nil? and not @observers.include?(obj) then
        @observers << obj
        self.logger.debug "Added #{obj} to observers" if not self.logger.nil?
      else
        raise FileStoreException, "Only instances of FileStore::Observer can be registered"
      end
    end
    #
    # Removes a concrete observer
    #
    # Arguments:
    #   obj: The observer to be removed. Obviously, it needs to be
    #       registered before-hand 
    #
    def unregister(obj)
      if @observers.include?(obj) then 
        @observers.delete_at(@observers.index(obj))
        self.logger.debug "Removed observing object #{obj} from the list" if not self.logger.nil?
      else
        raise FileStoreException, "Object #{obj} isn't a registered observer"
      end
    end
    #
    # Informs registered observers about an action 
    #
    # Arguments:
    #   msg: Some information sent to all registered observers
    #
    def inform(msg)
      @observers.each do |o|
        o.notify msg, self
      end
    end
    
  end
  #
  # Module FileStore::Observer can be mixed in to implement a 
  # observer. Observers are notified about actions occurring
  # in the observed subject, an instance of FileStore::SimpleStore
  # or FileStore::MultiTenantFileStore, respectively.
  #
  module Observer
    #
    # Module hook executed after the inclusion. Currently nothing
    # happens here
    #
    def self.included(klass)
    end
    #
    # Method called via the observed subject to inform observers
    # about an action occurred in the observed subject. Override
    # this method to fit your needs.
    #
    # Arguments:
    #   msg: Some information about the action
    #   subject: A reference to the observed object
    #
    def notify(msg, subject)
    end
    
  end
  
end