require File.join(ENV['HOME'], 'utils/ruby/irb') rescue nil
require 'rubygems'
require 'bundler'
begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end
require 'test/unit'

$LOAD_PATH.unshift File.join(File.dirname(__FILE__), '..', 'lib')
$LOAD_PATH.unshift File.dirname(__FILE__) # test dirs


require 'json'
require 'httparty'
require 'hangman'


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
    # TODO
  end

  while @r.parsed_response['data']['numberOfWordsTried'] <= @r.parsed_response['data']['numberOfGuessAllowedForThisWord'] do
  end if nil

  def word; current_response['word'] end
  def guessed_time; data['numberOfWordsTried'].to_i end
  def remain_time; data['numberOfGuessAllowedForThisWord'].to_i end

  def data
    begin
    if @current_response['data'].nil? && @current_response.responde_to?(:code) #503, 400
      {}
    else
      @current_response['data']
    end
    rescue => e
      e.class; require 'pry-debugger'; binding.pry
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

end

# TODO write word to file

#  `curl -X POST -H "Content-Type: application/json" -d '{"action":"initiateGame","userId":""}' #{REQUEST_URL}`
