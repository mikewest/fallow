module Fallow
  class Dispatch
    @@request       = nil
    @@paths_defined = false
    @@start         = nil
    def Dispatch.request
      @@request
    end
    def Dispatch.paths_defined?
      @@paths_defined
    end
    def Dispatch.timer_comment
      "<!-- Served uncached, via Fallow: #{Time.now - @@start} seconds.  Probably 1 database query. -->"
    end
    
    
    SUCCESS_CODE  = 200
#
#   Stole the idea completely from Sinatra
#
    def define_request_path ( url_patterns, &block)
      @dispatch_patterns = Array.new unless @dispatch_patterns
      
      url_patterns = [''] if url_patterns === ''
      url_patterns = url_patterns.to_a unless url_patterns.kind_of?( Array )

      uri_component = /:([A-Za-z0-9_\-]+)/
      uri_components = {
        'year'  => '(\d{4})',
        'month' => '(\d{2})',
        'slug'  => '([0-9A-Za-z_\-]+)',
        'tag'   => '([0-9A-Za-z_\-\%\[\]\:\!\@]+)',
      }
      url_patterns.each { |path|
        path.gsub!( uri_component ) { |match|
          if ( uri_components.has_key?( $1 ) )
            uri_components[ $1 ]
          else
            match
          end
        }
        path = "^#{path}/?$"
        @dispatch_patterns << [ %r{#{path}}, block ]
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

      content_type      = request.path_info.match(%r{\.xml}) ? 'application/xml' : 'text/html'
      encoding          = 'UTF-8'
      default_headers   = {
        'Content-Type'  => "#{content_type}; charset=#{encoding}",
        'Cache-Control' => 'max-age=3600, must-revalidate',
        'Server'        => 'nginx + thin + rack + fallow'
      }
      
      if found.nil?
        body, page_headers = Fallow::AdHoc.new( request.path_info ).render
      else
        match_group         = match_group.to_a[1..-1]
        body, page_headers  = found.call( match_group )
        page_headers        = {} if page_headers.nil?
      end
      body += Fallow::Dispatch.timer_comment
      Rack::Response.new( body, SUCCESS_CODE, default_headers.merge( page_headers ) ).finish
    end

    # Main entry point into Fallow from the Rack-based server
    def call ( env )
      @@start   = Time.now
      @@request = Rack::Request.new( env )

      if !Dispatch.paths_defined?
        define_request_path('/:year/:month/:slug') do |request_data|
          if request_data.nil?
            year, month, slug = ['','','']
          else
            year, month, slug = request_data[0..2]
          end
        
          Fallow::Article.new( year, month, slug ).render
        end

        define_request_path(['/:year','/:year/:month','/archive']) do |request_data|
          if request_data.nil?
            year, month = [nil,nil]
          else
            year, month = request_data[0..1]
          end

          Fallow::Archive.new(year, month).render
        end
        
        define_request_path(['/tags/:tag','/tags']) do |request_data|
          if request_data.nil?
            tag = nil
          else
            tag = request_data[0]
          end
          
          Fallow::Tags.new( tag ).render
        end

        define_request_path('/atom.xml') do |request_data|
          Fallow::Feed.new.render
        end
      
        define_request_path('') do |request_data|
          Fallow::Homepage.new.render
        end
        @@paths_defined = true;
      end
      
      result = nil
      begin
        begin
          result = dispatch( @@request )
        rescue Fallow::NotFound
          result = Fallow::ErrorPage.new.render( @@request, 404 )
        rescue Fallow::ServerError
          result = Fallow::ErrorPage.new.render( @@request, 500 )
        end
      rescue Fallow::RedirectTemp => boom
        result = Rack::Response.new( '', 302, { 'Location' => boom.message } ).finish
      rescue Fallow::RedirectPerm => boom
        result = Rack::Response.new( '', 301, { 'Location' => boom.message } ).finish
      rescue Exception => boom
        @@request['OMG!'] = boom.message
        @@request['Backtrace'] = boom.backtrace.inspect
        result = Fallow::ErrorPage.new.render( @@request, 500 )
      end
      result
    end
    
    def Dispatch.cache_headers( body, timestamp )
      [
        body,
        {
          'Last-Modified' =>  Time.at( timestamp ).httpdate
        }
      ]
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