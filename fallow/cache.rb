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
          `oneline`     TEXT
        );
      
        CREATE TABLE IF NOT EXISTS `tags` (
          `tag_id`          INTEGER PRIMARY KEY,
          `normalized_tag`  TEXT UNIQUE
        );
        
        CREATE TABLE IF NOT EXISTS `tag_mappings` (
          `tag_id`  INTEGER,
          `path`    TEXT
        );

      SQL
      @@db.execute_batch sql
    end
    
    def Cache.drop!
      Cache.connect! unless Cache.connected?
      
      sql = <<-SQL
        DROP TABLE IF EXISTS `articles`;
        DROP TABLE IF EXISTS `tags`;
        DROP TABLE IF EXISTS `tag_mappings`;
      SQL
      @@db.execute_batch sql
    end
#
#   Article Methods
#
    def Cache.update_article( path, header )
      Cache.connect! unless Cache.connected?

      @@db.transaction
        insert_article = @@db.prepare( 'INSERT OR IGNORE INTO `articles` (`path`, `published`, `modified`, `title`, `slug`, `oneline`) VALUES (:path, :published, :modified, :title, :slug, :oneline )' )
        map_tag        = @@db.prepare( 'INSERT INTO `tag_mappings` (`tag_id`, `path`) VALUES ( ?, ? )' )
      
        @@db.execute('DELETE FROM `articles` WHERE `path` = ?', path)
        @@db.execute('DELETE FROM `tag_mappings` WHERE `path` = ?', path)

        insert_article.execute(
          "path"      =>  path,
          "published" =>  header['Published'],
          "modified"  =>  header['Modified'],
          "title"     =>  header['Title'],
          "slug"      =>  header['Slug'],
          "oneline"   =>  header['OneLine']
        )
        unless header['Tags'].nil?
          header['Tags'].each {|tag|

            tag = Fallow.urlify( tag )
            tag_id = Cache.get_tag_id( tag )
            map_tag.execute( tag_id, path )
          }
        end
      
        insert_article.close
        map_tag.close
      @@db.commit
    end
    
    def Cache.how_many
      Cache.connect! unless Cache.connected?
      @@db.transaction
        num_articles = @@db.get_first_value('SELECT COUNT(*) FROM `articles`')
        num_tags     = @@db.get_first_value('SELECT COUNT(*) FROM `tags`')
        num_mappings = @@db.get_first_value('SELECT COUNT(*) FROM `tag_mappings`')
      @@db.commit
      p "Articles: #{num_articles}, Tags: #{num_tags}, Mappings: #{num_mappings}"
    end
    
    def Cache.all_done
      @@db.close
    end
    
private
    @@db              = nil

    def Cache.connect!
      @@db = SQLite3::Database.new( DB_FILE )
      @@db.type_translation = true
      @@db.results_as_hash  = true
    end

    
    def Cache.connected?
      ! @@db.nil?
    end

    
    def Cache.get_tag_id( tag )
      get_tag_id  = @@db.prepare( 'SELECT `tag_id` FROM `tags` WHERE `normalized_tag` = ?' )
      insert_tag  = @@db.prepare( 'INSERT INTO `tags` ( `normalized_tag` ) VALUES ( ? )' )
      
      rows  = get_tag_id.execute( tag )
      row   = rows.next
      if row.nil?

        insert_tag.execute( tag )
        tag_id = @@db.last_insert_row_id
      else
        tag_id = row['tag_id']
      end

      get_tag_id.close
      insert_tag.close

      tag_id
    end
    
  end
end