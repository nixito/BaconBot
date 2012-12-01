
require 'cinch'
require 'nokogiri'
require 'open-uri'
require 'uri'
require 'yaml'

def load_links
  unless File.exists?("links.yaml")
    File.open("links.yaml", 'w'){|f| f.write("---")}
  end
  YAML::load(File.read("links.yaml"))
end

def save_links
  File.open("links.yaml", "w"){|f|f.write(YAML::dump($links))}
end

$links = load_links
$links ||= []
save_links

class Links
  include Cinch::Plugin

  def cmds
    "links"
  end

  listen_to :message, method: :on_message
  def on_message m

    ## get title, save link
    #
    text = m.message.clone
    while(match = text.match(/\S+\.\S*[^,!]/))
      text = match.post_match
      url = match[0]

      unless url.index("http") == 0
        url = "http://#{url}"
      end

      begin
        doc = Nokogiri::HTML(open(url))

        title = doc.css('title').text.gsub("\n", "")
        synchronize(:links) do
          $links.push ({
            :url => url,
            :msg => text,
            :title => title,
            :name => m.user.nick.downcase,
            :time => Time.now
          })
          save_links
        end
        m.reply("#{m.user.nick}, link: #{title}") if title && !title.empty?
      rescue URI::InvalidURIError
      rescue SocketError
      rescue Exception=>e
        if e.to_s.start_with?("redirection forbidden")
          synchronize(:links) do
            $links.push({
              :url => url,
              :msg => text,
              :title => "",
              :name => m.user.nick.downcase,
              :time => Time.now
            })
            save_links
          end
        else
          #throw e
        end
      end
    end
  end

  match /links((?:\s+\w+)*)/
  def execute m, words
    if !words
      $links.sort! do |a, b|
        b[:time] <=> a[:time]
      end

      links = $links[0..2]
      links.each do |link|
        m.reply "#{m.user.nick}, #{link[:url]} - #{link[:title]} - linked by #{link[:name]} at #{link[:time]}"
      end
    else
      words = words.downcase.split
      results = $links.select do |link|
        words.all? do |word|
          word.strip!
          link[:url].to_s.downcase.include?(word) ||
            link[:title].to_s.downcase.include?(word) ||
            link[:name].to_s.downcase.include?(word) ||
            link[:msg].to_s.downcase.include?(word)
        end
      end

      results.sort! do |a, b|
        b[:time] <=> a[:time]
      end
      results = results[0..2]

      results.each do |link|
        m.reply "#{m.user.nick}, #{link[:url]} - #{link[:title]} - linked by #{link[:name]} at #{link[:time]}"
      end
    end
  end
end

$bot.plugins.register_plugin(Links)

