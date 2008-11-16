module Fallow
  class Cache
    DB_FILE = DATA_ROOT + '/Fallow.sqlite3'

#
#   Generic Workflow Methods
#
    def Cache.init!
      Cache.connect! unless Cache.connected?

      sql = <<-SQL
        CREATE TABLE IF NOT EXISTS `articles` (
          `path`        TEXT PRIMARY KEY,
          `published`   INTEGER,
          `modified`    INTEGER,
          `title`       TEXT,
          `slug`        TEXT,
          `summary`     TEXT
        );
        
        CREATE TABLE IF NOT EXISTS `bookmarks` (
          `path`        TEXT PRIMARY KEY,
          `hash`        TEXT,
          `published`   INTEGER,
          `title`       TEXT,
          `url`         TEXT,
          `desc`        TEXT
        );

        CREATE TABLE IF NOT EXISTS `flickr_sets` (
          `path`        TEXT PRIMARY KEY,
          `published`   INTEGER,
          `url`         TEXT,
          `id`          NUMBER,
          `secret`      TEXT,
          `farm`        NUMBER,
          `primary`     NUMBER,
          `title`       TEXT,
          `desc`        TEXT
        );
        
        CREATE TABLE IF NOT EXISTS `tweets` (
          `path`          TEXT PRIMARY KEY,
          `published`     INTEGER,
          `desc`          TEXT,
          `url`           TEXT,
          `reply_to_id`   NUMBER,
          `reply_to_user` NUMBER
        );
      
        CREATE TABLE IF NOT EXISTS `tags` (
          `tag_id`          INTEGER PRIMARY KEY,
          `normalized_tag`  TEXT UNIQUE
        );
        
        CREATE TABLE IF NOT EXISTS `tag_mappings` (
          `tag_id`  INTEGER,
          `path`    TEXT
        );
        CREATE UNIQUE INDEX tagmap ON tag_mappings( tag_id, path );
      SQL
      Cache.db.execute_batch sql
    end
    
    def Cache.drop!
      Cache.connect! unless Cache.connected?
      
      sql = <<-SQL
        DROP TABLE IF EXISTS `articles`;
        DROP TABLE IF EXISTS `bookmarks`;
        DROP TABLE IF EXISTS `flickr_sets`;
        DROP TABLE IF EXISTS `tweets`;
        DROP TABLE IF EXISTS `tags`;
        DROP TABLE IF EXISTS `tag_mappings`;
      SQL
      Cache.db.execute_batch sql
    end

#
#   Generic Getters
#
    def Cache.get_recent_articles( num )
      Cache.get_recent(:articles, num)
    end
    def Cache.get_recent_bookmarks( num )
      Cache.get_recent(:bookmarks, num)
    end
    def Cache.get_recent_photosets( num )
      Cache.get_recent(:photosets, num)
    end
    def Cache.get_recent_tweets( num )
      Cache.get_recent(:tweets, num)
    end
    def Cache.get_tag_cloud_data()
      Cache.get_tag_counts()
    end
    def Cache.get_related_tags( tag, count = 10 )
      Cache.get_related(:tags, tag, count)
    end
    
    def Cache.get_tagged_items( tag )
      Cache.get_tagged( tag )
    end
    
    def Cache.get_archived_items( start_date, end_date )
      Cache.get_archived( start_date.to_i, end_date.to_i )
    end
    
#
#   Article Methods
#
    def Cache.update_article( path, header )
      Cache.connect! unless Cache.connected?

      Cache.db.transaction
        Cache.db.execute('DELETE FROM `articles` WHERE `path` = ?', path)
        Cache.db.execute('DELETE FROM `tag_mappings` WHERE `path` = ?', path)

        summary = Markdown.new( header['OneLine'], :smart ).to_html
        title   = Markdown.new( header['Title'], :smart ).to_html.gsub(%r{<p>(.+)</p>}) { |match| $1 }

        Cache.db.execute(
          'INSERT OR IGNORE INTO `articles` (`path`, `published`, `modified`, `title`, `slug`, `summary`) VALUES (:path, :published, :modified, :title, :slug, :summary )',
          "path"      =>  path,
          "published" =>  header['Published'],
          "modified"  =>  header['Modified'],
          "title"     =>  title,
          "slug"      =>  header['Slug'],
          "summary"   =>  summary
        )
        unless header['Tags'].nil?
          header['Tags'].each {|tag|
            tag = Fallow.urlify( tag )
            tag_id = Cache.get_tag_id( tag )
            Cache.db.execute( 'INSERT INTO `tag_mappings` (`tag_id`, `path`) VALUES ( ?, ? )', tag_id, path )
          }
        end
      Cache.db.commit
    end
    
    def Cache.update_bookmark( path, data )
      Cache.connect! unless Cache.connected?
      begin
        Cache.db.transaction
          Cache.db.execute( 'DELETE FROM `bookmarks`    WHERE `path` = ?', path )
          Cache.db.execute( 'DELETE FROM `tag_mappings` WHERE `path` = ?', path )
        
          title = Markdown.new( data['title'], :smart ).to_html.gsub(%r{<p>(.+)</p>}) { |match| $1 }
          desc = Markdown.new( data['desc'], :smart ).to_html
        
          Cache.db.execute(
            'INSERT OR IGNORE INTO `bookmarks` (`path`, `published`, `title`, `url`, `desc`, `hash`) VALUES (:path, :published, :title, :url, :desc, :hash )',
            "path"      =>  path,
            "hash"      =>  data['hash'],
            "published" =>  data['published'],
            "title"     =>  title,
            "url"       =>  data['url'],
            "desc"      =>  desc
          )
          unless data['tags'].nil?
            data['tags'].each {|tag|
              tag = Fallow.urlify( tag )
              tag_id = Cache.get_tag_id( tag )
              Cache.db.execute( 'INSERT OR IGNORE INTO `tag_mappings` (`tag_id`, `path`) VALUES ( ?, ? )', tag_id, path )
            }
          end
      
        Cache.db.commit
      rescue Exception => boom
        pp boom
      end
    end
   
    def Cache.update_flickr_set( path, data )
      Cache.connect! unless Cache.connected?
      begin
        Cache.db.transaction
          Cache.db.execute( 'DELETE FROM `flickr_sets` WHERE `path` = ?', path )

          title = Markdown.new( data['title'], :smart ).to_html.gsub(%r{<p>(.+)</p>}) { |match| $1 }
          desc = (data['desc'].nil?) ? '' : Markdown.new( data['desc'], :smart ).to_html

          Cache.db.execute(
            'INSERT OR IGNORE INTO `flickr_sets` (`path`, `published`, `title`, `url`, `desc`, `id`, `secret`, `farm`, `primary`) VALUES ( :path, :published, :title, :url, :desc, :id, :secret, :farm, :primary )',
            "path"      =>  path,
            "published" =>  data['published'].to_i,
            "title"     =>  title,
            "url"       =>  data['url'],
            "desc"      =>  desc,
            "id"        =>  data['id'].to_i,
            "secret"    =>  data['secret'],
            "farm"      =>  data['farm'].to_i,
            "primary"   =>  data['primary'].to_i
#            "photos"    =>  data['photos'].to_i
          )
        Cache.db.commit
      # rescue Exception => boom
      #   pp boom
      end
    end
    
    def Cache.update_tweet( path, data )
      Cache.connect! unless Cache.connected?
      begin
        Cache.db.transaction
          Cache.db.execute( 'DELETE FROM `tweets` WHERE `path` = ?', path )

          Cache.db.execute(
            'INSERT OR IGNORE INTO `tweets` (`path`, `published`, `desc`, `url`, `reply_to_id`, `reply_to_user` ) VALUES ( :path, :published, :desc, :url, :id, :user )',
            "path"      =>  path,
            "published" =>  data['published'],
            "url"       =>  data['url'],
            "desc"      =>  data['desc'],
            "id"        =>  data['reply_to_id'],
            "user"      =>  data['reply_to_user']
          )
        Cache.db.commit
      # rescue Exception => boom
      #   pp boom
      end
    end
    
private
    @@db  = nil

    def Cache.db
      @@db
    end

    def Cache.connect!
      begin
        @@db = SQLite3::Database.new( DB_FILE )
      rescue Exception => boom
        pp boom
      end
      @@db.type_translation = true
      @@db.results_as_hash  = true
    end
    
    def Cache.connected?
      ! Cache.db.nil?
    end

    def Cache.get_recent( type, num )
      Cache.connect! unless Cache.connected?
      table = case type
        when :articles:   'articles'
        when :bookmarks:  'bookmarks'
        when :photosets:  'flickr_sets'
        when :tweets:     'tweets'
        else 'articles'
      end
      
      sql = "SELECT * FROM #{table} ORDER BY published DESC LIMIT #{num};"
      Cache.db.execute( sql )
    end
    
    def Cache.get_tagged( tag )
      Cache.connect! unless Cache.connected?
      
      tag = Fallow.urlify( tag )
      sql = <<-SQL
          SELECT
            title, published, path, summary as 'desc', '' as 'url', '' as 'hash', 'internal' as 'type'
          FROM
            articles a
          WHERE
            a.path IN (
              SELECT
                tm.path as 'path'
              FROM
                tags t
                  JOIN
                    tag_mappings tm
                  ON
                    t.tag_id = tm.tag_id
              WHERE
                t.normalized_tag = :tag
            )
        UNION
          SELECT
            title, published, path, desc, url, hash, 'external' as 'type'
          FROM
            bookmarks b
          WHERE
            b.path IN (
              SELECT
                tm.path as 'path'
              FROM
                tags t
                  JOIN
                    tag_mappings tm
                  ON
                    t.tag_id = tm.tag_id
              WHERE
                t.normalized_tag = :tag
            )
          ORDER BY
            published DESC
      SQL
      Cache.db.execute(
        sql,
        'tag'  => tag
      )
    end
    
    def Cache.get_archived( start_date, end_date )
      Cache.connect! unless Cache.connected?
      
      sql = <<-SQL
          SELECT
            title, published, path, summary as 'desc', '' as 'url', '' as 'hash', 'internal' as 'type'
          FROM
            articles a
          WHERE
            published BETWEEN :start AND :end
        UNION
          SELECT
            title, published, path, desc, url, hash, 'external' as 'type'
          FROM
            bookmarks b
          WHERE
            published BETWEEN :start AND :end
        UNION
          SELECT
            title, published, path, desc, url, id as 'hash', 'flickr' as 'type'
          FROM
            flickr_sets f
          WHERE
            published BETWEEN :start AND :end
        ORDER BY
          published DESC
      SQL
      Cache.db.execute(
        sql,
        'start' => start_date,
        'end'   => end_date
      )
    end
    
    def Cache.get_related( type, index, count = 10 )
      Cache.connect! unless Cache.connected?
      
      if type === :tags
        sql = <<-SQL
          SELECT
              t.normalized_tag as tag
          FROM
              tag_mappings tm, tags t
          WHERE
              tm.path IN (
                  SELECT
                      tm.path
                  FROM
                      tag_mappings tm, tags t
                  WHERE
                      tm.tag_id = t.tag_id
                      AND
                      t.normalized_tag = :index
              )
              AND
              t.normalized_tag != :index
              AND
              t.tag_id = tm.tag_id
          GROUP BY tm.tag_id
          ORDER BY COUNT(tm.path) DESC
          LIMIT :count
        SQL
      end
      
      Cache.db.execute(
        sql,
        'index' =>  index.to_s,
        'count' =>  count.to_i
      )
    end
    
    def Cache.get_tag_counts()
      Cache.connect! unless Cache.connected?
      
      sql = <<-SQL
        SELECT
          t.normalized_tag as tag, COUNT(tm.path) as tag_count
        FROM
          tag_mappings tm, tags t
        WHERE
          t.tag_id = tm.tag_id
        GROUP BY tm.tag_id
        ORDER BY tag ASC
      SQL
      Cache.db.execute( sql )
    end
    
    def Cache.get_tag_id( tag, create = true )
      row  = Cache.db.get_first_value( 'SELECT `tag_id` FROM `tags` WHERE `normalized_tag` = ?', tag )
      if row.nil? && create
        Cache.db.execute( 'INSERT INTO `tags` ( `normalized_tag` ) VALUES ( ? )', tag )
        tag_id = Cache.db.last_insert_row_id
      else
        tag_id = row
      end
      tag_id
    end
    
  end
end