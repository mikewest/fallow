module Fallow
  class Article
    def initialize ( year, month, slug )
      @path       = "/#{year}/#{month}/#{slug}"
      @filename   = ARTICLE_ROOT + "/#{@path}.markdown"
      @exists     = File.exist?( @filename )
      @header     = ''
      @body       = ''
      read_data if @exists
    end
    
    def exists?
      @exists
    end
    
    def render( caching_enabled = true )
      raise Fallow::NotFound unless @exists
      
      unless @header['Tags'].nil?
        tags = []
        @header['Tags'].each {|tag|
          tags << { 'tag' => tag, 'normalized_tag' => Fallow.urlify( tag ) }
        }
        tags = { 'article_tag' => tags }
      else
        tags = {}
      end
      
      markdown = Markdown.new( @body, :smart )
      @body_html = markdown.to_html
      
      templater = Fallow::Template.new( 'article' )
      @page_html = templater.render({
        'article_title' =>  @header['Title'],
        'article_body'  =>  @body_html,
        'published'     =>  Time.at(@header['Published']).strftime('%B %d, %Y at %H:%M'),
        :lists          =>  tags
      })
      
      persist if caching_enabled
      
      @page_html
    end

private
    
    def read_data
      in_header = true;
      File.open( @filename ).each {|line|
        if ( in_header )
          @header += line
          in_header = false if ( line =~ /^\.\.\.$/)
        else
          @body += line
        end
      }
      @header = YAML::load( @header )
    end
    
    def persist
      Fallow::Cache.update_article( @path, @header )
      
      FileUtils.mkdir_p HTML_ROOT + @path
      html_filename = HTML_ROOT + @path + '/index.html'
      File.open( html_filename, 'w' ) { |f| f.write( @page_html ) }
    end
    

  end
end

if $0 == __FILE__
  require 'yaml'
  require 'pp'
  require '../fallow'
  # article = Fallow::Article.new('2005', '03', 'component-encapsulation-using-object-oriented-javascript')
  #   pp article.render
  
  article = Fallow::Article.new('2009', '01', 'this-article-doesnt-exist')
  pp article.render
end