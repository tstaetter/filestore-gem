#
# tc_webdav.rb
#
# @author Thomas Stätter
# @date 2014/02/01
# @description Test script
#
require './classes.rb'
require 'test/unit'

include FileStore::WebDAV

class TestWebDAV < Test::Unit::TestCase
  
  def setup
    @host = 'owncloud.strawanzen.at'
    @credentials = { :user => 'demo', :password => 'demo' }
    @path = '/files'
    @test_file = 'testfile.txt'
    @webdav = WebDAV.new @host
    @remote_dir = File.join(@path, 'new@dir')
    
    @webdav.logger = StdoutLogger
    @webdav.credentials = @credentials
    @webdav.path_prefix = '/remote.php/webdav/'
    
    File.open(@test_file, "w+") do |f|
      f.write("lorem ipsum")
    end
  end
  
  def teardown
    FileUtils.rm(@test_file) if File.exists?(@test_file)
  end
  
  def test_01_connect
       puts "=" * 80
       puts "TestWebDAV::test_connect"
       puts "=" * 80
       result = {}
       
       assert_nothing_raised(Exception) { result = @webdav.propfind(@path) }
       assert_not_nil(result[:header])
       assert_not_nil(result[:body])
       assert_match(/2\d{2}/, result[:header].status.to_s, "[TestWebDAV::test_connect] Response code isn't of class 2xx")
       assert(result[:header].is_xml?, "[TestWebDAV::test_connect] Response is not XML")
  end
    
  def test_02_put
       puts "=" * 80
       puts "TestWebDAV::test_put"
       puts "=" * 80
       
       # result = {}
       upload = File.join(@path, @test_file)
       
       assert_nothing_raised(WebDAVException) {
         puts "[TestWebDAV::test_put] Uploading file '#{@test_file}' to '#{upload}'" 
         result = @webdav.put upload, @test_file
       }
       # assert_match(/2\d{2}/, result[:header].status.to_s, "Response code isn't of class 2xx")
  end
     
  def test_03_propfind
       puts "=" * 80
       puts "TestWebDAV::test_propfind"
       puts "=" * 80
       
       upload = File.join(@path, @test_file)
       result = {}
       
       assert_nothing_raised(WebDAVException) {
         puts "[TestWebDAV::test_propfind] Reading info for '#{upload}'" 
         result = @webdav.propfind upload
       }
       assert_match(/2\d{2}/, result[:header].status.to_s, "[TestWebDAV::test_propfind] Response code isn't of class 2xx")
  end
     
  def test_04_mkcol
       puts "=" * 80
       puts "TestWebDAV::test_mkcol"
       puts "=" * 80
       
       result = {}
       
       assert_nothing_raised(WebDAVException) {
         puts "[TestWebDAV::test_mkcol] Creating directory file '#{@remote_dir}'" 
         result = @webdav.mkcol @remote_dir
       }
       assert_match(/2\d{2}/, result[:header].status.to_s, "[TestWebDAV::test_mkcol] Response code isn't of class 2xx")
  end
  
  def test_05_get
    puts "=" * 80
    puts "TestWebDAV::test_get"
    puts "=" * 80
    
    result = {}
    remote_file = File.join(@path, @test_file)
    
    assert_nothing_raised(WebDAVException) {
      puts "[TestWebDAV::test_get] Trying to get remote file '#{remote_file}'" 
      result = @webdav.get remote_file
      puts "[TestWebDAV::test_get] Got file contents: #{result[:body]}"
    }
    assert_match(/2\d{2}/, result[:header].status.to_s, "[TestWebDAV::test_get] Response code isn't of class 2xx")
    assert_not_nil(result[:body], "[TestWebDAV::test_get] No data given")
  end
  
  def test_06_delete
    puts "=" * 80
    puts "TestWebDAV::test_delete"
    puts "=" * 80
    
    upload = File.join(@path, @test_file)
    result = {}
    
    assert_nothing_raised(WebDAVException) {
      puts "[TestWebDAV::test_delete] Deleting file '#{upload}'" 
      result = @webdav.delete upload
    }
    assert_match(/2\d{2}/, result[:header].status.to_s, "[TestWebDAV::test_delete] Response code isn't of class 2xx")
    assert_nothing_raised(WebDAVException) {
      puts "[TestWebDAV::test_delete] Deleting directory '#{@remote_dir}'" 
      result = @webdav.delete @remote_dir
    }
    assert_match(/2\d{2}/, result[:header].status.to_s, "[TestWebDAV::test_delete] Response code isn't of class 2xx")
  end
  
end