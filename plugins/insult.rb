
require 'cinch'
require 'yaml'

def load_insults
  unless File.exists?("insults.yaml")
    File.open("insults.yaml", 'w'){|f| f.write("---")}
  end
  YAML::load(File.read("insults.yaml"))
end

def save_insults
  File.open("insults.yaml", "w"){|f|f.write(YAML::dump($insults))}
end

$insults = load_insults
$insults ||= {}
save_insults

$insult_times = {}
$insult_times.default_proc = proc do |h,k|
  h[k] = 0
end

class Insult
  include Cinch::Plugin

  def cmds
    "insult"
  end

  listen_to :message, method: :on_message
  def on_message m
    synchronize(:insult) do
      msgname = m.user.nick.downcase

      if($insults[msgname] && $insults[msgname].length > 0)
        $insults[msgname].each do |msg|
          m.reply "#{m.user.nick}, #{msg[:msg]}"
        end
        $insults[msgname] = []
        save_insults
      end
    end
  end

  match /insult\s+([^\s]+)/
  def execute m, to
    to.downcase!
    synchronize(:insult) do
      msgname = m.user.nick.downcase
      if(Time.now.to_i - $insult_times[msgname] < 60)
        m.reply "#{m.user.nick}, eat a dick"
      else
        $insult_times[msgname] = Time.now.to_i

        ins = "eat a dick"
        File.open('insults.txt', 'r') do |f|
          lines = f.readlines
          ins = lines[rand(lines.size)]
        end

        $insults[to] ||= []
        if $insults[to].length == 0
          $insults[to].push({
            :msg => ins
          })
        end
        save_insults
      end
    end
  end
end

$bot.plugins.register_plugin(Insult)

