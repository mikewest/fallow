module Fallow
  class ErrorPage
    def render ( request )
      templater = Fallow::Template.new( 'error' )

      error_code = '500';
      result     = '';
      if request.env.has_key?('ERROR_CODE') then
        error_code, result = request.env['ERROR_CODE'], request.env['ERROR_TEXT']
      else
        result = '<ul>'
        request.env.each { |key,value|
          result += "<li><strong>#{key.to_s}</strong> => #{value.to_s}</li>"
        }
        result += '</ul>'
        
        templater = Fallow::Template.new( 'error' )
        result = templater.render({
          'debug_data'  =>  result
        })
      end
      [ error_code, result ]
    end
  end
end