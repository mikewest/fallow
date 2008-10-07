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
end