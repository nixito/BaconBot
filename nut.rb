
require 'nokogiri'
require 'open-uri'
require 'uri'
  def execute q
    q = URI.escape(q, Regexp.new("[^#{URI::PATTERN::UNRESERVED}]"))
    url = "http://api.wolframalpha.com/v2/query?input=nutrition%20data%20#{q}&format=plaintext&appid=HGAQ54-AEUEQH34WV"
    
    doc = Nokogiri::HTML(open(url))

    txt = doc.css("pod[@id='NutritionLabelSingle:ExpandedFoodData'] plaintext").inner_html

    serving = txt.match(/serving size\s(.+)$/)[1].strip
    carbs = txt.match(/total carbohydrates\s(.+)\|/)[1].strip
    fiber = txt.match(/dietary fiber\s(.+)\|/)[1].strip
    puts "serving: #{serving}, carbs: #{carbs}, fiber: #{fiber}"
  end

  execute "broccoli"
