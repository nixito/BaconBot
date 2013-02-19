
require 'cinch'
require 'nokogiri'
require 'open-uri'
require 'uri'

class Nutrition
  include Cinch::Plugin

  def cmds
    "nut(rition)"
  end

  match /nut(?:rition)? (.+)/
  def execute m, q
    q = URI.escape(q, Regexp.new("[^#{URI::PATTERN::UNRESERVED}]"))
    url = "http://api.wolframalpha.com/v2/query?input=nutrition%20data%20#{q}&format=plaintext&appid=HGAQ54-AEUEQH34WV"
    
    doc = Nokogiri::HTML(open(url))

    txt = doc.css("pod[@id='NutritionLabelSingle:ExpandedFoodData'] plaintext").inner_html

    serving = txt.match(/serving size\s(.+)$/)[1].strip
    carbs = txt.match(/total carbohydrates\s(.+)\|/)[1].strip
    fiber = txt.match(/dietary fiber\s(.+)\|/)[1].strip
    m.reply "#{m.user.nick}, serving: #{serving}, carbs: #{carbs}, fiber: #{fiber}"
  end
end

$bot.plugins.register_plugin(Nutrition)

