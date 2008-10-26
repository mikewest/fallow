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
          `published`   INTEGER,
          `title`       TEXT,
          `url`         TEXT,
          `desc`        TEXT
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
    def Cache.get_tagged_items( tag )
      Cache.get_tagged( tag )
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
            'INSERT OR IGNORE INTO `bookmarks` (`path`, `published`, `title`, `url`, `desc`) VALUES (:path, :published, :title, :url, :desc )',
            "path"      =>  path,
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
        when :articles: 'articles'
        when :bookmarks: 'bookmarks'
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
            title, published, path, summary as 'desc', '' as 'url', 'internal' as 'type'
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
            title, published, path, desc, url, 'external' as 'type'
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