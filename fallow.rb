#!/usr/bin/env ruby -wKU

%w(fileutils stringio time rubygems maruku rack thin pp yaml fileutils sqlite3).each { |lib| require lib }

module Fallow
  ROOT_DIR      = File.expand_path(File.dirname(__FILE__))
  DATA_ROOT     = ROOT_DIR + '/data'
  TEMPLATE_ROOT = ROOT_DIR + '/templates'
  ARTICLE_ROOT  = DATA_ROOT + '/articles'
  HTML_ROOT     = ROOT_DIR + '/../public'
  
  PUBLIC_ROOT   = ''
  STATIC_ROOT   = '/static'
  

  ARCHIVE_ROOT  = PUBLIC_ROOT + '/archive'
  TAGS_ROOT     = PUBLIC_ROOT + '/tags'
  
  autoload :Dispatch,   'fallow/dispatch'
  
  autoload :Article,    'fallow/article'
  autoload :Archive,    'fallow/archive'
  autoload :Homepage,   'fallow/homepage'

  autoload :Template,   'fallow/template'

  autoload :ErrorPage,  'fallow/error'

  autoload :Cache,      'fallow/cache'

#
# String Functions
#
  def Fallow.urlify( the_string )
    url = the_string.clone
    url.downcase!
    url.gsub!(/\s+/, '-')
    url.gsub!(/[^a-z0-9_\-]/, '')
    url
  end

#
# Logging
#
  def Fallow.log( message )
    Thin::Logging.log( message )
  end

#
# Potential Error States
#
  class NotFound < Exception
  end
  class ServerError < Exception
  end
end