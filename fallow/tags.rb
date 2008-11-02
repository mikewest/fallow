module Fallow
  class Tags
    require 'uri'
    def tagged_items( tag )
      Fallow::Cache.get_tagged_items( tag )
    end
    def get_related_tags( tag )
      related_tags = Fallow::Cache.get_related_tags( tag, 10 )
      unless related_tags.empty?
        tags = []
        related_tags.each {|tag|
          tags << { 'tag' => tag['tag'], 'uritag' => URI.encode( tag['tag'] ) }
        }
      else
        tags = nil
      end
      tags
    end
    
    def get_tag_cloud_data()
      tags = Fallow::Cache.get_tag_cloud_data()
      tags.each { |tag|
        tag['class']  = case tag['tag_count'].to_i
                          when 1:     'not-popular'
                          when 2:     'popular'
                          when 3..9:  'very-popular'
                          else        'ultra-popular'
                        end
        tag['uritag'] = URI.encode( tag['tag'] )
      }
    end

    def initialize( tag )
      @tag = tag
    end

    def render
      if @tag.nil?
        tags = get_tag_cloud_data()
        recency = Time.now.to_i
        templater = Fallow::Template.new( 'tag_cloud' )
        @page_html = templater.render({
          :lists          =>  {
            'tag_in_cloud'      =>  tags
          }
        })
      else
        @tag = URI.decode( @tag )
        total_articles = 0
        
        recency = 0
        articles = tagged_items( URI.decode( @tag ) ).each {|item|
          recency = item['published'].to_i if item['published'].to_i > recency
          item['url'] = item['path'] if item['type'] == 'internal'
          item['published'] = Time.at(item['published'].to_i).strftime('%B %d, %Y')
          total_articles += 1
        }
        
        raise Fallow::NotFound if articles.empty?
        
        tags = get_related_tags( @tag )
pp  tags
        templater = Fallow::Template.new( 'tags' )
        @page_html = templater.render({
          'tag'           =>  @tag,
          'count'         =>  total_articles,
          :lists          =>  {
            'archived_article'  =>  articles,
            'tag'               =>  tags
          }
        })
      end
      Fallow::Dispatch.cache_headers( @page_html, recency )
    end
  end
end