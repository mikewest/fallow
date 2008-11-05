module Fallow
  class Flickr
#    FLICKR_ROOT = EXTERNALS_ROOT + '/flickr'
    
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
        flickr = REXML::Document.new( res.body )
      rescue  Timeout::Error, Errno::EINVAL, Errno::ECONNRESET, 
              EOFError, Net::HTTPBadResponse, Net::HTTPHeaderSyntaxError, 
              Net::ProtocolError, REXML::ParseException
        flickr = REXML::Document.new('')
      end
      
      flickr.elements.each('photosets/photoset') do |post|
        attributes  = post.attributes
        unix_time   = Time.parse(attributes['time']).to_i
        photoset    = {
          'id'      =>  attributes['id'],
          'primary' =>  attributes['primary'],
          'secret'  =>  attributes['secret'],
          'server'  =>  attributes['server'],
          'farm'    =>  attributes['farm']
        }
        Bookmarks.persist( "/del.icio.us/#{unix_time}", bookmark, true )
      end
  end
end

