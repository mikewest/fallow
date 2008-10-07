module Fallow
  class ErrorPage
    def render ( request )
      if request.env.has_key?('ERROR_CODE') then
        [ request.env['ERROR_CODE'], request.env['ERROR_TEXT'] ]
      else
        result = '<ul>'
        request.env.each { |key,value|
          result += "<li><strong>#{key.to_s}</strong> => #{value.to_s}</li>"
        }
        result += '</ul>'
    
        [ 500, result ]
      end
    end
  end
end