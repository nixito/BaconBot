
require 'cinch'
require 'nokogiri'
require 'open-uri'
require 'uri'

class Weather
  include Cinch::Plugin

  def cmds
    "weather"
  end

  match /weather\s+(.+)/
  def execute m, loc
    m.reply get_weather(loc)
  end

  def get_weather loc
    loc.gsub!(" ", "%20")
    url = "http://www.google.com/ig/api?weather=#{loc}"
    
    doc = Nokogiri::HTML(open(url))

    city = doc.css('forecast_information city').attr("data")
    condition = doc.css('current_conditions condition').attr("data")
    f = doc.css('current_conditions temp_f').attr("data")
    c = doc.css('current_conditions temp_c').attr("data")
    humidity = doc.css('current_conditions humidity').attr("data")
    wind = doc.css('current_conditions wind_condition').attr("data")

    "#{city}: #{f}F #{c}C - #{condition}, #{humidity}, #{wind}"
  end
end

$bot.plugins.register_plugin(Weather)

