# encoding: UTF-8

require 'json'
require 'httparty'

REQUEST_URL = 'http://strikingly-interview-test.herokuapp.com/guess/process'
UserId = "moc.liamg@emojvm".reverse


def request data = {}
  HTTParty.post(REQUEST_URL, {
    :headers => {"Content-Type" => "application/json"},
    :body => ({
      :action  => "initiateGame",
      :userId  => UserId,
      :secret => ENV['SECRET']
    }).merge(data).to_json
  })
end


# 1. Initite Game
ENV['SECRET'] = request.parsed_response['secret']

# 2. Give Me A Word
@r = request(:action => "nextWord")

# 3. Make A Guess
@r.parsed_response['data'] # => {"numberOfWordsTried"=>1, "numberOfGuessAllowedForThisWord"=>10}

# return "**N***N"
def match_result w, c
  w.chars.map {|c1| (c == c1) ? c : '*' }.join
end

while @r.parsed_response['data']['numberOfWordsTried'] <= @r.parsed_response['data']['numberOfGuessAllowedForThisWord'] do
  @r = request(:action => 'guessWord', :guess => '')
end

# TODO write word to file



#  `curl -X POST -H "Content-Type: application/json" -d '{"action":"initiateGame","userId":"mvjome@gmail.com"}' #{REQUEST_URL}`
