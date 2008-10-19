module Fallow
  class Cache

    DB_FILE = DATA_ROOT + '/Fallow.sqlite3'
    
    def Cache.init!
      Cache.connect! unless Cache.connected?

      @@db.transaction do |db|
        
        sql = <<-SQL
          CREATE TABLE `articles` (
            `path`        TEXT PRIMARY KEY, 
            `published`   INTEGER,
            `modified`    INTEGER,
            `title`       TEXT,
            `slug`        TEXT,
            `oneline`     TEXT
          );
        
          CREATE TABLE `tags` (
            `normalized_tag`  TEXT PRIMARY KEY,
            `tag`             TEXT,
            `path`            TEXT
          );

        SQL
        db.execute_batch sql
      end
    end
    
    def Cache.drop!
      Cache.connect! unless Cache.connected?
      
      @@db.transaction do |db| 
        sql = <<-SQL
          DROP TABLE IF EXISTS `articles`;
          DROP TABLE IF EXISTS `tags`;
        SQL
        db.execute_batch sql
      end
    end
    
    def Cache.update_article( path, header )
      Cache.connect! if @@db.nil?
      
      @@db.transaction do |db|
        db.execute_batch(
          '
            DELETE FROM `articles` WHERE `path` = :path;
            DELETE FROM `tags`     WHERE `path` = :path;
          ',
          'path' => path
        )
        
        sql = <<-SQL
          INSERT INTO `articles` (
            `path`, `published`, `modified`, `title`, `slug`, `oneline`
          ) VALUES (
            :path, :published, :modified, :title, :slug, :oneline
          );
        SQL
        db.execute(
          sql,
          "path"      =>  path,
          "published" =>  header['Published'],
          "modified"  =>  header['Modified'],
          "title"     =>  header['Title'],
          "slug"      =>  header['Slug'],
          "oneline"   =>  header['OneLine']
        )
        sql = <<-SQL
          INSERT OR REPLACE INTO `tags` ( `tag`, `normalized_tag`, `path` ) VALUES ( :tag, :normalized, :path )
        SQL
        
        unless header['Tags'].nil?
          header['Tags'].each {|tag|
            db.execute(
              sql,
              'tag'         =>  tag,
              'normalized'  =>  Fallow.urlify( tag ),
              'path'        =>  path
            )
          }
        end
      end
      
      def Cache.get_article
        Cache.connect! unless Cache.connected?
        
        pp @@db.execute('SELECT * FROM `articles`')
        pp @@db.execute('SELECT * FROM `tags`')
      end
    end
    
private
    @@db = nil
    def Cache.connect!
      @@db = SQLite3::Database.new( DB_FILE )
      @@db.type_translation = true
    end
    def Cache.connected?
      ! @@db.nil?
    end
  end
end