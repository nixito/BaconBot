
require 'cinch'
require 'nokogiri'
require 'open-uri'
require 'uri'

class Timea
  include Cinch::Plugin

  def cmds
    "time"
  end

  match /time$/, method: :time
  def time m
    m.reply "bacon time: #{Time.now}"
  end

  match /time\s+(.+)/, method: :get_time
  def get_time m, loc
    loc.gsub!(" ", "+")
    url = "http://www.google.com/search?q=time+#{loc}"
    doc = Nokogiri::HTML(open(url))
    m.reply doc.css('.obcontainer')[0].text
  end
end

$bot.plugins.register_plugin(Timea)

