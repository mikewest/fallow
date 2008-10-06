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
      
      env['MATCH_GROUP']  = nil
      URI_TYPES.each {|type, regex|
        if
          !env['MATCH_GROUP']
          &&
          env['MATCH_GROUP'] = regex.match(requested_uri)
        then
          uri_type = type;
        end
      }
      
      renderer = nil
      case uri_type
        when 'article'  then renderer = Fallow::Article.new
        when 'archive'  then renderer = Fallow::Archive.new
        when 'homepage' then renderer = Fallow::Homepage.new
        else renderer = Fallow::ErrorPage.new
      end
      renderer.render( env )
    end
  end
end