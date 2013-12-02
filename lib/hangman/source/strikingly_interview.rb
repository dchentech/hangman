# encoding: UTF-8

class Hangman
  class StrikinglyInterview < Source
    require 'httparty'
    REQUEST_URL = 'http://strikingly-interview-test.herokuapp.com/guess/process'

    attr_reader :secret, :current_response

    def initialize userId
      @user_id = userId

      # 1. Initite Game
      @current_response = request.parsed_response
      @secret ||= @current_response['secret']

      return self
    end

    # 2. Give Me A Word
    def give_me_a_word
      @current_response = request(:action => "nextWord")
    end

    # 3. Make A Guess
    def make_a_guess char
      @current_response = request(:action => 'guessWord', :guess => char)
    end

    # 4. Get Test Results
    def get_test_results
      @current_response = request(:action => 'getTestResults')
    end

    def submit_test_results
      @current_response = request(:action => 'submitTestResults')
    end

    def word; current_response['word'] end
    # TODO 统一给所有request机上
    def init_guess
      s = give_me_a_word
      # compatible with network error at the first time
      while not network_success? do
        s = give_me_a_word
        sleep 3
      end
      s
    end
    def guessed_time; data['numberOfWordsTried'].to_i end
    def remain_time; data['numberOfGuessAllowedForThisWord'].to_i end
    def number_of_words_to_guess; data['numberOfWordsToGuess']; end

    def data
      if @current_response['data'].nil? && @current_response.respond_to?(:code) #503, 400
        {}
      else
        @current_response['data']
      end
    end
    def status; @current_response['status']; end
    def network_success?; @current_response.success? end

    def request data = {}
      opts = {
        :headers => {"Content-Type" => "application/json"},
        :body => ({
          :action  => "initiateGame",
          :userId  => @user_id,
          :secret => @secret
        }).merge(data).to_json
      }

      result  = nil
      while true do
        begin
          result = HTTParty.post(REQUEST_URL, opts)
          break if result && result.success?
        rescue Timeout::Error, EOFError
          sleep 3
          next
        end
      end
      result
    end

    def inspect
      "#<#{self.class}:#{self.object_id.to_s(16)} @user_id=#{@user_id.inspect}, @current_response=#{@current_response.inspect}>"
    end

  end

end
