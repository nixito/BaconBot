
require 'cinch'
require 'yaml'
load 'pot.rb'

def load_pots
  unless File.exists?("pots.yaml")
    File.open("pots.yaml", 'w'){|f| f.write("---")}
  end
  YAML::load(File.read("pots.yaml"))
end

def save_pots
  File.open("pots.yaml", "w"){|f|f.write(YAML::dump($pots))}
end
$pots = load_pots
$pots ||= {}
$pots.default_proc = proc do |h,k|
  h[k] = Pot.new
end

$pots.each_value do |pot|
  pot.fix
end

class PotMan
  include Cinch::Plugin

  def cmds
    "pot"
  end

  match /pot\s+(\w+)/, method: :asdf
  def asdf m, thing
    case thing
    when "help"
      m.reply "pot [help / list],  pot <name> [status / reset / kill / hand / list],  pot <name> draw <num>,  pot <name> [put / take] <chip>"
    when "list"
      synchronize(:pot) do
        m.reply "pots: #{$pots.keys.join(', ')}"
      end
    end

    save_pots
  end

  match /pot\s+(\w+)\s+(\w+)\s*(\w*)/, method: :pot
  def pot m, name, task, arg
    synchronize(:pot) do
      msgname = m.user.nick.downcase
      pot = $pots[name]

      case task.downcase
      when "reset"
        pot.reset
        m.reply "pot #{name} reset"
      when "kill"
        $pots.delete name
        m.reply "pot #{name} killed"
      when "hand"
        m.reply "pot #{name} #{msgname}'s hand: #{pot.hand(msgname)}"
      when "draw"
        chips = pot.draw msgname, arg.to_i
        m.reply "drew #{chips}"
      when "put"
        chips = pot.put(msgname, arg.upcase)
        m.reply "pot #{name} #{msgname} put: #{chips}"
      when "take"
        chips = pot.take(msgname, arg.upcase)
        m.reply "pot #{name} #{msgname} take: #{chips}"
      when "status"
        num = pot.status

        m.reply "pot #{name} has #{num} chips remaining"
      end

      save_pots
    end
  end
end

$bot.plugins.register_plugin(PotMan)

