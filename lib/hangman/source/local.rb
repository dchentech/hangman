# encoding: UTF-8

class Hangman
  class Local < Source
    def initialize _words = nil
      @words = _words
      @words ||= Hangman::Words.dup.map(&:to_s).select {|w| w.length < 19 }.shuffle[0..(number_of_words_to_guess-1)]
      @numberOfWordsTried = 0

      @numberOfCorrectWords = 0
      @numberOfWrongGuess = 0
      @totalScore = 0 # TODO
    end

    def give_me_a_word
      @numberOfWordsTried += 1
      @numberOfGuessAllowedForThisWord = 10
      @guessed_time = 0
      @word = @words.pop
      raise "no word anymore" if @word.nil?
      @marked_word_hash = (0..(@word.length-1)).inject({}) {|h, n| h[n] = '*'; h }
    end

    def make_a_guess char
      _old_asterisk_count = @marked_word_hash.values.count('*')

      is_not_desc_remain_only_already = true
      @word.chars.to_a.each_with_index do |_c, idx|
        # 这次 如果猜中了
        if char == _c
          @marked_word_hash[idx] = _c 
          is_not_desc_remain_only_already = false
        end
      end
      # 这次 没猜中就给 @guessed_time 加一次一
      if is_not_desc_remain_only_already && (remain_time > 0)
        @guessed_time += 1
      end

      if @marked_word_hash.values.count('*') < _old_asterisk_count
      else
        @numberOfGuessAllowedForThisWord -= 1
        @numberOfWrongGuess += 1
      end
      @numberOfCorrectWords += 1 if @marked_word_hash.values.count('*').zero?

      @current_response = {
        "word" => @marked_word_hash.values.join,
        "data" => data
      }
    end

    def init_guess; give_me_a_word end
    def get_test_results; current_response end
    def submit_test_results; end

    def number_of_words_to_guess; 80 end
    def network_success?; true end
    def remain_time; 10 - guessed_time end
    def word; current_response['word'] end
    def current_response
      {
        'word' => @marked_word_hash.values.join,
        'data' => data
      }
    end

    def data
      if @numberOfWordsTried == number_of_words_to_guess
        {
          "numberOfWordsTried" => @numberOfWordsTried,
          "numberOfCorrectWords" => @numberOfCorrectWords,
          "numberOfWrongGuesses" => (@numberOfWordsTried - @numberOfCorrectWords),
          "totalScore" => @totalScore,
        }
      else
        {
          "numberOfWordsTried" => @numberOfWordsTried,
          "numberOfGuessAllowedForThisWord" => @numberOfGuessAllowedForThisWord
        }
      end
    end

    def inspect
      "#<#{self.class}:#{self.object_id.to_s(16)} @guessed_time=#{@guessed_time} @word=#{@word} @current_response=#{@current_response}>"
    end

  end

end
