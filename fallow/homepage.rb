module Fallow
  class Homepage
    def recent_articles( num = 5 )
      Fallow::Cache.get_recent_articles( num )
    end
    def recent_bookmarks( num = 5 )
      Fallow::Cache.get_recent_bookmarks( num )
    end

    def render ( )
      articles = recent_articles( 5 ).each {|article|
        article['url'] = article['path']
        article['published'] = Time.at(article['published']).strftime('%B %d, %Y at %H:%M')
        article['modified'] = Time.at(article['modified']).strftime('%B %d, %Y at %H:%M')
      }
      bookmarks = recent_bookmarks( 5 )

      templater = Fallow::Template.new( 'homepage' )
      @page_html = templater.render({
        :lists          =>  {
          'recent_writing'  =>  articles,
          'recent_link'     =>  bookmarks
        }
      })
      
      @page_html
    end
  end
end