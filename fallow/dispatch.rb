module Fallow
  class Dispatch
    @@request     = nil
    
    def Dispatch.request
      @@request
    end
    
    SUCCESS_CODE  = 200
#
#   Stole the idea completely from Sinatra
#
    def define_request_path ( url_patterns, &block)
      @dispatch_patterns = Array.new unless @dispatch_patterns
      
      url_patterns = url_patterns.to_a unless url_patterns.kind_of?( Array )

      uri_component = /:([A-Za-z0-9_\-]+)/
      uri_components = {
        'year'   => '(\d{4})',
        'month'  => '(\d{2})',
        'slug'   => '([0-9A-Za-z_\-]+)'
      }
      url_patterns.map { |path|
        path.gsub!( uri_component ) { |match|
          if ( uri_components.has_key?( $1 ) )
            uri_components[ $1 ]
          else
            match
          end
        }
        path += '/?'
        @dispatch_patterns << [ %r{#{path}}o, block ]
      }
      
    end
   
    def dispatch( request )
      found       = nil
      match_group = nil
      @dispatch_patterns.each { |pattern_group|
        if !found && request.path_info.match( pattern_group[0] )
          match_group = $~
          found       = pattern_group[1]
        end
      }
      raise Fallow::ServerError if found.nil?

      match_group = match_group.to_a[1..-1]

      Rack::Response.new( found.call( match_group ), SUCCESS_CODE ).finish
    end

    # Main entry point into Fallow from the Rack-based server
    def call ( env )
      @@request = Rack::Request.new( env )

      define_request_path('/:year/:month/:slug') do |request_data|
        if request_data.nil?
          year, month, slug = ['','','']
        else
          year, month, slug = request_data[0..2]
        end
        
        Fallow::Article.new( year, month, slug ).render
      end

      define_request_path('/') do |request_data|
        Fallow::Homepage.new.render
      end

      define_request_path(['/:year','/:year/:month']) do |request_data|
        Fallow::Archive.new
      end
      
      result = nil
      begin
        result = dispatch( @@request )
      rescue Fallow::NotFound
        result = Fallow::ErrorPage.new.render( @@request, 404 )
      rescue Fallow::ServerError
        result = Fallow::ErrorPage.new.render( @@request, 500 )
      end
      result
    end
    
    private :dispatch, :define_request_path
  end
end

if $0 == __FILE__
 
  require 'test/unit/assertions'
  include Test::Unit::Assertions
  
  d = Fallow::Dispatch.new
  d.define_request_path('/:year/:month/:slug') do
    puts 'Article!'
  end
  d.define_request_path('/:year/:month') do
    puts 'Archive!'
  end
  
  d.dispatch('/2008/01/this-is-a-slug')
  d.dispatch('/2008/01/')
  
end