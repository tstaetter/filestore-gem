#
# meta_manager.rb
# @author Thomas Stätter
# @date 2012/11/08
# @description
#

module FileStore
	#
	# Base class for implementing a meta manager class. This class is used for storing
	# and managing file meta data
	#
	class MetaManager
		#
		# Returns the data set identified by the given id
		# @param ID The ID to be looked for
		# @returns A hashset containing all stored meta data
		#
		def get_data(id)
		end
		#
		# Removes a dataset from the collection
		# @param id The key to identify the data to be deleted
		#
		def remove(id)
		end
		#
		# Restores a previously deleted meta data set
		# @param id The ID of the meta data set to be restored
		#
		def restore(id)
		end
		#
		# Adds/updates a dataset to/in the collection
		# @param id The key to identify the data
		# @param metaData The actual meta data to store
		#
		def add_or_update(id, metaData)
		end
		#
		# Shuts down the manager class and clears all used resources
		#
		def shutdown
		end
		#
		# Determines wether a given ID is already in use
		# @param id The ID to be tested
		#
		def has_id?(id)
		end
	end

end