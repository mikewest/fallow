module Fallow
  class Bookmarks
    DELICIOUS_ROOT = EXTERNALS_ROOT + '/del.icio.us'
    
    def Bookmarks.last_update
      timestamp = `ls #{DELICIOUS_ROOT} | sort | tail -n1 | sed -e 's#\.yaml##'`
      if timestamp != ''
        timestamp = Time.at(timestamp.to_i)
      else
        timestamp = Time.at(0)
      end
      timestamp.strftime('%Y-%m-%dT%H:%M:%SZ')
    end
    
    def Bookmarks.sync!
      require 'net/https'
      require 'rexml/document'
      Kernel::load( ROOT_DIR + '/fallow.conf' )
      http = Net::HTTP.new('api.del.icio.us', 443)
      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE

      res = http.start do |http|
        req = Net::HTTP::Get.new("/v1/posts/all?fromdt=#{Bookmarks.last_update}", 'User-Agent' => 'Fallow/0.01a')
        req.basic_auth(@@auth[0], @@auth[1])
        http.request(req)
      end

      begin
        delicious = REXML::Document.new( res.body )
      rescue  Timeout::Error, Errno::EINVAL, Errno::ECONNRESET, 
              EOFError, Net::HTTPBadResponse, Net::HTTPHeaderSyntaxError, 
              Net::ProtocolError, REXML::ParseException
        delicious = REXML::Document.new('')
      end
      delicious.elements.each('posts/post') do |post|
        attributes  = post.attributes
        unix_time   = Time.parse(attributes['time']).to_i
        bookmark    = {
          'hash'      =>  attributes['hash'],
          'url'       =>  attributes['href'],
          'title'     =>  attributes['description'],
          'desc'      =>  attributes['extended'],
          'published' =>  unix_time,
          'tags'      =>  attributes['tag'].split(' ')
        }
        Bookmarks.persist( "/del.icio.us/#{unix_time}", bookmark, true )
      end
    end
    
    def Bookmarks.update_cache!
      require 'find'
      Find.find( DELICIOUS_ROOT ) do |bookmark|
        if File.file?(bookmark) && bookmark.match(%r{/(\d+).yaml$})
          puts "Rendering /del.icio.us/#{$1}\n"
          data = Bookmarks.read_data( $1 )
          Bookmarks.persist( "/del.icio.us/#{$1}", data, false )
        end
      end
    end
    
private
    def Bookmarks.read_data( timestamp )
      filename = DELICIOUS_ROOT + "/#{timestamp}.yaml"
      raise Fallow::NotFound unless File.exist?( filename )
      
      data = File.open( filename ) { |yf| YAML::load( yf ) }
      data
    end
    
    def Bookmarks.persist( path, data, to_disk = false)
      Fallow::Cache.update_bookmark( path, data )
      
      if to_disk
        filename = EXTERNALS_ROOT + path + '.yaml'
        File.open( filename, 'w' ) { |f| f.write( data.to_yaml ) }
      end
    end
  end
end