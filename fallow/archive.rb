module Fallow
  class Archive
    def render ( request )
      Fallow::ErrorPage.new.render( request );
    end
  end
end