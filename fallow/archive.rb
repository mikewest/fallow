module Fallow
  class Archive
    
    def archived_items( year, month )
      if ( @month.nil? )
        start_date  = Time.utc( year )
        end_date    = Time.utc( year+1 )
      else
        start_date  = Time.utc( year, month )
        end_date    = Time.utc( year + (month==12 ? 1 : 0), month==12 ? 1 : month+1 )
      end
      Fallow::Cache.get_archived_items( start_date, end_date )
    end

    def initialize( year = nil, month = nil )
      @year   = year
      @year   = @year.to_i unless @year.nil?
      @month  = month
      @month  = @month.to_i unless @month.nil?
    end

    def render
      if @year.nil? && @month.nil?
        raise Fallow::NotFound
        # TODO: Archive landing page
      else
        articles = archived_items( @year, @month ).each {|item|
          item['url'] = item['path'] if item['type'] == 'internal'
          item['published'] = Time.at(item['published'].to_i).strftime('%B %d, %Y')
        }

        if ( @month.nil? )
          title = @year.to_s
        else
          title = Time.utc(@year, @month).strftime('%B, %Y')
        end

        templater = Fallow::Template.new( 'archive' )
        @page_html = templater.render({
          'year_month'    =>  title,
          :lists          =>  {
            'archived_article'  =>  articles,
          }
        })
      
        @page_html
      end
    end
  end
end