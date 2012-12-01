
require 'cinch'

class SG
  include Cinch::Plugin

  def cmds
    "sg"
  end

  match /sg(?:\s+(\w+))?/
  def initialize *args
    super

    @sg_servers = {
      "ballerbude" => ["212.65.13.87", 27960],
      "gbu" => ["74.91.112.187", 27920],
      "jeux" => ["91.121.74.167", 27971],
      "pain" => ["68.191.36.42", 27960],
      "paladin" => ["108.178.55.36", 27960],
      "paladinbr" => ["108.178.55.106", 27960],
      "terranova" => ["212.65.13.87", 27962],
      "webe" => ["216.230.231.74", 59670]
      #"sgbr" => ["91.121.39.115", 27979],
      #"fail" => ["37.59.141.101", 25565],
      #"paladin" => ["108.178.55.36", 27960],
      #"specialbude" => ["212.65.13.87", 27961],
      #"frogsbr" => ["91.121.39.115", 27970],
      #"circus" => ["176.9.90.215", 27960],
      #"sgwars" => ["91.121.39.115", 27975],
      #"sg.fr" => ["91.121.39.115", 27971],
      #"q3alive" => ["188.120.238.182", 27960]
    }

    @t=Thread.new do
      watch_sg
    end
  end

  def unregister
    super
    Thread.kill(@t) if @t && @t.alive?
  end

  def execute m, server
    if server
      @sg_servers.each do |name, addr|
        if(server.downcase == name)
          begin
            map, players = sg_info(addr[0], addr[1])
            a = addr[0]
            if addr[1] != 27960
              a += ":#{addr[1]}"
            end
            m.reply "#{name} #{a} - #{map} - #{players.join(',  ')}"
          rescue
            m.reply "#{name}: fail"
          end
        end
      end
    else
      str = ""

      @sg_servers.each do |name, addr|
        begin
          str += "#{name} #{sg_info(addr[0], addr[1])[1].length}    "
        rescue Exception=>e
          str += "#{name} fail    "
        end
      end
      m.reply str
    end
  end

  def sg_info server, port=27960, timeout=1.5 #3sec default timeout
    resp, sock = nil, nil
    begin
      cmd = "\xff\xff\xff\xffgetstatus"
      sock = UDPSocket.open
      sock.send(cmd, 0, server, port)
      resp = if select([sock], nil, nil, timeout)
        sock.recvfrom(65536)
      end
      if resp
        resp[0] = resp[0][4..-1] #trim leading bits
      end
    rescue IOError, SystemCallError
    ensure
      sock.close if sock
    end

    resp = resp ? resp[0] : ""

    info = resp.split("\n")[1].split("\\")
    i = info.find_index("mapname")
    map = info[i+1]

    players = resp.split("\n")[2..-1]
    players.reject! do |p|
      score, ping, name = p.split(" ", 3)
      ping == "0"
    end
    players.map! do |p|
      name = p.split(" ", 3)[2]
      name.gsub(/\^./, "")
    end
    return map, players
  end

  def watch_sg
    alerts = ["bacon", "boog", "cwnn"]
    last = {}
    alerts.each do |alert|
      last[alert] = {}
      @sg_servers.each do |server, addr|
        last[alert][server] = 0
      end
    end

    sleep 15 #give time to get fully connected

    while true
      alerts.each do |alert|
        @sg_servers.each do |server, addr|
          begin
            players = sg_info(addr[0], addr[1], 1)[1]
            if(players.find{|p|p.downcase.include? alert})
              if((Time.now.to_i - last[alert][server]) > (60 * 5))
                #it has been more than 5 minutes since we last saw this alert on this server
                chan = $bot.channels.find{|c|c.name == "#sg_usa"}
                chan.msg("#{alert} alert on #{server}") if chan
              end
              last[alert][server] = Time.now.to_i
              STDOUT.flush
            end
          rescue Exception=>e
          end
        end
      end
      sleep 30
    end
  end
end

$bot.plugins.register_plugin(SG)

