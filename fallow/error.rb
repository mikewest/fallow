module Fallow
  class ErrorPage
    def render ( request, error_code = nil )
      templater = Fallow::Template.new( 'error' )

      error_code ||= 500;

      error_messages = {
        403 => "<p>Oi!  Quit poking around in these here <em>forbidden</em> pages!</p>",
        404 => "<p>You've found a nonexistant page!  That's a sign of luck in many cultures, you know... Just not <em>this</em> one.  Too bad!</p><p>Why not head off to the <a href='/'>homepage</a> to try again?</p>",
        500 => "<p>Oh my, a server error!  That's not good at all.  It either means that you're being naughty, or I'm being a crap programmer.  Odds are high for both.</p>"
      }

      error_message = error_messages.has_key?( error_code ) ? error_messages[ error_code ] : error_messages[ 500 ]

      debug = '<ul>'
      request.env.each { |key,value|
        debug += "<li><strong>#{key.to_s}</strong> => #{value.to_s}</li>"
      }
      debug += '</ul>'
      
      templater = Fallow::Template.new( 'error' )
      result = templater.render({
        'error_code'    =>  error_code,
        'error_message' =>  error_message,
        'debug_data'    =>  debug
      })
      [ error_code, result ]
    end
  end
end