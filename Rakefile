require 'rake/clean'
require 'fallow'

ROOT_DIR = File.expand_path(File.dirname(__FILE__))
DATA_ROOT = ROOT_DIR + '/data'

#
#   Database Tasks
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
    sh 'thin start -R /home/mikewest/public_html/synergistically.de/private/rackup.ru -s1 --socket /tmp/thin.sock;'
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
