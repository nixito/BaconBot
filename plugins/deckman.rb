
require 'cinch'
require 'yaml'
load 'deck.rb'

def load_decks
  unless File.exists?("decks.yaml")
    File.open("decks.yaml", 'w'){|f| f.write("---")}
  end
  YAML::load(File.read("decks.yaml"))
end

def save_decks
  File.open("decks.yaml", "w"){|f|f.write(YAML::dump($decks))}
end

$decks = load_decks
$decks ||= {}
$decks.default_proc = proc do |h,k|
  h[k] = Deck.new
end

$decks.each_value do |deck|
  deck.fix
end

class DeckMan
  include Cinch::Plugin

  def cmds
    "deck"
  end

  match /deck\s+(\w+)/, method: :asdf
  def asdf m, thing
    case thing
    when "help"
      m.reply "deck [help / list],  deck <name> [status / reset / kill / hand / shuffle / discard / list],  deck <name> draw <num>,  deck <name> [put / take / discard / sleeve] <card>"
    when "list"
      synchronize(:deck) do
        m.reply "decks: #{$decks.keys.join(', ')}"
      end
    end

    save_decks
  end

  match /deck\s+(\w+)\s+(\w+)\s*(\w*)/, method: :deck
  def deck m, name, task, arg
    synchronize(:deck) do
      msgname = m.user.nick.downcase
      deck = $decks[name]

      case task.downcase
      when "reset"
        deck.reset
        m.reply "deck #{name} reset"
      when "shuffle"
        deck.shuffle
        m.reply "deck #{name} shuffled"
      when "sleeve"
        cards = deck.sleeve(msgname, arg.upcase)
        m.reply "deck #{name} #{msgname} sleeved: #{cards}"
      when "hand"
        m.reply "deck #{name} #{msgname}'s hand: #{deck.hand(msgname)}"
      when "discard"
        cards = deck.discard(msgname, arg.upcase)
        m.reply "deck #{name} #{msgname} discarded: #{cards}"
      when "take"
        cards = deck.take(msgname, arg.upcase)
        m.reply "deck #{name} #{msgname} took: #{cards}"
      when "put"
        cards = deck.put(msgname, arg.upcase)
        m.reply "deck #{name} #{msgname} put: #{cards}"
      when "kill"
        $decks.delete name
        m.reply "deck #{name} killed"
      when "status"
        num, dnum, hands = deck.status
        str = ["deck #{name} #{num} (#{dnum}) cards"]
        hands.each do |hand|
          str.push "#{hand[0]} #{hand[1]}#{hand[2] ? "+1" : ""} cards"
        end

        m.reply str.join(", ")
      when "list"
        list = deck.list
        m.reply list
      when "draw"
        cards = deck.draw msgname, arg.to_i
        m.reply "drew #{cards}"
      end

      save_decks
    end
  end
end

$bot.plugins.register_plugin(DeckMan)

