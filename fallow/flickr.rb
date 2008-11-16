module Fallow
  class Flickr
    FLICKR_ROOT           = EXTERNALS_ROOT  + '/flickr'

    def Flickr.get_set_list!
      require 'net/https'
      require 'rexml/document'
      Kernel::load( ROOT_DIR + '/fallow.conf' )
      
      http = Net::HTTP.new('api.flickr.com', 80)

      begin
        res = http.start do |http|
          req = Net::HTTP::Get.new("/services/rest/?api_key=#{@@auth[0]}&user_id=#{@@user_id}&method=flickr.photosets.getList", 'User-Agent' => 'Fallow/0.01a')
          http.request(req)
        end
        flickrsets = REXML::Document.new( res.body )
      rescue  Timeout::Error, Errno::EINVAL, Errno::ECONNRESET, 
              EOFError, Net::HTTPBadResponse, Net::HTTPHeaderSyntaxError, 
              Net::ProtocolError, REXML::ParseException
        flickrsets = REXML::Document.new('')
      end
      
      flickrsets.elements.each('rsp/photosets/photoset') do |set|
        attributes  = set.attributes
        
        next if Flickr.set_exists?( attributes['id'] )
        
        photo       = Flickr.get_photo_data( attributes['primary'], attributes['secret'], attributes['id'] )
        
        photoset    = {
          'path'        =>  "/flickr/#{attributes['id']}",
          'id'          =>  attributes['id'],
          'primary'     =>  attributes['primary'],
          'secret'      =>  attributes['secret'],
          'server'      =>  attributes['server'],
          'farm'        =>  attributes['farm'],
          'photos'      =>  attributes['photos'],
          'title'       =>  set.elements['title'].text,
          'desc'        =>  set.elements['description'].text,
          'published'   =>  photo['published'],
          'url'         =>  "http://www.flickr.com/photos/#{@@friendly_name}/sets/#{attributes['id']}"
        }
        Flickr.persist( photoset['path'], photoset, true )
      end
    end
    
    def Flickr.update_cache!
      require 'find'
      Find.find( FLICKR_ROOT ) do |set|
        if File.file?(set) && set.match(%r{/(\d+).yaml$})
          puts "Rendering /flickr/#{$1}\n"

          data = File.open( set ) { |yf| YAML::load( yf ) }

          Flickr.persist( "/flickr/#{$1}", data, false )
        end
      end
    end

private
    def Flickr.set_exists?( set_id )
      filename = FLICKR_ROOT + "/#{set_id}.yaml"
      imgname  = FLICKR_ROOT + "/thumbnails/#{set_id}.jpg"
      File.exist?( filename ) && File.exist?( imgname )
    end

    def Flickr.persist( path, data, to_disk = false)
      Fallow::Cache.update_flickr_set( path, data )
      
      if to_disk
        filename = EXTERNALS_ROOT + path + '.yaml'
        File.open( filename, 'w' ) { |f| f.write( data.to_yaml ) }
      end
    end

    def Flickr.get_photo_data( photo_id, photo_secret, set_id = nil )
      http = Net::HTTP.new('api.flickr.com', 80)
      begin
        res = http.start do |http|
          req = Net::HTTP::Get.new("/services/rest/?method=flickr.photos.getInfo&api_key=#{@@auth[0]}&photo_id=#{photo_id}&secret=#{photo_secret}", 'User-Agent' => 'Fallow/0.01a')
          http.request( req )
        end
        photo = REXML::Document.new( res.body )
      rescue Exception
        photo = REXML::Document.new('')
      end

      to_return = {}
      photo.elements.each("rsp/photo") do |p|
        atts = p.attributes
        
        unless ( set_id.nil? )
          # Get photo URL
          (farm, server, id, secret) = atts['farm'], atts['server'], atts['id'], atts['secret']
          http = Net::HTTP.new("farm#{farm}.static.flickr.com", 80)
          begin
            res = http.start do |http|
              req = Net::HTTP::Get.new("/#{server}/#{id}_#{secret}_s.jpg", 'User-Agent' => 'Fallow/0.01a')
              http.request( req )
            end
            FileUtils.mkdir_p FLICKR_ROOT + "/thumbnails/"
            filename = FLICKR_ROOT + "/thumbnails/#{set_id}.jpg"
            File.open( filename, 'w' ) { |f| f.write( res.body ) }
          end
        end
        
        # Return published date
        to_return['published']  = p.elements['dates'].attributes['posted']
      end
      to_return
    end
  end
end