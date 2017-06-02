require 'json'
require 'net/http'
class Response

  attr_reader :body, :message, :error

  def initialize(res)
    @code = res.code
    @message = res.is_a?(Net::HTTPSuccess) ? nil : res.message
    @body = JSON.parse(res.body)
    @error = if @body['error'] && @body['error']['messages']
               if @body['error']['messages'].is_a?(Array)
                 @body['error']['messages'].join('. ')
               else
                 @body['error']['messages']
               end
             else
               @body['error']
             end
  end

  def code
    @code.to_i
  end

end

