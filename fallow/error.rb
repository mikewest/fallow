module Fallow
  class ErrorPage
    def render ( env )
      result = '<ul>'
      env.each { |item|
        result += "<li><strong>#{item[0]}</strong> => #{item[1]}</li>"
      }
      result += '</ul>'
    
      [ 500, {'Content-Type' => 'text/html'}, [result] ]
    end
  end
end