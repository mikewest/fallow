#!/usr/bin/env ruby -wKU

require 'fallow'

run Rack::Builder.new {
  use Rack::Lint 
  Fallow.new 
}