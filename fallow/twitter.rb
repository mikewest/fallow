module Fallow
  TWITTER_ROOT  = EXTERNALS_ROOT  + '/twitter'

  class Tweet
    def initialize( data = nil )
      return nil if data.nil?
      
      @data = data
      
      @data['id']             = @data['id'].to_i || 0
      @data['reply_to_id']    = @data['reply_to_id'].to_i || 0
      @data['reply_to_user']  = @data['reply_to_user'].to_i || 0
      
      @data['published']      = if @data['published'].is_a?(String)
                                  Time.parse( @data['published'] )
                                else
                                  Time.at( @data['published'] )
                                end.to_i

      @data['desc']           = htmlize_raw_desc!
      @data['url']            = "http://twitter.com/#{ Twitter::username }/statuses/#{ @data['id'] }"
    end

    def htmlize_raw_desc!
      return '' if @data['raw_desc'].nil?
      
      @data['desc'] = @data['raw_desc'].gsub(%r{ (http[s]?://[-a-z.]+?\.[a-z]+/\S*?) (?:\s|$) }xi ) { |match|
        "<a href='#{ $1 }'>#{ $1 }</a>"
      }.gsub( %r{ (?:^|\s) @ ([-a-z0-9_]+) }xi ) { |match|
        "<a href='http://twitter.com/#{ $1.downcase }/'>@#{ $1 }</a>"
      }
    end

    def path
      "/twitter/#{ @data['id'] }"
    end

    def to_hash
      @data
    end

    def to_yaml
      @data.to_yaml
    end

    def persist( to_disk = true )
        Fallow::Cache.update_tweet( self.path, self.to_hash )
      
        if to_disk
          filename = EXTERNALS_ROOT + self.path + '.yaml'
          File.open( filename, 'w' ) { |f| f.write( self.to_yaml ) }
        end
    end

    def Tweet.from_file( filename )
      raise Fallow::NotFound unless File.exist?( filename )
      
      data = File.open( filename ) { |yf| YAML::load( yf ) }
      Tweet.new( data )
    end

    def Tweet.exists?( id )
      filename = TWITTER_ROOT + "/#{ id }.yaml"
      File.exists?( filename )
    end
  end
  
  
  class Twitter
    def Twitter.username
      Kernel::load( ROOT_DIR + '/fallow.conf' )
      @@user_id
    end
    
    def Twitter.get_tweets!
      require 'net/https'
      require 'rexml/document'
      
      http = Net::HTTP.new('twitter.com', 80)

      begin
        res = http.start do |http|
          req = Net::HTTP::Get.new("/statuses/user_timeline/#{ Twitter.username }.xml", 'User-Agent' => 'Fallow/0.01a')
          http.request(req)
        end
        tweets = REXML::Document.new( res.body )
      rescue  Timeout::Error, Errno::EINVAL, Errno::ECONNRESET, 
              EOFError, Net::HTTPBadResponse, Net::HTTPHeaderSyntaxError, 
              Net::ProtocolError, REXML::ParseException
        tweets = REXML::Document.new('')
      end
      
      tweets.elements.each('statuses/status') do |tweet|
        data = tweet.elements
        
        next if Tweet.exists?( data['id'].text )
        
        tweet_data  = Tweet.new({
          'id'            =>  data['id'].text,
          'published'     =>  data['created_at'].text,
          'raw_desc'      =>  data['text'].text,
          'desc'          =>  data['text'].text,
          'reply_to_id'   =>  data['in_reply_to_status_id'].text,
          'reply_to_user' =>  data['in_reply_to_user_id'].text
        })
        tweet_data.persist
      end
    end

    def Twitter.update_cache!
      require 'find'
      Find.find( TWITTER_ROOT ) do |tweet|
        if File.file?(tweet) && tweet.match(%r{/(\d+).yaml$})
          puts "Rendering /twitter/#{$1}\n"
          Tweet.from_file( tweet ).persist( false )
        end
      end
    end
    
  end
end