module Fallow
  class Article
    def render ( request )
      if !request.env['MATCH_GROUP'] then
        return Fallow::ErrorPage.new.render( request )
      end

      year, month, slug = request.env['MATCH_GROUP'][1..3]
    
      @path   = "/#{year}/#{month}/#{slug}"
      @exists = File.exist?( DATA_ROOT + "/#{@path}.markdown" )
    
      if @exists
        [ 200, "#{@path} is totally an article.  Hooray!" ]
      else
        request.env['ERROR_TEXT'] = "#{@path} isn't an article.  Soz.";
        request.env['ERROR_CODE'] = 404;
        Fallow::ErrorPage.new.render( request )
      end
    end
  end
end