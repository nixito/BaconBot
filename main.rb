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

$bot = Cinch::Bot.new do
  configure do |c|
    nick = "BaconBot"
    server = "irc.freenode.org"
    channel = "#bottest"

    if(File.exists("cfg/nick"))
      nick = IO.read("cfg/nick")
    end

    if(File.exists("cfg/server"))
      server = IO.read("cfg/server")
    end

    if(File.exists("cfg/channel"))
      channel = IO.read("cfg/channel")
    end

    c.nick = nick
    c.realname = nick
    c.user = nick
    c.server = server
    c.channels = [channel]
  end

  on :connect do |m|
    if(File.exists("cfg/identify"))
      pass = IO.read("cfg/identify")
      User("nickserv").msg("identify #{pass}")
    end
  end
  
  on :message, "!reload" do |m|
    if(File.exists("cfg/admin"))
      admin = IO.read("cfg/admin")
      load_plugins if m.user.nick.upcase == admin.upcase
    end
  end
end

load_plugins

$bot.start

