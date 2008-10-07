module Fallow
  class Homepage
    def render ( request )
      Fallow::ErrorPage.new.render( request );
    end
  end
end