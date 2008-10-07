module Fallow
  class Article
    def render ( request )
      if !request.env['MATCH_GROUP'] then
        return Fallow::ErrorPage.new.render( request )
      end

      year, month, slug = request.env['MATCH_GROUP'][1..3]
    
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