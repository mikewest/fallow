require 'rake/clean'
require 'find'
require 'fallow'

ROOT_DIR      = File.expand_path(File.dirname(__FILE__))
DATA_ROOT     = ROOT_DIR + '/data'
ARTICLE_ROOT  = DATA_ROOT + '/articles'
#
#   Cache Tasks
#

  desc  'Create DB for cache'
  task :init do
    Fallow::Cache.init!
  end
  
  desc 'Drop cache DB'
  task :drop do
    Fallow::Cache.drop!
  end
 
  task :reset_db => [ :drop, :init ]

  task :populate => [:reset_db] do
    Find.find( ARTICLE_ROOT ) do |entry|
      if File.file?(entry) && entry.match(%r{/(\d{4})/(\d{2})/([0-9A-Za-z_\-]+)\.markdown$})
        puts "Rendering /#{$1}/#{$2}/#{$3}\n"
        Fallow::Article.new( $1, $2, $3 ).render
      end
    end
  end

#
#   Git Tasks
#
  desc 'Revert to git HEAD'
  task :reset_git do
    sh "git reset --hard"
  end
  
#
#   Server Tasks
#
  desc 'Reset Thin server'
  task :restart_thin => [:remove_logs] do
    sh 'killall thin;'
    sh "thin start -R #{ROOT_DIR}/rackup.ru -s1 --socket /tmp/thin.sock;"
  end
  
  desc 'Remove Thin logs'
  task :remove_logs do
    sh 'rm ./log/thin.0.log;'
  end

  task :rethin => [:restart_thin, :remove_logs]

#
#   Log Tasks
#
  desc 'Dump the log'
  task :log do
    sh 'cat ./log/thin.0.log'
  end

#
#   Wrapup Task
#
desc 'Reset Everything'
task :reset => [:reset_git, :reset_db, :rethin]
