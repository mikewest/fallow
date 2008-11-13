module Fallow
  class Template
    VALID_TEMPLATE_CHARS = '[A-Za-z0-9_\.]'
  
    def initialize( template_file = nil, template_root = TEMPLATE_ROOT )
      @template_root  = template_root
      self.load( template_file ) unless ( template_file.nil? )
    end
  
    def load( template_file )
      @template_file  = template_file
      @template       = load_template_file( @template_file )

      raise "#{template_file} isn't a valid template!" if ( @template.nil? )
      
      compile()
    end
  
    def render( replacements = { :lists => {} } )
      # Reasonable defaults
      replacements[:lists] = {} unless ( replacements.has_key?( :lists ) )
      
      #
      # Deal with `%string{default}%` replacements
      #
      @template = process_single_replacements( @template, replacements )
      #
      # Deal with `@include_multiple 'template'` replacements
      #
      @template.gsub!( %r{^@include_multiple\s+['"](#{VALID_TEMPLATE_CHARS}+)['"]\s*(?:\{([^\}]+)\})?$}o ) { |match|
        template, text = $1, $2
        if ( ! text.nil? )
          before, between, after = text.split( '|' )
        else
          before, between, after = '', '', ''
        end

        subtemplate = load_template_file( template )

        list_name = template.gsub(%r{\.[a-z]+$}, '')


        unless ( subtemplate.nil? || !replacements[:lists].has_key?( list_name ) )
          replacement_string = []
          replacements[:lists][list_name].each { |item|
            replacement_string << process_single_replacements( subtemplate, item )
          }

          before + replacement_string.join( between ) + after
        else
          nil
        end
      }
      @template
    end
  
    def to_s
      @template
    end
    
    def to_str
      self.to_s
    end
  
#
# Private Functions
#
    def compile
      @template.gsub!( %r{^@include\s+['"](#{VALID_TEMPLATE_CHARS}+)['"]\s*$}o ) { |match|
        to_include = load_template_file( $1 )
        if ( to_include.nil? )
          nil
        else
          to_include
        end
      }
    end
    def load_template_file( template_file )
      template_file = "#{template_file}.html" unless template_file =~ %r{\.[a-z]+$}
      template_file = "#{@template_root}/#{template_file}"
      if ( File.exist?( template_file ) )
        File.open( template_file ).read()
      else
        nil
      end
    end
    
    def process_single_replacements( text, replacements = {} )
      text = process_conditionals( text, replacements )
      
      
      replaced = text.gsub( %r{%([^%]+?)(?:\{([^%]+)\})?%} ) { |match|
        if ( replacements.has_key?( $1 ) )
          replacements[$1]
        elsif ( Fallow.const_defined?( $1.upcase ) )  
          Fallow.const_get( $1.upcase )
        elsif ( ! $2.nil? )
          $2
        else
          match
        end
      }
      replaced
    end
    
    def process_conditionals( text, replacements = {} )
      replaced = text.gsub( /^@if\s*\(([^)]+)\)\s*\{([^}]+)\}/ ) { |match|
        replace = false
        
        conditional = $1
        replacement = $2
        
        if ( conditional.match( /%([^%]+)%\s*==\s*(\S+)/ ) )
          replace = ( replacements.has_key?( $1 ) && replacements[$1] == $2)
        end

        replacement if replace
      }
    end
  
    private :compile, :load_template_file, :process_single_replacements
  end
end

if $0 == __FILE__
 
  require 'test/unit/assertions'
  include Test::Unit::Assertions
  
  templater = Fallow::Template.new( 'homepage', '/Users/mikewest/Repositories/Fallow/templates' )
  
  assert_not_nil templater

  templater.render({
    'STATIC_BASE_URL' =>  'http://static.mikewest.org',
    :lists            =>  {
      'recent_link'   =>  [
        {
          'title'   =>  'Geoffrey Grosenbach: "Beanstalk Messaging Queue"',
          'url'     =>  '#TODO_BEANSTALK',
          'summary' =>  'Geoffrey Grosenbach describes how to use Beanstalk (in Ruby) to implement a simple queuing mechanism for checking comments against Akismet in the background, asynchronous to the rails process that accepted the comment.'
        },
        {
          'title'   =>  'Beanstalkd',
          'url'     =>  '#TODO_BEANSTALK2',
          'summary' =>  'Queuing rapidly becomes a critical architectural decision when systems that receive and process data need to scale. Beanstalk looks like a solid implementation of the concept, with some great features and good buzz.'
        }
      ]
    }
  })
  
  puts templater
end