module Fallow
  class Archive
    def render ( env )
      Fallow::ErrorPage.new.render( env );
    end
  end
end