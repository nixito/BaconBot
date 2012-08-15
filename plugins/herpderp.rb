
require 'cinch'

class HerpDerp
  include Cinch::Plugin

  listen_to :message, method: :on_message
  def on_message m
    m.reply "derp" if m.message.downcase == "herp"
  end
end

$bot.plugins.register_plugin(HerpDerp)

