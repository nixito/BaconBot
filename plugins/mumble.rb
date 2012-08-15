
require 'cinch'
require 'redis'

$redis ||= Redis.new
$murm_users ||= []

class Mumble
  include Cinch::Plugin

  def initialize *args
    super
    
    @t=Thread.new do
      watch_murmur
    end
  end

  def cmds
    "mumble"
  end

  def unregister
    super
    Thread.kill(@t) if @t && @t.alive?
  end

  match /mumble|mumz/
  def execute(m)
    synchronize(:mumble) do
      str = $murm_users.join(", ")
      if str.length == 0
        str = "emptier than my heart"
      end
      m.reply "mumz: #{str}"
    end
  end

  def watch_murmur
    while true
      synchronize(:mumble) do
        users = $redis.get('murmUsers').split(';')

        chan = $bot.channels.find{|c|c.name == "#sg_usa"}

        users.each do |newUser|
          if(!$murm_users.include?(newUser))
            chan.send("#{newUser} on mumz") if chan
          end
        end

        $murm_users.each do |oldUser|
          if(!users.include?(oldUser))
            chan.send("#{oldUser} off mumz") if chan
          end
        end

        $murm_users = users
      end
      sleep 2
    end
  end
end

$bot.plugins.register_plugin(Mumble)

