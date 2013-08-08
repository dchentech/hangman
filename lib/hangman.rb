# encoding: UTF-8

require 'logger'
require File.expand_path('../hangman/constants.rb', __FILE__)
require File.expand_path('../hangman/ruby.rb', __FILE__)

class Hangman
  attr_reader :source
  attr_reader :guessed_chars, :matched_words

  def initialize source
    @source = source

    # check @source's methods
    [:word, :make_a_guess, :give_me_a_word, :status, :success?].each do |m|
      raise "#{@source}'s class #{@source.class} havent defined method :#{m}" if not @source.methods.include? m
    end

    @guessed_chars = []
    @matched_words = nil

    return self
  end

  # delegate behaviors to @source
  def success?; @source.success?  end
  def word; @source.word end
  def done?; word.count('*').zero? end
  def init_guess; @source.give_me_a_word end

  def guess
    raise "Please #init_guess first" if word.nil?

    # 退出，比如全部都是重复字母，包括一两个字母，比如A, AA
    return false if matched_chars_with_idx.length == word_length

    _old_asterisk_count = word.count('*')

    #require 'pry-debugger'; binding.pry
    @source.make_a_guess current_guess_char

    # Number of Allowed Guess on this word is 0, please get a new word
    return false if @source.status == 400

    # 这次猜测有匹配！
    # require 'pry-debugger'; binding.pry
    begin
    if success? && (word.count('*') < _old_asterisk_count)
      # 根据匹配的位置继续过滤 候选单词列表
      # @return { char => [3, 5] }
      word.chars.each_with_index do |_char, idx|
        next if (_char == '*') || @guessed_chars[0..-2].include?(_char)
        @matched_words = @matched_words & Length_to__char_num_to_words__hash[word_length]["#{_char}#{idx}".to_sym]
      end
      # break # 成功后继续猜 下一个字母
    end
    rescue => e
      e; require 'pry-debugger'; binding.pry
    end

  end

  # return e.g. 'E'
  def current_guess_char
    case word.count("*")
    # 第一步: 依据词典词频找出第一个匹配的字母及其一或多个位置
    when word_length
      _char = (Hash[range.map {|num| PopularityOfLettersInLength[num] }.flatten.frequencies].keys - @guessed_chars).first
    # 第二步: 查找剩余字母，直到找完位置
    else
      # 依据上面匹配字母及其位置找到所有符合单词
    # require 'pry-debugger'; binding.pry
      if not @matched_words
        matched_words_array = matched_chars_with_idx.map do |_char_with_idx|
          Length_to__char_num_to_words__hash[word_length][_char_with_idx]
        end
        if matched_words_array.size.zero?
          puts "no matched word" 
          return nil
        end
        matched_words_array.each do |_a1|
          @matched_words ||= _a1
          @matched_words = @matched_words & _a1
        end
      end
      # 如果所有单词都不匹配
      return nil if @matched_words.size.zero?

      # 并求出接下来的字母及其位置
      # 当找到一个匹配后，就重新选择下一个最大机会匹配字母
      _char = select_next_vowel_or_consonant
    end

    return nil if _char.nil? # 兼容无单词情况, 比如猜测词是SUNDAY，但是词典里只SUNDAE有

    @guessed_chars << _char

    return _char
  end

  # @return [:N2, :N6]
  def matched_chars_with_idx
    _a = []
    word.chars.each_with_index do |c1, idx|
      _a << "#{c1}#{idx}".to_sym if c1 != '*'
    end
    return _a
  end


  # 如果前一个是元音，那么下一个就是辅音，如果没找到，继续辅音，
  # 知道找到，才切换下一个为元音。
  # 辅音同理。
  def select_next_vowel_or_consonant
    # avaible unguessed chars from @matched_words
    _chars = @matched_words.map {|_w1| _w1.to_s.chars.to_a }.flatten.frequencies.map(&:first) - @guessed_chars

    _list = VowelList.index(@guessed_chars[-1]) ? ConsonantList : VowelList
    _c1 = _chars.detect {|c| _list.index(c) }
    _c1 || _chars[0] # 兼容元音数量少的情况
  end

  def guess_word
    while (matched_chars_count != word_length) do

      puts "[剩余单词数量#{@matched_words.count}] : [已匹配字母数量#{matched_chars_count}] #{c1}: #{result}"
      puts @matched_words.inspect if ENV['DEBUG']
    end

    puts "猜测 次数:#{@source.guessed_time} 单词:#{word} 单词长度:#{word.length} 顺序:#{@guessed_chars}"
    puts
    raise "猜测次数 不可能少于 单词含有的唯一字母个数" if @source.guessed_time < _w.chars.to_a.uniq.length
    return @source.guessed_time
  end

  def range; word_length..word_length end
  def word_length; @_word_length_cache ||= word.length end
  def matched_chars_count; word.length - word.count('*').length end

end

# TODO http://www.datagenetics.com/blog/april12012/index.html#result


class Hangman
  def self.word_recorder
    @@word_recorder ||= Logger.new(File.expand_path("../../strikingly_words.txt", __FILE__))
  end
end
