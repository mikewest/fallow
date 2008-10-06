#!/usr/bin/env ruby -wKU

%w(fileutils stringio time rubygems maruku).each { |lib| require lib }

module Fallow
  ROOT_DIR  = File.expand_path(File.dirname(__FILE__))
  DATA_DIR  = ROOT_DIR + '/data';
  
  autoload :Request   'fallow/request'
  
  autoload :Article   'fallow/article'
  autoload :Archive   'fallow/archive'
  autoload :Homepage  'fallow/homepage'


  autoload :ErrorPage 'fallow/error'
end