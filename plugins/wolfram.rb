
require 'cinch'
require 'nokogiri'
require 'open-uri'
require 'uri'

class Wolfram
  include Cinch::Plugin

  def cmds
    "wolf(ram)"
  end

  match /wolf(?:ram)? (.+)/
  def execute m, q
    q = URI.escape(q, Regexp.new("[^#{URI::PATTERN::UNRESERVED}]"))
    url = "http://api.wolframalpha.com/v2/query?input=#{q}&format=plaintext&appid=HGAQ54-AEUEQH34WV"
    
    doc = Nokogiri::HTML(open(url))

    txt = doc.css('#Result plaintext').inner_html

    dec = doc.css('#DecimalApproximation plaintext').inner_html

    txt = "go die in a fire" if !txt || txt == ""

    if(dec && dec != "")
      txt += " (#{dec})"
    end

    m.reply m.user.nick + ", " + txt
  end
end

$bot.plugins.register_plugin(Wolfram)

