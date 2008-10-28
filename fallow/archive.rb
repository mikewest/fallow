module Fallow
  class Archive

    def archived_items( year, month )
      if ( month.nil? )
        start_date, end_date  = Time.utc( year ), Time.utc( year+1 )
      else
        start_date  = Time.utc( year, month )
        end_date    = Time.utc( year + (month==12 ? 1 : 0), month==12 ? 1 : month+1 )
      end
      Fallow::Cache.get_archived_items( start_date, end_date )
    end

    def initialize( year = nil, month = nil )
      @year, @month = year, month
      @year         = @year.to_i unless @year.nil?
      @month        = @month.to_i unless @month.nil?
    end

    def render( caching_enabled = true )
      if @year.nil? && @month.nil?
        raise Fallow::RedirectTemp, '/'+Time.now.strftime('%Y')+'/'
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

        persist if caching_enabled

        @page_html
      end
    end

private
    def persist
      @path = "/#{@year}"
      @path += "/%02d" % [@month] unless @month.nil?

      # Don't persist current year, or current year/month:
      now = Time.now
      return if @path == now.strftime('/%Y') || @path == now.strftime('/%Y/%M')

      FileUtils.mkdir_p HTML_ROOT + @path
      html_filename = HTML_ROOT + @path + '/index.html'
      File.open( html_filename, 'w' ) { |f| f.write( @page_html ) }
    end
  end
end