module Fallow
  class Request
    URI_TYPES = {
      'article'   =>  %r{^/(\d{4})/(\d{2})/([^/])/?$},
      'archive'   =>  %r{^/(\d{4})/?(?:(\d{2})/?)?$},
      'homepage'  =>  %r{^/?$}
    };

    # Main entry point into Fallow from the Rack-based server
    def call ( env )
      requested_uri = env['PATH_INFO']
      uri_type      = nil

      if requested_uri =~ %r{^/(\d{4})/(\d{2})/([^/]+)/?$} then
        env['PAGE_TYPE']    = 'article'
        env['MATCH_GROUP']  = $~
        renderer            = Fallow::Article.new
      elsif requested_uri =~ %r{^/(\d{4})/?(?:(\d{2})/?)?$} then
        env['PAGE_TYPE']    = 'archive'
        env['MATCH_GROUP']  = $~
        renderer            = Fallow::Archive.new
      elsif requested_uri =~ %r{^/?$} then
        env['PAGE_TYPE']    = 'homepage'
        env['MATCH_GROUP']  = $~
        renderer            = Fallow::Homepage.new
      else
        env['PAGE_TYPE']    = 'error'
        env['MATCH_GROUP']  = nil
        renderer            = Fallow::ErrorPage.new
      end

      renderer.render( env )
    end
  end
end