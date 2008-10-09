#!/usr/bin/env ruby -wKU

%w(fileutils stringio time rubygems maruku rack thin).each { |lib| require lib }

Thin::Logging.silent = false;

module Fallow
  ROOT_DIR  = File.expand_path(File.dirname(__FILE__))
  DATA_DIR  = ROOT_DIR + '/data'
  
  
  autoload :Dispatch,   'fallow/dispatch'
  
  autoload :Article,    'fallow/article'
  autoload :Archive,    'fallow/archive'
  autoload :Homepage,   'fallow/homepage'

  autoload :Template,   'fallow/template'

  autoload :ErrorPage,  'fallow/error'

  def request_for(path, &block)
    URI_COMPONENTS = {
      :year   => '\d{4}',
      :month  => '\d{2}',
      :slug   => '[0-9A-Za-z-_]+'
    }
    path.each { |path|
      URI.encode(path)
    }
  end

#
# Potential Page Types (vaguely like Sinatra)
#
  request_for ['/'] {
    # Homepage
  }
  
  request_for ['/:year/:month/:slug/?'] {
    # Article
  }
  
  request_for ['/archive/','/archive/:year/?'] {
    # Archive
  }
  
#
# Potential Error States
#
  class NotFound < Exception
  end
end