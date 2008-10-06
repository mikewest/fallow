module Fallow
  class ErrorPage
    def render ( env )
      result = '<ul>'
      env.each { |item|
        result += "<li><strong>#{item[0].to_s}</strong> => #{item[1].to_s}</li>"
      }
      result += '</ul>'
    
      [ 500, {'Content-Type' => 'text/html'}, [result] ]
    end
  end
end