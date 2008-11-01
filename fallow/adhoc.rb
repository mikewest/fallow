module Fallow
  class AdHoc
    def initialize ( path )
      @path = path
      raise Fallow::NotFound unless exists?
      
      read_data
    end
    def render( caching_enabled = true)
      templater = Fallow::Template.new( 'adhoc' )
      @page_html = templater.render({
        'title'     =>  @title,
        'body'      =>  @body_html,
        'adhoc_id'  =>  Fallow.urlify( @path )
      })
      
      persist if caching_enabled
      
      [ @page_html, { 'Content-Type' => "text/html; charset=UTF-8" } ]
    end

    def exists?
      @filename   = ADHOC_ROOT + "#{@path}"
      @filename  += '/index.markdown' if @filename.match(%r{([^\.]|/$)})
      @filename.gsub!(%r{/+}, '/')
      
      @exists     = File.exist?( @filename )
    end

private

    def read_data
      @title = ''
      @body  = ''
      File.open( @filename ).each {|line|
        @title = line if @title.empty?
        @body += line
      }
      markdown = Markdown.new( @body, :smart )
      @body_html = markdown.to_html
    end

    def persist
      stripped_path = @path.gsub(%r{/([^/]+\.[^/]+)?$}, '')
      indexed_path  = ( @path.match( %r{[a-zA-Z0-9_-]+\.[a-zA-Z0-9_-]+$} ) ) ? @path : @path+'/index.html'
      indexed_path.gsub!(%r{/+}, '/')
      
      FileUtils.mkdir_p HTML_ROOT + stripped_path
      html_filename = HTML_ROOT + indexed_path
      File.open( html_filename, 'w' ) { |f| f.write( @page_html ) }
    end
  end
end