module Fallow
  class Feed
    def recent_articles( num = 10 )
      Fallow::Cache.get_recent_articles( num )
    end
    def recent_bookmarks( num = 10 )
      Fallow::Cache.get_recent_bookmarks( num )
    end

    def render ( )
      template_data = {
        'last_updated'  =>  nil,
        :lists          =>  {
          'atom_entry_list'  =>  []
        }
      }

      recency = 0      
      articles = recent_articles( 10 ).each {|article|
        recency = article['published'] if article['published'] > recency
        current = Fallow::Article.new( article['path'] ).raw_data
        template_data['last_updated'] = current['updated'] if template_data['last_updated'].nil?
        template_data[:lists]['atom_entry_list'] << current
      }
      
      templater = Fallow::Template.new( 'atom.xml' )
      @page_html = templater.render( template_data )
      
      Fallow::Dispatch.cache_headers( @page_html, recency )
    end
  end
end