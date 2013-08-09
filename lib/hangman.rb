# encoding: UTF-8

require 'logger'
require File.expand_path('../hangman/constants.rb', __FILE__)
require File.expand_path('../hangman/ruby.rb', __FILE__)
require File.expand_path('../hangman/source.rb', __FILE__)

# TODO log words and their unmatched words to database
# TODO Can I skip a word? Yes! send another "Give Me A Word" request, i.e. "action":"nextWord"
# 并发测试，网络速度太慢 =》 开启多个guard
# TODO http://www.datagenetics.com/blog/april12012/index.html#result
# TODO 记录下猜不到的单词的相关信息，下次可以优先根据其中相反的词频猜。

class Hangman
  attr_reader :source
  attr_reader :guessed_chars, :matched_words, :unmatched_words

  def initialize source
    @source = source
    @source.hangman = self

    @guessed_chars = []
    @matched_words = nil
    @unmatched_words = []

    return self
  end

  # delegate behaviors to @source
  require 'active_support/core_ext/module/delegation.rb'
  Hangman::Source::InstanceMethods.each do |m|
    delegate m, :to => :source
  end
  def done?; !!word && word.count('*').zero? end

  def guess
    raise "Please #init_guess first" if word.nil?
    #require 'pry-debugger'; binding.pry

    # 退出，比如全部都是重复字母，包括一两个字母，比如A, AA
    return false if matched_chars_with_idx.length == word_length

    _old_asterisk_count = word.count('*')

    _current_guess_char = current_guess_char
    return "no char" if _current_guess_char.nil?
    @source.make_a_guess _current_guess_char

    # 兼容一个都没有匹配
    @matched_words ||= [] if @source.remain_time.zero?

    return false if not @source.network_success?
    setup_matched_words

    #require 'pry-debugger'; binding.pry

    # Number of Allowed Guess on this word is 0, please get a new word

    begin
    if network_success? && @matched_words # compactible with herokuapp error

      # 这次猜测有匹配！
      if word.count('*') < _old_asterisk_count

        # 根据匹配的位置继续过滤 候选单词列表
        # @return e.g. { char => [3, 5] }
        word.chars.each_with_index do |_char, idx|
          # 排除*或已经做过的
          next if (_char == '*') || @guessed_chars[0..-2].include?(_char)

          ws = Length_to__char_num_to_words__hash[word_length]["#{_char}#{idx}".to_sym]
          @matched_words = @matched_words & (ws || [])
          @matched_words -= @unmatched_words
        end

        # 排除 包含匹配字母, 但是 *不在相同位置* 的单词
        word_idxes = idxes_of_char_in_the_word(word, _current_guess_char)
        aa = []
        @matched_words.delete_if do |_w|
          s = (idxes_of_char_in_the_word(_w, _current_guess_char) - word_idxes).any?
          aa << _w
          s
        end
        puts "删除了#{aa.size}个单词"

      else
        # reject no match words
        @matched_words.delete_if do |w|
          _r = w.to_s.include?(_current_guess_char)
          @unmatched_words << w if _r
          _r
        end
      end
      # break # 成功后继续猜 下一个字母
    end
    rescue => e
      e.class; require 'pry-debugger'; binding.pry
    end

    return _current_guess_char
  end

  # @return e.g. 'E'
  def current_guess_char
    case word.count("*")
    # 第一步: 依据词典词频找出第一个匹配的字母及其一或多个位置
    when word_length
      _char = (Hash[range.map {|num| PopularityOfLettersInLength[num] }.flatten.frequencies].keys - @guessed_chars).first
    # 第二步: 查找剩余字母，直到找完位置
    else
      setup_matched_words
      
      # 如果词典中所有单词都不匹配
      if @matched_words.nil?
        require 'pry-debugger'; binding.pry
      end
      return nil if @matched_words.size.zero?

      # 并求出接下来的字母及其位置
      # 当找到一个匹配后，就重新选择下一个最大机会匹配字母
      _char = select_next_vowel_or_consonant
    end

    return nil if _char.nil? # 兼容无单词情况, 比如猜测词是SUNDAY，但是词典里只SUNDAE有

    @guessed_chars << _char

    return _char
  end

  # @return e.g. [:N2, :N6]
  def matched_chars_with_idx
    __map_on_word(word, (proc do |c1, idx, _a|
      _a << "#{c1}#{idx}".to_sym if c1 != '*'
    end))
  end

  # @ return e.g. [3, 5]
  def rest_asterisk_idxes
    __map_on_word(word, (proc do |c1, idx, _a|
      _a << idx if c1 == '*'
    end))
  end

  def idxes_of_char_in_the_word _w, _c
    __map_on_word(_w, (proc do |c1, idx, _a|
      _a << idx if c1 == _c
    end))
  end

  # 如果前一个是元音，那么下一个就是辅音，如果没找到，继续辅音，
  # 直到找到，才切换下一个为元音。
  # 辅音同理。
  def select_next_vowel_or_consonant
    # avaible unguessed chars from @matched_words
    _chars = @matched_words.map {|_w1| _w1.to_s.chars.to_a }.flatten.frequencies.map(&:first) - @guessed_chars

    _list = VowelList.index(@guessed_chars[-1]) ? ConsonantList : VowelList
    _c1 = _chars.detect {|c| _list.index(c) }

    # 判断该字母在剩余位置是否还有匹配,
    # 如果没有，就调用下一个候选词
    _c1_idx = 0
    is_has_match = false
    while not is_has_match do
      _c1 ||= _chars[_c1_idx] # 兼容元音数量少的情况
      break if _chars.size.zero?

      is_has_match = !!(rest_asterisk_idxes.detect do |_idx|
        _result = Length_to__char_num_to_words__hash[word_length]["#{_c1}#{_idx}".to_sym]

        # 如果这个位置的字母不存在，那么就去@matched_words也删掉符合的
        @matched_words.delete_if do |_w1|
          _w1.to_s.chars.to_a[_idx] == _c1
        end if not _result

        _result
      end)

      if not is_has_match
        _c1_idx += 1
        _c1 = _chars[_c1_idx]
      end
    end

    _c1
  end

  def word_length; word.length end
  def range; word_length..word_length end
  def matched_chars_count; word.length - word.count('*').length end

  private
  def __map_on_word _w, _filter = (proc {|c1, idx, _a| })
    a = []
    _w.to_s.chars.each_with_index do |c1, idx|
      _filter.call(c1, idx, a)
    end
    return a
  end

  def setup_matched_words
    # 依据上面匹配字母及其位置找到所有符合单词
    if @matched_words.nil? && ((word_length - word.count('*')) > 0)
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
  end

end


class Hangman
  def self.word_recorder
    @@word_recorder ||= Logger.new(File.expand_path("../../strikingly_words.txt", __FILE__))
  end
end
