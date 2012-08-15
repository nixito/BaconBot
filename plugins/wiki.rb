
require 'cinch'
require 'nokogiri'
require 'open-uri'
require 'uri'
require 'yaml'

def cur_date
  Time.now.strftime("%D")
end

def load_fact
  unless File.exists?("fact.yaml")
    File.open("fact.yaml", 'w'){|f| f.write("---")}
  end
  YAML::load(File.read("fact.yaml"))
end

def save_fact
  File.open("fact.yaml", "w"){|f|f.write(YAML::dump($fact))}
end

$fact = load_fact
$fact ||= [cur_date, get_fact]
save_fact

class Wiki
  include Cinch::Plugin

  def cmds
    ["wiki", "fact"]
  end

  match "fact", method: :fact
  def fact m
    if(cur_date != $fact[0])
      $fact[0] = cur_date
      $fact[1] = get_fact
      save_fact
    end

    m.reply $fact[1]
  end

  match /wiki\s+(.+)/, method: :wiki
  def wiki m, q
    m.reply get_fact(q)
  end

  def get_fact name=nil
    name ||= "Special:Random"
    url = "http://en.wikipedia.org/wiki/#{name.gsub(" ", "_")}"

    doc = Nokogiri::HTML(open(url))

    title = doc.css('h1#firstHeading').text

    text = doc.css('div#bodyContent p')[0].text
    text.gsub!(/\[\d+\]/, "")

    unless text.index(title)
      text = "#{title.strip}: #{text}"
    end

    text
  end
end

$bot.plugins.register_plugin(Wiki)

