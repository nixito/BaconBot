require 'cinch'

class Hello
  include Cinch::Plugin

  match "hello"

  def execute(m)
    if m.user.nick == "Nixito"
    m.reply "Hello, #{m.user.nick}"
    else m.reply "Go die in a fire, #{m.user.nick}"
    end
  end
end

$bot.plugins.register_plugin(Hello)

