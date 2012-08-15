
require 'cinch'
require 'yaml'

def load_seen
  unless File.exists?("seen.yaml")
    File.open("seen.yaml", 'w'){|f| f.write("---")}
  end
  YAML::load(File.read("seen.yaml"))
end

def save_seen
  File.open("seen.yaml", "w"){|f|f.write(YAML::dump($seen))}
end

$seen = load_seen
$seen ||= {}
save_seen

class Seen
  include Cinch::Plugin

  def cmds
    "seen"
  end

  listen_to :channel, method: :log_message
  def log_message(m)
    $seen[m.user.nick.downcase] = {
      :nick => m.user.nick,
      :chan => m.channel.to_s,
      :msg => m.message,
      :time => Time.now
    }
    save_seen
  end

  match(/seen (.+)/, method: :check_nick)
  def check_nick(m, nick)
    seen = $seen[nick.downcase]

    return unless seen

    seen_t = seen[:time]
    seconds = Time.now - seen_t
    mins = (seconds / 60).to_i
    seconds = (seconds % 60 ).to_i
    hours = (mins / 60).to_i
    mins = (mins % 60).to_i
    days = (hours / 24).to_i
    hours = (hours % 24).to_i

    ago = 
    if(days > 0)
      "#{days}d #{hours}h #{mins}m"
    elsif(hours > 0)
      "#{hours}h #{mins}m"
    else
      "#{mins}m"
    end


    if seen
      m.reply "#{seen[:nick]} at #{seen_t} (#{ago} ago) in #{seen[:chan]} saying: #{seen[:msg]}"
    else
      m.reply "#{nick} who wat?"
    end
  end
end

$bot.plugins.register_plugin(Seen)

