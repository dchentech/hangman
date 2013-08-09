# encoding: UTF-8

class Hangman
  class Local < Source
    def initialize user_id = nil
      @words ||= Hangman::Words.dup.map(&:to_s).select {|w| w.length < 19 }.shuffle[0..(number_of_words_to_guess-1)]
    end

    def number_of_words_to_guess; 80 end

    def init_guess
      @numberOfWordsTried = 1
      @numberOfGuessAllowedForThisWord = 11
      give_me_a_word
    end

    def give_me_a_word
      @word = @words.pop
      @marked_word_hash = (0..(@word.length-1)).inject({}) {|h, n| h[n] = '*'; h }
    end
    
    def make_a_guess char
      is_not_desc_remain_only_already = true
      @word.chars.to_a.each_with_index do |_c, idx|
        if char == _c
          if (remain_time > 0) && is_not_desc_remain_only_already
            @numberOfWordsTried += 1
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

    def network_success?; true end
    def remain_time; @numberOfGuessAllowedForThisWord - guessed_time end
    def guessed_time; @numberOfWordsTried end
    def word; current_response['word'] end
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
end
