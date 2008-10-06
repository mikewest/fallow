module Fallow
  class Article
    def render ( env )
      if !env['MATCH_GROUP'] then
        return Fallow::ErrorPage.new.render( env )
      end

      year  = env['MATCH_GROUP'][1]
      month = env['MATCH_GROUP'][1]
      slug  = env['MATCH_GROUP'][1]
    
      @path   = "/#{year}/#{month}/#{slug}"
      @exists = File.exist?( DATA_DIR + "/#{@path}.markdown" )
    
      if @exists
        [ 200, {'Content-Type' => 'text/html'}, ["#{@path} is totally an article.  Hooray!"] ]
      else
        [ 404, {'Content-Type' => 'text/html'}, ["#{@path} isn't an article.  Soz."] ]
      end
    end
  end
end