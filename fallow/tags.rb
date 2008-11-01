module Fallow
  class Tags
    def tagged_items( tag )
      Fallow::Cache.get_tagged_items( tag )
    end
    def get_related_tags( tag )
      related_tags = Fallow::Cache.get_related_tags( tag, 10 )
      unless related_tags.empty?
        tags = []
        related_tags.each {|tag|
          tags << { 'normalized_tag' => Fallow.urlify( tag['tag'] ) }
        }
      else
        tags = nil
      end
      
    end

    def initialize( tag )
      @tag = tag
    end

    def render
      if @tag.nil?
        raise Fallow::NotFound
        # TODO: This should display a tag cloud
      else
        total_articles = 0
        recency = 0
        articles = tagged_items( @tag ).each {|item|
          recency = item['published'].to_i if item['published'].to_i > recency
          item['url'] = item['path'] if item['type'] == 'internal'
          item['published'] = Time.at(item['published'].to_i).strftime('%B %d, %Y')
          total_articles += 1
        }
        
        raise Fallow::NotFound if articles.empty?
        
        tags = get_related_tags( @tag )

        templater = Fallow::Template.new( 'tags' )
        @page_html = templater.render({
          'tag'           =>  @tag,
          'count'         =>  total_articles,
          :lists          =>  {
            'archived_article'  =>  articles,
            'tag'               =>  tags
          }
        })
      
        Fallow::Dispatch.cache_headers( @page_html, recency )
      end
    end
  end
end