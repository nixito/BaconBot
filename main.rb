#!/usr/env ruby

require 'cinch'
require 'set'

$plugins = Set.new

def load_plugins
  $bot.plugins.each do |p|
    $bot.handlers.unregister(*(p.handlers))
  end
  $bot.plugins.unregister_all
  Dir["plugins/*.rb"].each{ |f| load f }
end

def on_timer_15s
  $bot.plugins.each do |p|
    if(p.respond_to? :timer_15s)
      p.timer_15s
    end
  end
end

$bot = Cinch::Bot.new do
  configure do |c|
    nick = "BaconBot"
    server = "chat.freenode.net"
    channel = "#bottest"

    if(File.exists?("cfg/nick"))
      nick = IO.read("cfg/nick").strip
    end

    if(File.exists?("cfg/server"))
      server = IO.read("cfg/server").strip
    end

    if(File.exists?("cfg/channel"))
      channel = IO.read("cfg/channel").strip
    end

    c.nick = nick
    c.realname = nick
    c.user = nick
    c.server = server
    c.channels = [channel]
  end

  on :connect do |m|
    if(File.exists?("cfg/identify"))
      pass = IO.read("cfg/identify").strip
      User("nickserv").msg("identify #{pass}")
    end
  end
  
  on :message, "!reload" do |m|
    if(File.exists?("cfg/admin"))
      admin = IO.read("cfg/admin").strip
      load_plugins if m.user.nick.upcase == admin.upcase
    end
  end
end

Cinch::Timer.new($bot, {:interval => 15}) do
  on_timer_15s
end

load_plugins

$bot.start

