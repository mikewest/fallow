#!/usr/bin/env ruby -wKU

require 'fallow'

app = Rack::Builder.new {
  use Rack::Lint 
  run Fallow.new 
} 

run app