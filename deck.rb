
CARDS = ["RJ", "BJ"]
%w(H D C S).each do |suit|
  %w(2 3 4 5 6 7 8 9 10 J Q K A).each do |val|
    CARDS.push "#{val}#{suit}"
  end
end

class Deck
  def initialize
    reset
  end

  def sort_value(card)
    val = card[0..-2]
    case val
    when "A"
      100
    when "K"
      99
    when "Q"
      98
    when "J"
      97
    else
      val.to_i
    end
  end

  def sort_with_suit(card)
    val = card[0..-2]
    suit = card[-1]

    val = case val
    when "B"
      1000
    when "R"
      900
    when "A"
      500
    when "K"
      400
    when "Q"
      300
    when "J"
      200
    else
      val.to_i * 10
    end

    val += case suit
    when "J"
      5
    when "S"
      4
    when "H"
      3
    when "D"
      2
    when "C"
      1
    end

    val
  end

  def pretty_cards(cards, sleeve=nil)
    jokers = []
    spades = []
    hearts = []
    diamonds = []
    clubs = []
    sleeves = [sleeve].compact

    cards.each do |card|
      case card[-1]
      when "J"
        jokers.push card
      when "S"
        spades.push card
      when "H"
        hearts.push card
      when "D"
        diamonds.push card
      when "C"
        clubs.push card
      end
    end

    pretty = []

    jokers.each do |card|
      pretty.push ((card[0] == "R" ? "Red" : "Black") + " Joker")
    end

    [spades, hearts, diamonds, clubs, sleeves].each do |suit|
      next if suit.empty?

      suit.sort! do |x,y|
        sort_value(y) <=> sort_value(x)
      end

      pretty_suit = []

      suit.each do |card|
        pretty_suit.push card[0..-2]
      end

      pretty_suit = pretty_suit.join(", ")

      pretty_suit += " of " + 
        case suit[0][-1]
        when "S"
          "Spades"
        when "H"
          "Hearts"
        when "D"
          "Diamonds"
        when "C"
          "Clubs"
        end

      if suit == sleeves
        pretty_suit = "Sleeved " + pretty_suit
      end

      pretty.push pretty_suit
    end

    pretty.join("; ")
  end

  def reset
    @cards = CARDS.clone
    @discard = []
    @hands = {}
    @hands.default_proc = proc do |h,k|
      h[k] = []
    end
    @sleeves = {}
  end

  def shuffle
    @cards += @discard
    @discard = []
  end

  def fix
    @cards ||= CARDS.clone
    @discard ||= []
    @hands ||= {}
    @hands.default_proc = proc do |h,k|
      h[k] = []
    end
    @sleeves ||= {}
  end

  def status
    stat = [@cards.length, @discard.length]
    hands = []
    @hands.each do |player, hand|
      unless hand.empty? && !@sleeves[player]
        hands.push [player, hand.size, @sleeves[player]]
      end
    end

    stat.push hands
  end

  def list
    cards = []

    @hands.each do |name, hand|
      hand.each do |card|
        cards.push [card, name]
      end
    end

    cards.sort_by! do |arr|
      sort_with_suit(arr[0])
    end

    cards.reverse!

    cards.map! do |arr|
      "#{arr[0]} (#{arr[1]})"
    end

    cards.join ", "
  end

  def hand player
    pretty_cards(@hands[player], @sleeves[player])
  end

  def discard player, cards
    sleeve = nil

    if cards.empty?
      cards = @hands[player].clone
    else
      if @hands[player].include?(cards)
        cards = [cards]
      else
        if cards == @sleeves[player]
          sleeve = @sleeves.delete(player)
          @discard += [sleeve]
        end
        cards = []
      end
    end

    @discard += cards
    @hands[player] -= cards

    pretty_cards(cards, sleeve)
  end

  def take player, cards
    took = []

    card = @cards.delete(cards)
    card ||= @discard.delete(cards)
    @hands[player] += [card] if card

    pretty_cards([card])
  end

  def put player, cards
    sleeve = nil

    if cards.empty?
      cards = @hands[player].clone
    else
      if @hands[player].include?(cards)
        cards = [cards]
      else
        if cards == @sleeves[player]
          sleeve = @sleeves.delete(player)
          @cards += [sleeve]
        end
        cards = []
      end
    end

    @cards += cards
    @hands[player] -= cards

    pretty_cards(cards, sleeve)
  end

  def sleeve player, card
    unless @hands[player].include?(card)
      return ""
    end

    if @sleeves[player]
      return ""
    end

    @sleeves[player] = @hands[player].delete(card)

    pretty_cards([@sleeves[player]])
  end

  def draw player, num
    drawn = []
    num.times do
      next if @cards.empty?
      drawn.push(@cards.delete_at(rand(@cards.length)))
    end
    @hands[player] += drawn
    pretty_cards(drawn)
  end
end
