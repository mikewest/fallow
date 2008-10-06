module Fallow
  class Homepage
    def render ( env )
      Fallow::ErrorPage.new.render( env );
    end
  end
end