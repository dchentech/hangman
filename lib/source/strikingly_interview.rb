# encoding: UTF-8

require 'json'
require 'httparty'


class StrikinglyInterview
  REQUEST_URL = 'http://strikingly-interview-test.herokuapp.com/guess/process'

  attr_reader :secret, :current_response
  attr_accessor :hangman

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
  # @r.parsed_response['data'] # => {"numberOfWordsTried"=>1, "numberOfGuessAllowedForThisWord"=>10}
  # @r.parsed_response['word']

  # 4. Get Test Results
  def get_test_results
    @current_response = request(:action => 'getTestResults')
  end

  def submit_test_results
    @current_response = request(:action => 'submitTestResults')
  end

  def word; current_response['word'] end
  def guessed_time; data['numberOfWordsTried'].to_i end
  def remain_time; data['numberOfGuessAllowedForThisWord'].to_i end

  def data
    if @current_response['data'].nil? && @current_response.respond_to?(:code) #503, 400
      {}
    else
      @current_response['data']
    end
  end
  def status; @current_response['status']; end
  def success?; @current_response.success? end

  def request data = {}
    HTTParty.post(REQUEST_URL, {
      :headers => {"Content-Type" => "application/json"},
      :body => ({
        :action  => "initiateGame",
        :userId  => @user_id,
        :secret => @secret
      }).merge(data).to_json
    })
  end

  def inspect
    "#<#{self.class}:#{self.object_id.to_s(16)} @user_id=#{@user_id.inspect}, @current_response=#{@current_response.inspect}>"
  end

end

#  `curl -X POST -H "Content-Type: application/json" -d '{"action":"initiateGame","userId":""}' #{REQUEST_URL}`
