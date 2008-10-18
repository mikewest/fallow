module Fallow
  class Article
    def initialize ( year, month, slug )
      @path     = "/#{year}/#{month}/#{slug}"
      @filename = ARTICLE_ROOT + "/#{@path}.markdown"
      @exists   = File.exist?( @filename )
      @header   = ''
      @body     = ''
      read_data if @exists
    end
    
    def exists?
      @exists
    end
    
    def render
      raise Fallow::NotFound unless @exists
      
      tags = []
      @header['Tags'].each {|tag|
        tags << { 'tag' => tag }
      }
      
      templater = Fallow::Template.new( 'article' )
      result = templater.render({
        'article_title' =>  @header['Title'],
        'article_body'  =>  Maruku.new(@body).to_html,
        'published'     =>  Time.at(@header['Published']).strftime('%B %d, %Y at %H:%M'),
        :lists          =>  {
          'article_tag' =>  tags
        }
      })
      result
    end
    
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
    
    private :read_data
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