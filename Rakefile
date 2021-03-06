require 'rake/clean'
require 'find'
require 'fallow'
require 'uri'

ROOT_DIR        = File.expand_path(File.dirname(__FILE__))
DATA_ROOT       = ROOT_DIR + '/data'
ARTICLE_ROOT    = DATA_ROOT + '/articles'
EXTERNALS_ROOT  = DATA_ROOT + '/externals'

THIN_INSTANCES  = 2
THIN_SOCKETS    = '/tmp/mikewestorg.sock'

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

  desc "Render and cache Homepage"
  task :populate_homepage do
    puts "Rendering homepage"
    Fallow::Homepage.new().render
  end

  desc "Render and cache articles."
  task :populate_articles => [:reset_db] do
    puts "Rendering and caching articles."
    Find.find( ARTICLE_ROOT ) do |entry|
      if File.file?(entry) && entry.match(%r{/(\d{4})/(\d{2})/([0-9A-Za-z_\-]+)\.markdown$})
        puts "   *   Rendering /#{$1}/#{$2}/#{$3}\n"
        Fallow::Article.new( $1, $2, $3 ).render
      end
    end
  end
  
  desc "Cache del.icio.us bookmarks."
  task :populate_delicious => [:reset_db] do
    puts "Caching del.icio.us bookmarks.\n"
    Fallow::Bookmarks.update_cache!
  end
  
  desc "Cache archive pages"
  task :populate_archive do
    # Don't cache current year, or year/month
    now         = Time.now
    year, month = Time.now.strftime('%Y'), Time.now.strftime('%m')
    
    directories = Dir[ ARTICLE_ROOT + '/**/' ]
    directories.each { |dir|
      if dir.match(%r{/(\d{4})/(?:(\d{2})/)?})
        p "Publishing year: #{$1}, month: #{$2}" unless ( $1 == year ) && ( $2.nil? || $2 == month )
        Fallow::Archive.new( $1, $2 ).render unless ( $1 == year ) && ( $2.nil? || $2 == month )
      end
    }
  end
  
  task :populate_twitter do
    Fallow::Twitter.update_cache!
  end
  
  task :populate_flickr do
    Fallow::Flickr.update_cache!
  end
  
  task :sync_twitter do
    Fallow::Twitter.get_tweets!
  end
  
  task :sync_delicious do
    Fallow::Bookmarks.sync!
  end
  
  task :sync_flickr do
    Fallow::Flickr.get_set_list!
  end
  
  task :homepage do
    Fallow::Homepage.new.render()
  end

  task :populate => [:reset_db, :populate_articles, :populate_delicious, :populate_twitter, :populate_flickr, :populate_archive, :populate_homepage]
  
  task :sync => [:sync_delicious, :sync_flickr, :sync_twitter]

#
#   Git Tasks
#
  desc 'Revert to git HEAD'
  task :reset_git do
    sh "git reset --hard"
  end
  
#
#   Static Tasks
#
  desc 'Prezip statics'
  task :rezip_statics do
    
  end

#
#   Server Tasks
#
  desc 'Reset Thin server'
  task :restart_thin => [:remove_logs] do
    `thin stop --pid #{ROOT_DIR}/pids/thin.0.pid`
    `thin stop --pid #{ROOT_DIR}/pids/thin.1.pid`
    sh "thin start -R #{ROOT_DIR}/rackup.ru -s#{THIN_INSTANCES} --socket #{THIN_SOCKETS} --log #{ROOT_DIR}/log/thin.log --pid #{ROOT_DIR}/pids/thin.pid"
  end
  
  desc 'Remove Thin logs'
  task :remove_logs do
    `rm #{ROOT_DIR}/log/thin.*.log;`
  end

  task :rethin => [:restart_thin, :remove_logs]

  desc 'Start lobster locally'
  task :lobster do
    `rackup -Ilib #{ROOT_DIR}/rackup.ru`
  end

#
#   Log Tasks
#
  desc 'Dump the log'
  task :log do
    sh 'cat #{ROOT_DIR}/log/thin.*.log'
  end

#
#   Wrapup Task
#
desc 'Reset Everything'
task :reset => [:reset_git, :rezip_statics, :reset_db, :populate, :rethin]
