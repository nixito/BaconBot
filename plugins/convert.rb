
require "net/http"
require "uri"
require 'steam-condenser'

class Convert
  include Cinch::Plugin

  def cmds
    ["con(vert)"]
  end

  match /(?:con(?:vert)?) (\d+)(\w+)\s+(\w+)/, method: :con
  def con(m, i, u1, u2)
    uri = URI.parse("http://rate-exchange.appspot.com/currency?from=#{u1}&to=#{u2}&q=#{i}")
    response = Net::HTTP.get_response(uri)
    result = MultiJson.load(response.body, :symbolize_keys => true)
    j = result[:v].round(2)
    m.reply "#{j}#{u2}"
  end
end

$bot.plugins.register_plugin(Convert)

