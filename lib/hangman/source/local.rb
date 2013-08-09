# encoding: UTF-8

class Hangman::Local < Hangman::Source
  def initialize user_id = nil
    @words ||= Words.dup.map(&:to_s).select {|w| w.length < 19 }.shuffle[0..(number_of_words_to_guess-1)]
  end

  def word
    @word
  end

  def number_of_words_to_guess
    80
  end

  def init_a_guess
    @numberOfWordsTried ||= 1
    @numberOfGuessAllowedForThisWord ||= 10
  end

  def give_me_a_word
    @word = @words.pop
    @marked_word_hash = (0..(@word.length-1)).inject({}) {|h, n| h[n] = '*'; h }
  end
  
  def make_a_guess char
    is_not_desc_remain_only_already = true
    @word.chars.to_a.each_with_index do |_c, idx|
      if char == _c
        if (@remain_time > 0) && is_not_desc_remain_only_already
          @remain_time -= 1 
          is_not_desc_remain_only_already = false
        end
        @marked_word_hash[idx] = _c 
      end
    end

    @current_response = {
      "word" => @marked_word_hash.values.join,
      "data" => data
    }
  end

  def network_success?
    true
  end

  def guessed_time
    10 - remain_time
  end

  def remain_time
    @remain_time ||= 10
  end

  def current_response
    {
      'word' => @marked_word_hash.values.join,
      'data' => data
    }
  end

  def data
    {
      "numberOfWordsTried" => @numberOfWordsTried,
      "numberOfGuessAllowedForThisWord" => @numberOfGuessAllowedForThisWord
    }
  end

end
