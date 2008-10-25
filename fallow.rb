#!/usr/bin/env ruby -wKU

%w(fileutils stringio time rubygems rdiscount rack thin pp yaml fileutils sqlite3).each { |lib| require lib }



module Fallow
  extend self
  
  #
  # Exciting configuration constants
  #
  ROOT_DIR        = File.expand_path(File.dirname(__FILE__))
  DATA_ROOT       = ROOT_DIR + '/data'
  ARTICLE_ROOT    = DATA_ROOT + '/articles'
  EXTERNALS_ROOT  = DATA_ROOT + '/externals'
  TEMPLATE_ROOT   = ROOT_DIR + '/templates'
  HTML_ROOT       = ROOT_DIR + '/../public'
  
  PUBLIC_ROOT   = ''
  STATIC_ROOT   = '/static'
  

  ARCHIVE_ROOT  = PUBLIC_ROOT + '/archive'
  TAGS_ROOT     = PUBLIC_ROOT + '/tags'
  
  #
  #   Core Components
  #
  autoload :Dispatch,   'fallow/dispatch'
  autoload :Template,   'fallow/template'
  autoload :Cache,      'fallow/cache'  
  autoload :Bookmarks,  'fallow/bookmarks'
  #
  #   Page types
  #
  autoload :Article,    'fallow/article'
  autoload :Archive,    'fallow/archive'
  autoload :Homepage,   'fallow/homepage'
  autoload :ErrorPage,  'fallow/error'



#
# String Functions
#
  def urlify( the_string )
    url = the_string.clone
    url.downcase!
    url.gsub!(/\s+/, '-')
    url.gsub!(/[^a-z0-9_\-]/, '')
    url
  end

#
# Logging
#
  def log( message )
    Thin::Logging.log( message )
  end

#
# Potential Error States
#
  class NotFound < Exception
  end
  class ServerError < Exception
  end
  
#
# Constructor (for rackup application start)
#
  def new
    Fallow::Dispatch.new 
  end
  
end