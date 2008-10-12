#!/usr/bin/env ruby -wKU

%w(fileutils stringio time rubygems maruku rack thin).each { |lib| require lib }

Thin::Logging.silent = false;

module Fallow
  ROOT_DIR      = File.expand_path(File.dirname(__FILE__))
  DATA_ROOT     = ROOT_DIR + '/data'
  TEMPLATE_ROOT = ROOT_DIR + '/templates'
  
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

#   def request_for(path, &block)
#     uri_component = /(?::(\w+))/
#     uri_components = {
#       :year   => '\d{4}',
#       :month  => '\d{2}',
#       :slug   => '[0-9A-Za-z-_]+'
#     }
#     path.each { |path|
#       path.gsub( uri_component ) { |match|
#         
#       }
#     }
#   end
# 
# #
# # Potential Page Types (vaguely like Sinatra)
# #
#   request_for ['/'] do
#     # Homepage
#   end
#   
#   request_for ['/:year/:month/:slug/?'] do
#     # Article
#   end
#   
#   request_for ['/:year/?','/:year/:month/?'] do
#     raise Redirect
#   end
#   
#   request_for ['/archive/?','/archive/:year/?','/archive/:year/:month/?'] do
#     # Archive
#   end
  
#
# Potential Error States
#
  class NotFound < Exception
  end
end