
require 'cinch'

class Hello
  include Cinch::Plugin

  match "hello"

  def execute(m)
    m.reply "Go die in a fire, #{m.user.nick}"
  end
end

$bot.plugins.register_plugin(Hello)

