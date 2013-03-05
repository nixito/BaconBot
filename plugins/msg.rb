
require 'cinch'
require 'yaml'

def load_msgs
  unless File.exists?("msgs.yaml")
    File.open("msgs.yaml", 'w'){|f| f.write("---")}
  end
  YAML::load(File.read("msgs.yaml"))
end

def save_msgs
  File.open("msgs.yaml", "w"){|f|f.write(YAML::dump($msgs))}
end

$msgs = load_msgs
$msgs ||= {}
save_msgs

class Msg
  include Cinch::Plugin

  def cmds
    "msg"
  end

  listen_to :join, method: :on_join
  def on_join m
    synchronize(:msg) do
      msgname = m.user.nick.downcase

      if($msgs[msgname] && $msgs[msgname].length > 0)
        m.reply "#{m.user.nick}, you have messages waiting"
      end
    end
  end

  listen_to :message, method: :on_message
  def on_message m
    synchronize(:msg) do
      msgname = m.user.nick.downcase

      if($msgs[msgname] && $msgs[msgname].length > 0)
        $msgs[msgname].each do |msg|
          m.reply "#{m.user.nick}, #{msg[:name]} at #{msg[:time]}: #{msg[:msg]}"
        end
        $msgs[msgname] = []
        save_msgs
      end
    end
  end

  match /msg\s+([^\s]+)\s+([^\s].*)/, method: :msg
  def msg m, to, text
    synchronize(:msg) do
      to.downcase!

      $msgs[to] ||= []
      $msgs[to].push({
        :msg => text,
        :name => m.user.nick,
        :time => Time.now
      })
      save_msgs
      m.reply "#{m.user.nick}, msg deployed"
    end
  end
end

$bot.plugins.register_plugin(Msg)

