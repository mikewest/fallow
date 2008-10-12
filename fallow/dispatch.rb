module Fallow
  class Dispatch
#
#   Stole the idea completely from Sinatra
#
    def define_request_path ( url_patterns, &block)
      @dispatch_patterns = Array.new unless @dispatch_patterns
      
      url_patterns = url_patterns.to_a unless url_patterns.kind_of?( Array )

      uri_component = /:([A-Za-z0-9_\-]+)/
      uri_components = {
        'year'   => '\d{4}',
        'month'  => '\d{2}',
        'slug'   => '[0-9A-Za-z_\-]+'
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
      found = nil
      @dispatch_patterns.each { |pattern_group|
        if !found && request.path_info.match( pattern_group[0] )
          found = pattern_group[1]
        end
      }
      unless found.nil?
        renderer = found.call
        code, body = renderer.render( request )[0..1]
      else
        code, body = Fallow::ErrorPage.new.render( request, 404 )[0..1]
      end
      Rack::Response.new( body, code ).finish
    end

    # Main entry point into Fallow from the Rack-based server
    def call ( env )
      request = Rack::Request.new( env )

      define_request_path('/:year/:month/:slug') do |request|
        Fallow::Article.new
      end

      define_request_path('/') do |request|
        Fallow::Homepage.new
      end

      define_request_path(['/:year','/:year/:month']) do |request|
        Fallow::Archive.new
      end
      
      dispatch( request )
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