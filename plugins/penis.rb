
require 'cinch'

$penis_times ||= {}
$penis_times.default_proc = proc do |h,k|
  h[k] = 0
end

class Penis
  include Cinch::Plugin

  def cmds
    "penis"
  end

  match /(penis|siitin|robocock)/
  def execute m, type
    if(Time.now.to_i - $penis_times[m.user.nick] >= 60)
      case type
      when "penis"
        m.reply m.user.nick + ", 8"+("="*(rand(7)+2))+"D"
      when "siitin"
        m.reply m.user.nick + ", c"+("="*(rand(7)+1))+"3"
      when "robocock"
        heads = ["O", "K", "E", ">", ")", "}", "B", "@", "H"]
        m.reply m.user.nick + ", []===" + heads.sample
      end
    end
    $penis_times[m.user.nick] = Time.now.to_i
  end
end

$bot.plugins.register_plugin(Penis)

