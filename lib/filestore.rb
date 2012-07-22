#
# filestore.rb
# @author Thomas Stätter
# @date 09.07.2012
# @description Library using a file system as storage for arbitrary files
#

$:.unshift('.')

require 'uuidtools'
require 'fileutils'
require 'action.rb'
require 'log.rb'
require 'meta.rb'

module FileStore

	class FileStoreException < Exception
	end

	class FileStore
		STORE_ROOT = 'filestore'
		DELETED_ROOT = 'deleted'
		
		def initialize(metaManager, basePath = ".")
			raise FileStoreException, "Invalid base path given" if (basePath.nil? or 
				not File.exists?(basePath) or
				not File.directory?(basePath) or
				not basePath.is_a?(String) or
				basePath == '')
		
			@storePath = File.join(basePath, STORE_ROOT)
			@deletedPath = File.join(basePath, DELETED_ROOT)
			
			begin
				FileUtils.mkdir_p(@storePath) if not Dir.exists?(@storePath)
				FileUtils.mkdir_p(@deletedPath) if not Dir.exists?(@deletedPath)
			rescue StandardError => e
				raise FileStoreException, "Couldn't create store directories", e.backtrace
			end
			
			# needs no specific exception handling dew to the fact, that the directories
			# could be created
			@logger = Log.new(basePath)
			
			raise FileStoreException, "No meta manager given" if not metaManager.is_a? MetaManager
			@metaManager = metaManager
		end
		
		def <<(path)
			id = ''
			
			if File.exists?(path) and File.readable?(path) then
				id = UUIDTools::UUID.random_create.to_s
				action = AddAction.new(id, "Origin: #{path}")
				
				action.execute {
					dstPath = move(@storePath, id, path)
					
					raise "Couldn't move file" if dstPath == ''
					
					@metaManager << MetaData.new(id, { MetaData::FIELD_PATH => dstPath })
				}
				
				@logger << action
			else
				raise FileStoreException, "File is not readable"
			end
			
			id
		end
		
		def -(id)
			if @metaManager[id] != nil then
				md = @metaManager[id]
				action = DeleteAction.new(id, "Origin: #{md.path}")
				
				action.execute {
					raise "Couldn't move file" if move(@deletedPath, id, @metaManager[id].path) == ''
					@metaManager - id
				}
				
				@logger << action
			else
				raise FileStoreException, "Key not found"
			end
		end
		
		protected
		
		def move(basePath, id, srcPath)
			dstPath = ''
			
			begin
				date = Date.today
				dstPath = File.join(basePath, date.year.to_s, date.month.to_s, date.day.to_s, id)
				dstDir = File.dirname(dstPath)
				
				(FileUtils.mkdir_p(dstDir) and puts "creating #{dstDir}") if not Dir.exists?(dstDir)
				FileUtils.mv(srcPath, dstPath)
			rescue Exception => e
				raise FileStoreException, "Couldn't move file", e.backtrace
			ensure
				return dstPath
			end
		end
	end

end