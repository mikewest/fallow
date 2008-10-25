module Fallow
  class Bookmarks
    DELICIOUS_ROOT = EXTERNALS_ROOT + '/del.icio.us'
    
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
    end
      
      
  end
end