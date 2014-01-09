#
# meta_manager.rb
#
# author: Thomas Stätter
# date: 2012/11/08
#
module FileStore
	#
	# Base class for implementing a meta manager class. This class is used for storing
	# and managing file meta data
	#
	class MetaManager
		#
		# Returns the data set identified by the given id
		#
		# Arguments:
		#	id: The ID to be looked for
		#
		# Returns:
		#	A hashset containing all stored meta data
		#
		def get_data(id)
		end
		#
		# Removes a dataset from the collection
		#
		# Arguments:
		#	id: The key to identify the data to be deleted
		#
		def remove(id)
		end
		#
		# Restores a previously deleted meta data set
		#
		# Arguments:
		#	id: The key to identify the data to be deleted
		#
		def restore(id)
		end
		#
		# Adds/updates a dataset to/in the collection
		#
		# Arguments:
		#	id: The key to identify the data to be deleted
		# 	metaData: The actual meta data to store
		#
		def add_or_update(id, metaData)
		end
		#
    # Saves the meta data in the current state
    #
		def save
		end
		#
		# Shuts down the manager class and clears all used resources
		#
		def shutdown
		end
		#
		# Determines wether a given ID is already in use
		#
		# Arguments:
		# 	id: The ID to be tested
		#
		def has_id?(id)
		end
	end

end