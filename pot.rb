
CHIPS = ["W"] * 50 + ["R"] * 25 + ["B"] * 10

class Pot
  def initialize
    reset
  end

  def reset
    @chips = CHIPS.clone
    @hands = {}
    @hands.default_proc = proc do |h,k|
      h[k] = []
    end
  end

  def fix
    @chips ||= CHIPS.clone
    @hands ||= {}
    @hands.default_proc = proc do |h,k|
      h[k] = []
    end
  end

  def pretty_chips(chips, sleeve=nil)
    blues = []
    reds = []
    whites = []

    chips.each do |chip|
      case chip
      when "B"
        blues.push chip
      when "R"
        reds.push chip
      when "W"
        whites.push chip
      end
    end

    pretty = []

    [blues, reds, whites].each do |suit|
      next if suit.empty?

      pretty_suit = "#{suit.size} " +
        case suit[0]
        when "B"
          "Blue"
        when "R"
          "Red"
        when "W"
          "White"
        end

      pretty.push pretty_suit
    end

    pretty.join("; ")
  end

  def hand player
    pretty_chips(@hands[player])
  end

  def status
    @chips.size
  end

  def draw player, num
    drawn = []
    num.times do
      next if @chips.empty?
      drawn.push(@chips.delete_at(rand(@chips.length)))
    end
    @hands[player] += drawn
    pretty_chips(drawn)
  end

  def put player, chips
    if chips.empty?
      chips = @hands[player].clone
    else
      if @hands[player].include?(chips)
        chips = [chips]
      else
        chips = []
      end
    end

    @chips += chips
    chips.each do |chip|
      @hands[player].delete_at(@hands[player].find_index(chip))
    end

    pretty_chips(chips)
  end

  def take player, chips
    if @chips.include?(chips)
      chips = [chips]
    else
      chips = []
    end

    chips.each do |chip|
      @chips.delete_at(@chips.find_index(chip))
    end
    @hands[player] += chips

    pretty_chips(chips)
  end

end
