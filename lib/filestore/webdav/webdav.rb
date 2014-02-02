#
# webdav.rb
#
# author: Thomas Stätter
# date: 2014/02/01
#
module FileStore::WebDAV
  #
  # Class WebDAVException is used to identify errors occuring
  # in WebDAV connections
  #
  class WebDAVException < Exception
  end
  #
  # Class implementing easy accessor to HTTP response headers
  #
  class ResponseHeaders
    attr_reader :headers, :http_version, :status, :response_text
    #
    # Initialize new ResponseHeaders instance
    #
    # Arguments:
    #   text: The raw response text
    #
    def initialize(text)
      @headers = {}
      @http_version = ''
      @status = -1
      @response_text = ''
      
      parse text
    end
    #
    # Determines wether the reponse body is XML
    #
    # Returns:
    #   true if content type is appilcation/xml, false otherwise
    #
    def is_xml?
      not (@headers['Content-Type'] =~ /^application\/xml.*/).nil?
    end
    #
    # Determines wether the reponse body is HTML
    #
    # Returns:
    #   true if content type is appilcation/html, false otherwise
    #
    def is_html?
      not (@headers['Content-Type'] =~ /^application\/html.*/).nil?
    end
    
    private
    #
    # Parse the reponse text
    #
    def parse(text)
      text.split("\n").each do |line|
        if line =~ /^.*\:.*$/
          s = line.split(":")
      
          key = s[0].strip
          value = s[1].strip
      
          @headers[key] = value
        else
          s = line.split
          
          @http_version = s[0]
          @status = s[1].to_i
          @response_text = s[2]
        end
      end
    end
  end
  #
  # Class implementing a connector to a HTTP resource via WebDAV
  #
  class WebDAV
    include FileStore::Logger
    
    attr_reader :host, :port, :protocol, :chunk_size
    attr_accessor :credentials, :path_prefix
    
    @socket = nil
   
    def initialize(host,port=80,protocol='HTTP/1.1',chunk=8096)
      @host = host.to_s
      @port = port.to_i
      @protocol = protocol
      @chunk_size = chunk.to_i
      @credentials = {}
    end
    
    def encode_credentials
      Base64.encode64("#{credentials[:user]}:#{credentials[:password]}").strip
    end
   
    def build_header(method, path, content_length = nil)
      header = "#{method} #{File.join(@path_prefix, path)} #{@protocol} \r\n"
      header += "Content-Length: #{content_length}\r\n" unless content_length.nil?
      header += "Host: #{@host}\r\n"
      header += "Authorization: Basic #{encode_credentials}\r\n" unless @credentials.empty?
      header += "User-Agent: WebDAV-Client/0.1\r\n"
      header += "Connection: close\r\n\r\n"
      
      return header
    end
   
    def request(method, path)
      data = {}
      buf = ''      
      begin
        open
        header = build_header(method, path)
        
        if @socket.write(header) == header.length then
          while line = @socket.gets # Read lines from socket
            buf += line
          end
          
          data = { 
            header: ResponseHeaders.new(buf.split("\r\n\r\n")[0]), 
            body: buf.split("\r\n\r\n")[1] 
          }
        else
          raise WebDAVException.new "Couldn't send request headers"
        end
      rescue Exception => e
        raise WebDAVException.new "Caught exception while sending request. #{e.message}"
      ensure
        close
      end
      
      return data
    end
    
    def delete(path)
      request('DELETE', path)
    end
    
    def propfind(path)
      request('PROPFIND', path)
    end
   
    def head(path)
      request('HEAD', path)
    end
   
    def mkcol(path)
      request('MKCOL', path)
    end
   
    def put(path, local_file, auto_head = true)
      if !File.exists?(local_file) || !File.readable?(local_file)
        raise WebDAVException.new "File not exists or not accessible for reading!"
      end
   
      open
   
      datalen = File.size(local_file)
      header = build_header('PUT', path, datalen)
   
      begin
        if @socket.write(header) == header.length then
          written = 0
          File.open(local_file,'r') do |f| 
            until f.eof? do
              written += @socket.write f.read(@chunk_size)
            end
          end
   
          if written == datalen
            close
            if !auto_head
              return true
            else
              return head(path)
            end
          end
        end
      rescue Exception => e
        raise WebDAVException.new "Caught exception in PUT request. #{e.message}"
      ensure
        close
      end
    end
    
    def get(path)
      request('GET', path)
    end
   
    def open
      begin 
        @socket = TCPSocket.open(@host, @port)
        return true
      rescue Exception => e
        raise WebDAVException.new "Caught exception while opening connection. #{e.message}"
      end
    end
   
    def close
      begin
        return @socket.close
      rescue 
        return false
      end
    end
    
  end
  
end