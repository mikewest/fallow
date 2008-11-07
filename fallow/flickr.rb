module Fallow
  class Flickr
    FLICKR_ROOT = EXTERNALS_ROOT + '/flickr'
    
    @@thumb_url = 'http://farm{farm-id}.static.flickr.com/{server-id}/{id}_{secret}_s.jpg'
    
    def Flickr.get_set_list
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
        photoset    = {
          'id'          =>  attributes['id'],
          'primary'     =>  attributes['primary'],
          'secret'      =>  attributes['secret'],
          'server'      =>  attributes['server'],
          'farm'        =>  attributes['farm'],
          'title'       =>  set.elements['title'].text,
          'description' =>  set.elements['description'].text
        }
        Flickr.persist( "/flickr/#{attributes['id']}", photoset, true )
      end
    end

private
    def Flickr.persist( path, data, to_disk = false)
#      Fallow::Cache.update_bookmark( path, data )
      
      if to_disk
        filename = EXTERNALS_ROOT + path + '.yaml'
        File.open( filename, 'w' ) { |f| f.write( data.to_yaml ) }
      end
    end

  end
end