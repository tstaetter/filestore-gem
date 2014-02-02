#
# store_factory.rb
#
# author: Thomas Stätter
# date: 2014/01/06
#
module FileStore
  #
  # Base factory class
  #
  class BaseFactory
    #
    # Creates a new instance of the given class
    #
    # Arguments:
    #   klass: The class to be instantiated
    #   path: The path to be used wether for stores or managers
    #   observable (optional): Determines wether this instance should support observation
    #   logger (optional): The logging facility
    #
    # Returns:
    #   A new instance of 'klass'
    #
    def self.create(klass, path, observable = false, logger = StdoutLogger)
      logger.debug "Creating new instance of class #{klass} with path '#{path}'"
      obj = klass.new path
      
      obj.logger = logger if not logger.nil?
      
      if observable then
        logger.debug "Extending instance with module 'ObservedSubject'"
        
        obj.extend ObservedSubject
        obj.initialize_obs 
      end
      
      return obj
    end
    
  end
  #
  # MetaManager factory class
  #
  class MemoryMetaFactory < BaseFactory
    #
    # Creates a memory meta-manager instance
    #
    # Arguments:
    #   persist_file: The file where the manager will be persistet
    #   observable (optional): Determines wether this instance should support observation
    #   logger (optional): The logging facility
    #
    # Returns:
    #   A new instance of MemoryMetaManager
    #
    def self.create(persist_file = MemoryMetaManager::FILE, observable = false, logger = StdoutLogger)
      return super(MemoryMetaManager, persist_file, observable, logger)
    end
  end
  #
  # MultiTenantFileStore factory class
  #
  class MultiTenantStoreFactory < BaseFactory
    #
    # Creates a multi tenant store instance
    #
    # Arguments:
    #   base_path: The directory of the multitenant store
    #   observable (optional): Determines wether this instance should support observation
    #   logger (optional): The logging facility
    #
    # Returns:
    #   A new instance of MultiTenantStore
    #
    def self.create(base_path, observable = false, logger = StdoutLogger)
      logger.debug "Creating new MultiTenantFileStore"
      multi_store = super MultiTenantFileStore, base_path, observable, logger
      
      multi_store.stores = MultiTenantStoreFactory::recover_tenant_stores(base_path, observable, logger) if File.exists?(base_path)
      
      return multi_store
    end
    
    #
    # Recovers a multitenant store
    #
    # Arguments:
    #   rootPath: The base path of the multitenant store
    #   logger (optional): The logging facility
    #
    # Returns:
    #   A hashset of file stores (with the user ID as key) recovered
    #   from the given directory
    #
    def self.recover_tenant_stores(root_path, observable, logger)
      raise FileStoreException, "Root path #{rootPath} isn't a valid multitenant store" if not File.directory?(root_path)
      
      stores = {}
      
      logger.debug "Trying to recover tenant stores"
      
      Dir.glob(File.join(root_path, "*")).each do |e|
        begin
          if File.directory?(e) then
            tenant = File.basename(e)
            tenant_path = File.absolute_path e
            
            logger.debug "Restoring tenant store in directory #{tenant_path}"
            
            sfs = SimpleStoreFactory::create tenant_path, observable, logger
        
            stores[tenant] = sfs
          end
        rescue Exception => e
          logger.error "Couldn't create store for tenant #{tenant}.\n#{e}"
        end
      end
      
      return stores
    end
    
  end
  #
  # SimpleFileStore factory class
  #
  class SimpleStoreFactory < BaseFactory
    #
    # Creates a simple file-store instance
    #
    # Arguments:
    #   base_path: The base path directory
    #   observable (optional): Determines wether this instance should support observation
    #   logger (optional): The logging facility
    #
    # Returns:
    #   A new instance of SimpleFileStore
    #
    def self.create(base_path, observable = false, logger = StdoutLogger)
      store = super(SimpleFileStore, base_path, observable, logger)
      mm = MemoryMetaFactory.create File.join(base_path, MemoryMetaManager::FILE), observable, logger
      
      store.meta_manager = mm
      
      begin
        SimpleStoreFactory.recover_store(store)
      rescue FileStoreException => e
        logger.debug "Couldn't recover store.\nReason: #{e.message}\nTrying to create the store"
        SimpleStoreFactory.create_store(store)
      end
      
      return store
    end
    
    #
    # Setup for a new file store directory
    #
    # Arguments:
    #   store: The file store instance to set up
    #
    def self.create_store(store)
      # Try to create needed directories
      begin
        FileUtils.mkdir [store.store_path, store.deleted_path, store.rollback_path]
      rescue Errno::ENOENT => e
        raise FileStoreException, "One ore more system directories couldn't be created.\n#{e.message}"
      end
      #
      # Try to create hidden meta file
      #
      begin
        meta = { 
          :created_at => Date.today.strftime('%d.%m.%Y %H:%M:%S:%L'), 
          :store_path => store.store_path,
          :deleted_path => store.deleted_path,
          :rollback_path => store.rollback_path,
          :created_by => Etc.getlogin
        }
        
        File.open(store.meta_file, "wb+") do |fh|
          YAML.dump(meta, fh)
        end
        #
        # Creation was successful
        #
      rescue Exception => e
        raise FileStoreException, "Store meta file #{store.meta_file} couldn't be created.\n#{e.message}"
      end
    end
    #
    # Recover an existing file store
    #
    # Arguments:
    #   store: The file store instance to recover
    #
    def self.recover_store(store)
      # trying to recover existing file store
      begin
        meta = YAML.load_file(store.meta_file)
        
        raise FileStoreException, "Store directory not found" if not File.directory?(meta[:store_path])
        raise FileStoreException, "Deleted directory not found" if not File.directory?(meta[:deleted_path])
        raise FileStoreException, "Rollback directory not found" if not File.directory?(meta[:rollback_path])
        #
        # Recovery was successful
        #
      rescue Exception => e
        raise FileStoreException, "Unable to recover file store from path #{store.root_path}.\n#{e.message}"
      end
    end
  end
  
  module WebDAV
    #
    # WebDAVStore factory class
    #
    class WebDAVStoreFactory
      #
      # Creates a WebDAV file-store instance
      #
      # Arguments:
      #   root_path: The base path directory
      #   host: The WebDAV host
      #   prefix: The path prefix for any URL
      #   port (optional): The WebDAV port
      #   user (optional): HTTP user
      #   password (optional): HTTP password 
      #   observable (optional): Determines wether this instance should support observation
      #   logger (optional): The logging facility
      #
      # Returns:
      #   A new instance of WebDAVStore
      #
      def self.create(root_path, host, prefix, port = 80, user = '', password = '', observable = false, logger = StdoutLogger)
        store = nil
        
        begin
          store = WebDAVStore.new host, port, user, password, root_path, logger
          store.connection.path_prefix = prefix
          
          if observable then
            logger.debug "Extending instance with module 'ObservedSubject'"
            
            store.extend ObservedSubject
            store.initialize_obs 
          end
        rescue FileStoreException => e
          logger.debug "Couldn't create webdav store.\nReason: #{e.message}"
        end
        
        return store
      end
    end
  end
end