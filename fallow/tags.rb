module Fallow
  class Tags
    def tagged_items( tag )
      Fallow::Cache.get_tagged_items( tag )
    end

    def initialize( tag )
      @tag = tag
    end

    def render
      if @tag.nil?
        
      else
        articles = tagged_items( @tag ).each {|item|
          item['url'] = item['path'] if item['type'] == 'article'
          item['published'] = Time.at(item['published'].to_i).strftime('%B %d, %Y')
        }

        templater = Fallow::Template.new( 'tags' )
        @page_html = templater.render({
          'tag'           =>  @tag,
          :lists          =>  {
            'archived_article'  =>  articles,
          }
        })
      
        @page_html
      end
    end
  end
end