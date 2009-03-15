module Fallow
  class ErrorPage
    def render ( request, error_code = nil )
      @path = request.path_info
      
      redirect_url = redirect?
      raise Fallow::RedirectPerm, redirect_url unless redirect_url.nil?
      
      templater = Fallow::Template.new( 'error' )

      error_code ||= 500;

      error_messages = {
        403 => "<p>Oi!  Quit poking around in these here <em>forbidden</em> pages!</p>",
        404 => "<p>You&rsquo;ve found a nonexistant page!  That&rsquo;s a sign of luck in many cultures, you know... Just not <em>this</em> one.  Too bad!  In an ideal world, I'd try to figure out what it is that you were expecting to find by intelligently parsing the URL for keywords and such, but I haven&rsquo;t gotten around to writing that code yet.  Sorry!</p>",
        500 => "<p>Oh my, a server error!  That&rsquo;s not good at all.  It either means that you&rsquo;re being naughty, or I&rsquo;m being a crap programmer.  Odds are high for both.</p>"
      }
      error_message   = error_messages.has_key?( error_code ) ? error_messages[ error_code ] : error_messages[ 500 ]
      error_message  += '<p>But hey! Since you&rsquo;re here, why not visit <a href="/">the homepage</a> to see what I&rsquo;ve been up to recently, or <a href="/archive/">the archive</a> for older articles and links?</p>'

      if request.GET.has_key?('debug')
        debug = '<h3>Environment</h3><ul>'
        request.env.each { |key,value|
          debug += "<li><strong>#{key.to_s}</strong> => #{value.to_s}</li>"
        }
        debug += '</ul>'
      
        debug += '<h3>Fallow State</h3><ul>'
        Fallow.constants.each { |const|
          debug += "<li><strong>#{const}</strong> => #{Fallow.const_get(const)}</li>"
        }
        debug += '</ul>'
      else
        debug = '<!-- No debug data.  Soz. -->'
      end
      
      templater = Fallow::Template.new( 'error' )
      result = templater.render({
        'error_code'    =>  error_code,
        'error_message' =>  error_message,
        'debug_data'    =>  debug
      })
      result  += Fallow::Dispatch.timer_comment
      Rack::Response.new( result, error_code ).finish
    end
    
private

    def redirect?
#
#   Resume
#
      if @path.match(%r{^/resume})
        raise Fallow::RedirectTemp, "#{STATIC_ROOT}/resume.pdf"
#
#   About
#
      elsif @path.match(%r{^/about}) || @path.match(%r{^/contact}) || @path.match(%r{^/bio})
        '/is'
#
#   PerfectTime
#
      elsif @path.match(%r{^/projects/files/Perfect})
        'https://github.com/mikewest/perfecttime/tree'

#
#   DataRequestor
#
      elsif @path.match(/datarequestor/i) || @path.match(%r{^/projects})
        'https://github.com/mikewest/datarequestor/tree'

#
#    Old Feed URL
#
      elsif @path.match(%r{^/rss})
        'http://feeds.mikewest.org/just_posts'
#
#    Index.php
#
      elsif @path.match(%r{^/index})
        '/'
#
#   Old File Downloads
#
      elsif @path.match(%r{^/file_download/(\d+)})
        case $1.to_i
          when 1:     'https://github.com/mikewest/datarequestor/tree'
          when 2:     '/resume'
          when 3..4:  'https://github.com/mikewest/mcw_templates/tree'
          when 5..8:  '/'
          when 9..10: 'https://github.com/mikewest/datarequestor/tree'
        end
                      

#
#   Old articles
#
      elsif @path.match(%r{^/archive})
        case @path
          when '/archive/gently-abandoning-dead-to-me-projects': '/2008/10/gently-abandoning-dead-to-me-projects'
          when '/archive/auto-configuring-proxy-settings-with-a-pac-file': '/2007/01/auto-configuring-proxy-settings-with-a-pac-file'
          when '/archive/microformats-on-kelkoo': '/2008/03/microformats-on-kelkoo'
          when '/archive/accessibility-tips-from-mike-davies': '/2008/03/accessibility-tips-from-mike-davies'
          when '/archive/safegarding-your-data-with-parchive': '/2008/01/safegarding-your-data-with-parchive'
          when '/archive/carlos-launched-escaloop': '/2008/01/carlos-launched-escaloop'
          when '/archive/innovation-and-interoperability': '/2007/12/innovation-and-interoperability'
          when '/archive/dns-made-easy-is-actually-pretty-easy': '/2007/12/dns-made-easy-is-actually-pretty-easy'
          when '/archive/solving-strange-text-wrapping-problems-in-bash': '/2007/12/solving-strange-text-wrapping-problems-in-bash'
          when '/archive/now-i-have-a-colourful-bash-prompt': '/2007/12/now-i-have-a-colourful-bash-prompt'
          when '/archive/presentation-love-the-terminal': '/2007/12/presentation-love-the-terminal'
          when '/archive/photoset-media-ajax': '/2007/11/photoset-media-ajax'
          when '/archive/just-back-from-london': '/2007/11/just-back-from-london'
          when '/archive/looking-forward-to-media': '/2007/11/looking-forward-to-media'
          when '/archive/goodbye-grandmom': '/2007/08/goodbye-grandmom'
          when '/archive/playing-with-pownce': '/2007/07/playing-with-pownce'
          when '/archive/viva-la-y-french-news-site': '/2007/07/viva-la-y-french-news-site'
          when '/archive/congrats-to-the-singapore-news-team': '/2007/07/congrats-to-the-singapore-news-team'
          when '/archive/two-more-news-relaunches-up-and-running': '/2007/06/two-more-news-relaunches-up-and-running'
          when '/archive/i-am-a-super-early-bird-are-you': '/2007/06/i-am-a-super-early-bird-are-you'
          when '/archive/escaping-curly-braces-in-xslt-attributes': '/2007/06/escaping-curly-braces-in-xslt-attributes'
          when '/archive/ice-water-for-some': '/2007/06/ice-water-for-some'
          when '/archive/short-form-link-blogging': '/2007/06/short-form-link-blogging'
          when '/archive/home-again-home-again': '/2007/05/home-again-home-again'
          when '/archive/stupid-i18n-mistake': '/2007/05/stupid-i18n-mistake'
          when '/archive/how-do-i-unit-test-a-website': '/2007/05/how-do-i-unit-test-a-website'
          when '/archive/words-escape-me': '/2007/05/words-escape-me'
          when '/archive/my-bookmarks-are-amazingly-out-of-date': '/2007/05/my-bookmarks-are-amazingly-out-of-date'
          when '/archive/domain-transfer': '/2007/05/domain-transfer'
          when '/archive/es-vivo': '/2007/05/es-vivo'
          when '/archive/stopgap-solution': '/2007/05/stopgap-solution'
          when '/archive/i-used-to-be-so-pretty': '/2007/04/i-used-to-be-so-pretty'
          when '/archive/fun-apple-remote-tricks': '/2007/04/fun-apple-remote-tricks'
          when '/archive/just-the-stats': '/2007/04/just-the-stats'
          when '/archive/amazingly-stupid-datarequestor-bug': '/2007/04/amazingly-stupid-datarequestor-bug'
          when '/archive/installing-libgd-from-source-on-os-x': '/2007/04/installing-libgd-from-source-on-os-x'
          when '/archive/its-live': '/2007/04/its-live'
          when '/archive/datarequestor-1-dot-6': '/2007/02/datarequestor-1-dot-6'
          when '/archive/signs-of-life': '/2007/01/signs-of-life'
          when '/archive/benchmarking-your-site-with-http_load': '/2007/01/benchmarking-your-site-with-http_load'
          when '/archive/subversion-143': '/2007/01/subversion-143'
          when '/archive/locking-your-mac': '/2007/01/locking-your-mac'
          when '/archive/auto-configuring-proxy-settings-with-a-pac-file': '/2007/01/auto-configuring-proxy-settings-with-a-pac-file'
          when '/archive/installing-textpattern-with-markdown': '/2007/01/installing-textpattern-with-markdown'
          when '/archive/setting-up-an-openid-server-with-phpmyid': '/2007/01/setting-up-an-openid-server-with-phpmyid'
          when '/archive/iwant': '/2007/01/iwant'
          when '/archive/using-yui-in-greasemonkey-scripts': '/2007/01/using-yui-in-greasemonkey-scripts'
          when '/archive/frohe-weihnachten': '/2006/12/frohe-weihnachten'
          when '/archive/building-sshkeychain-as-an-intel-binary': '/2006/12/building-sshkeychain-as-an-intel-binary'
          when '/archive/building-subversion-for-os-x': '/2006/12/building-subversion-for-os-x'
          when '/archive/starting-out-with-the-svk-version-control-system': '/2006/10/starting-out-with-the-svk-version-control-system'
          when '/archive/comments-with-specificity': '/2006/10/comments-with-specificity'
          when '/archive/apartments-in-munich': '/2006/10/apartments-in-munich'
          when '/archive/backing-up-e-mail': '/2006/10/backing-up-e-mail'
          when '/archive/anatomy-of-a-technical-interview-part-i': '/2006/09/anatomy-of-a-technical-interview-part-i'
          when '/archive/serverless-svn-repositories': '/2006/09/serverless-svn-repositories'
          when '/archive/traffic-analysis-with-mint': '/2006/09/traffic-analysis-with-mint'
          when '/archive/you-heard-me-leave': '/2006/09/you-heard-me-leave'
          when '/archive/scope-in-javascript': '/2006/09/scope-in-javascript'
          when '/archive/answers-to-common-interview-questions': '/2006/09/answers-to-common-interview-questions'
          when '/archive/articles-about-interviewing': '/2006/09/articles-about-interviewing'
          when '/archive/quick-optimization': '/2006/08/quick-optimization'
          when '/archive/french-translation-of-i-wonder-what-this-button-does': '/2006/08/french-translation-of-i-wonder-what-this-button-does'
          when '/archive/i-wish-i-was-at-oscon-subversion-best-practices': '/2006/07/i-wish-i-was-at-oscon-subversion-best-practices'
          when '/archive/i-wonder-what-this-button-does': '/2006/07/i-wonder-what-this-button-does'
          when '/archive/i-wonder-how-to-say-ugh-in-german': '/2006/07/i-wonder-how-to-say-ugh-in-german'
          when '/archive/building-accessible-widgets-for-the-web': '/2006/07/building-accessible-widgets-for-the-web'
          when '/archive/forbidden-errors-and-subversion-commits': '/2006/07/forbidden-errors-and-subversion-commits'
          when '/archive/digital-web-and-me': '/2006/07/digital-web-and-me'
          when '/archive/pimp-my-javascript-duffs-edition': '/2006/06/pimp-my-javascript-duffs-edition'
          when '/archive/install-sqlite-locally-on-os-x': '/2006/06/install-sqlite-locally-on-os-x'
          when '/archive/mcwmagnolia-version-04-is-out': '/2006/06/mcwmagnolia-version-04-is-out'
          when '/archive/textmate-bundle-for-textpattern': '/2006/06/textmate-bundle-for-textpattern'
          when '/archive/subversion-post-commit-hooks-101': '/2006/06/subversion-post-commit-hooks-101'
          when '/archive/working-with-subversion-file-properties': '/2006/06/working-with-subversion-file-properties'
          when '/archive/virtual-hosting-on-os-x': '/2006/06/virtual-hosting-on-os-x'
          when '/archive/leveraging-modrewrite': '/2006/05/leveraging-modrewrite'
          when '/archive/mcwmagnolia': '/2006/04/mcwmagnolia'
          when '/archive/preparing-a-mac-for-resale': '/2006/04/preparing-a-mac-for-resale'
          when '/archive/mcwtemplates-v02': '/2006/04/mcwtemplates-v02'
          when '/archive/mcw-templates': '/2006/04/mcw-templates'
          when '/archive/new-server': '/2006/04/new-server'
          when '/archive/datarequestor': '/2006/03/datarequestor'
          when '/archive/bio': '/2006/03/bio'
          when '/archive/showing-perfect-time-unobtrusively': '/2006/02/showing-perfect-time-unobtrusively'
          when '/archive/event-handlers-and-other-distractions': '/2005/03/event-handlers-and-other-distractions'
          when '/archive/type-ahead-search-for-select-elements': '/2005/03/type-ahead-search-for-select-elements'
          when '/archive/component-encapsulation-using-object-oriented-javascript': '/2005/03/component-encapsulation-using-object-oriented-javascript'
          when '/archive/slidable-select-widgets-explained': '/2005/03/slidable-select-widgets-explained'
          when '/archive/son-of-perfecttime-the-validationator': '/2006/02/son-of-perfecttime-the-validationator'
          else nil
        end
      elsif @path.match(%r{^/blog/id/(\d+)})
        case $1.to_i
          when 1:   '/archive'
          when 12:  '/2005/03/event-handlers-and-other-distractions'
          when 13:  '/2005/03/component-encapsulation-using-object-oriented-javascript'
          when 17:  '/2005/03/type-ahead-search-for-select-elements'
          when 18:  '/2005/03/slidable-select-widgets-explained'
          when 19:  '/2005/03/slidable-select-widgets-explained'
          when 20:  '/2006/02/showing-perfect-time-unobtrusively'
          when 21:  '/2006/02/son-of-perfecttime-the-validationator'
          else nil
        end
      end
    end
  end
end