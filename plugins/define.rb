
require 'cinch'
require 'wordnik'
require 'json'

Wordnik.configure do |config|
  config.api_key = '3bf46a5a5cb84b9e5a5000c516f0a45d421e6ba5180ed8e72'
end

class Define
  include Cinch::Plugin
  #help "!dict(ionary) <word> - Look up a word via the WordNet database"
  
  @@pagesize = 4

  def cmds
    ["def(ine)", "ex(ample)", "word"]
  end
  
  match /(?:(?:dict(?:ionary)?)|(?:def(?:ine)?)) ([^\s]+)(?:\s+(\d+))?/, method: :define
  def define(m, query, page = 1)
    page = page.to_i
    dfns = Wordnik.word.get_definitions(query)
    maxPage = (dfns.size/@@pagesize.to_f).ceil

    page = 1 if page < 1
    page = maxPage if page > maxPage

    min = (page-1)*@@pagesize
    max = min+@@pagesize-1

    m.reply "#{query} page #{page} of #{maxPage}"
    dfns[min..max].each do |dfn|
      m.reply "#{dfn['word']}, #{dfn['partOfSpeech']}: #{dfn['text']}"
    end
  end

  match /(?:ex(?:ample)?) ([^\s]+)(?:\s+(\d+))?/, method: :example
  def example(m, query, page = 1)
    page = page.to_i
    dfns = Wordnik.word.get_examples(query, :limit => @@pagesize*4)['examples']
    maxPage = (dfns.size/@@pagesize.to_f).ceil

    page = 1 if page < 1
    page = maxPage if page > maxPage

    min = (page-1)*@@pagesize
    max = min+@@pagesize-1

    m.reply "#{query} page #{page} of #{maxPage}"
    dfns[min..max].each do |dfn|
      m.reply "#{dfn['word']}: #{dfn['text']}"
    end
  end

  match /word/, method: :word
  def word(m)
    page = page.to_i
    word = Wordnik.words.get_word_of_the_day()
    dfns = word['definitions']
    word = word['word']

    dfns.each do |dfn|
      m.reply "#{word}: #{dfn['text']}"
    end
  end
end

$bot.plugins.register_plugin(Define)

