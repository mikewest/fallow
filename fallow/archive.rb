module Fallow
  class Article
    def render ( env )
      Fallow::ErrorPage.new.render( env );
    end
  end
end