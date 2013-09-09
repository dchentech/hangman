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

#  `curl -X POST -H "Content-Type: application/json" -d '{"action":"initiateGame","userId":""}' #{REQUEST_URL}`

# TODO 还是没有排除掉
# TODO test methods
__END__
ZETA应该被排除掉



该单词长度为13， 可以猜10 次。
10.删除了741个单词
10.删除了37个单词
10.删除了0个单词
10.
第71个单词 => 失败
依次猜过的3个字母: ["I", "C", "A"]
最终匹配结果 #<Hangman::StrikinglyInterview:3fc3345bf8c4 @user_id="mvjome@gmail.com", @current_response=#<HTTParty::Response:0x7f866d4341d0 parsed_response={"word"=>"C***A**I*A***", "userId"=>"mvjome@gmail.com", "secret"=>"7OXP61ISCVUNMITZRKEN1PWFA5G66R", "status"=>200, "data"=>{"numberOfWordsTried"=>71, "numberOfGuessAllowedForThisWord"=>10}}, @response=#<Net::HTTPOK 200 OK readbody=true>, @headers={"access-control-allow-headers"=>["X-Requested-With,Content-Type"], "access-control-allow-methods"=>["GET,PUT,POST,DELETE"], "access-control-allow-origin"=>["*"], "content-type"=>["application/json; charset=utf-8"], "date"=>["Sat, 10 Aug 2013 04:44:53 GMT"], "x-powered-by"=>["Express"], "content-length"=>["177"], "connection"=>["Close"]}>>
还没猜完的0个单词: []

Started
...删除了706个单词
..该单词长度为4， 可以猜10 次。
10.删除了200个单词
10.9.8.7.
第1次 失败
依次猜过的5个字母: ["A", "B", "E", "C", "I"]
最终匹配结果 #<Hangman::StrikinglyInterview:3fd8542ee7c8 @user_id="mvjome@gmail.com", @current_response=#<HTTParty::Response:0x7fb0a8709698 parsed_response="<!DOCTYPE html PUBLIC \"-//W3C//DTD XHTML 1.0 Transitional//EN\" \"http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd\">\n    <html>\n    <head>\n      <meta http-equiv=\"content-type\" content=\"text/html; charset=ISO-8859-1\">\n      <style type=\"text/css\">\n        html, body, iframe { margin: 0; padding: 0; height: 100%; }\n        iframe { display: block; width: 100%; border: none; }\n      </style>\n    <title>Application Error</title></head>\n    </head>\n    <body>\n      <iframe src=\"//s3.amazonaws.com/heroku_pages/error.html\">\n        <p>Application Error</p>\n      </iframe>\n    </body>\n    </html>", @response=#<Net::HTTPServiceUnavailable 503 Service Unavailable readbody=true>, @headers={"content-type"=>["text/html"], "date"=>["Fri, 09 Aug 2013 13:53:10 GMT"], "server"=>["MochiWeb/1.0 (Any of you quaids got a smint?)"], "content-length"=>["601"], "connection"=>["Close"]}>>
还没猜完的87个单词: [:DITA, :DIVA, :DONA, :DOPA, :DUMA, :DURA, :FILA, :FORA, :GIGA, :GLIA, :HILA, :HORA, :HOYA, :HULA, :HYLA, :ILIA, :ILKA, :INIA, :IOTA, :IXIA, :JOTA, :JUGA, :JURA, :KINA, :KIVA, :KOLA, :KUNA, :LIMA, :LIPA, :LIRA, :LOTA, :LUNA, :MINA, :MOLA, :MORA, :MOXA, :MURA, :MYNA, :NIPA, :NOMA, :NONA, :NOTA, :NOVA, :OHIA, :OKRA, :OLLA, :ORRA, :OSSA, :PIKA, :PIMA, :PINA, :PITA, :PROA, :PUJA, :PULA, :PUMA, :PUNA, :PUPA, :ROTA, :RUGA, :SIMA, :SKUA, :SODA, :SOFA, :SOJA, :SOLA, :SOMA, :SORA, :SOYA, :STOA, :SURA, :TOGA, :TOLA, :TORA, :TUFA, :TUNA, :ULNA, :ULVA, :URSA, :VIGA, :VINA, :VISA, :VITA, :VIVA, :WHOA, :YOGA, :YUGA]

该单词长度为4， 可以猜10 次。
10.9.9.8.7.6.5.4.3.2.1.
第12次 失败
依次猜过的11个字母: ["A", "E", "N", "O", "R", "I", "B", "C", "D", "L", "F"]
最终匹配结果 #<StrikinglyInterview:3ffb22da7674 @user_id="mvjome@gmail.com", @current_response=#<HTTParty::Response:0x7ff645d6cf48 parsed_response={"word"=>"*E**", "userId"=>"mvjome@gmail.com", "secret"=>"TYD36RK7F4W2VS4IC54DTSZTXEBNVC", "status"=>200, "data"=>{"numberOfWordsTried"=>12, "numberOfGuessAllowedForThisWord"=>0}}, @response=#<Net::HTTPOK 200 OK readbody=true>, @headers={"access-control-allow-headers"=>["X-Requested-With,Content-Type"], "access-control-allow-methods"=>["GET,PUT,POST,DELETE"], "access-control-allow-origin"=>["*"], "content-type"=>["application/json; charset=utf-8"], "date"=>["Fri, 09 Aug 2013 04:34:40 GMT"], "x-powered-by"=>["Express"], "content-length"=>["167"], "connection"=>["Close"]}>>
还没猜完的119个单词: [:GEEK, :GEES, :GEEZ, :GEMS, :GEST, :GETA, :GETS, :GEUM, :HEAP, :HEAT, :HEHS, :HEME, :HEMP, :HEMS, :HEST, :HETH, :HETS, :HEWS, :JEEP, :JEES, :JEEZ, :JEHU, :JESS, :JEST, :JETE, :JETS, :JEUX, :JEWS, :KEAS, :KEEK, :KEEP, :KEET, :KEGS, :KEMP, :KEPS, :KEPT, :KEYS, :MEAT, :MEEK, :MEET, :MEGS, :MEME, :MEMS, :MESA, :MESH, :MESS, :META, :METE, :METH, :MEWS, :MEZE, :PEAG, :PEAK, :PEAS, :PEAT, :PEEK, :PEEP, :PEES, :PEGS, :PEHS, :PEKE, :PEPS, :PEST, :PETS, :PEWS, :SEAM, :SEAS, :SEAT, :SEEK, :SEEM, :SEEP, :SEES, :SEGS, :SEME, :SEPT, :SETA, :SETS, :SETT, :SEWS, :SEXT, :SEXY, :TEAK, :TEAM, :TEAS, :TEAT, :TEEM, :TEES, :TEGS, :TEMP, :TEPA, :TEST, :TETH, :TETS, :TEWS, :TEXT, :VEEP, :VEES, :VEST, :VETS, :VEXT, :WEAK, :WEEK, :WEEP, :WEES, :WEET, :WEKA, :WEPT, :WEST, :WETS, :YEAH, :YEAS, :YEGG, :YETT, :YEUK, :YEWS, :ZEES, :ZEKS, :ZEST, :ZETA]

该单词长度为4， 可以猜10 次。
10.9.9.8.7.6.5.4.3.2.1.
第6次 失败
依次猜过的11个字母: ["A", "E", "B", "O", "C", "I", "G", "H", "J", "K", "L"]
最终匹配结果 #<StrikinglyInterview:3ffb22da7674 @user_id="mvjome@gmail.com", @current_response=#<HTTParty::Response:0x7ff641ef3af0 parsed_response={"word"=>"**E*", "userId"=>"mvjome@gmail.com", "secret"=>"TYD36RK7F4W2VS4IC54DTSZTXEBNVC", "status"=>200, "data"=>{"numberOfWordsTried"=>6, "numberOfGuessAllowedForThisWord"=>0}}, @response=#<Net::HTTPOK 200 OK readbody=true>, @headers={"access-control-allow-headers"=>["X-Requested-With,Content-Type"], "access-control-allow-methods"=>["GET,PUT,POST,DELETE"], "access-control-allow-origin"=>["*"], "content-type"=>["application/json; charset=utf-8"], "date"=>["Fri, 09 Aug 2013 04:33:33 GMT"], "x-powered-by"=>["Express"], "content-length"=>["166"], "connection"=>["Close"]}>>
还没猜完的125个单词: [:AMEN, :ANES, :ANEW, :APED, :APER, :APES, :APEX, :AREA, :ARES, :ASEA, :ATES, :AVER, :AVES, :AWED, :AWEE, :AWES, :AXED, :AXES, :AYES, :DEED, :DEEM, :DEEP, :DEER, :DEES, :DEET, :DREE, :DREW, :DUES, :DUET, :DYED, :DYER, :DYES, :EMES, :EMEU, :EPEE, :ESES, :EVEN, :EVER, :EVES, :EWER, :EWES, :EXES, :EYED, :EYEN, :EYER, :EYES, :FEED, :FEES, :FEET, :FREE, :FRET, :MAES, :MEED, :MEET, :NEED, :NEEM, :NEEP, :PEED, :PEEN, :PEEP, :PEER, :PEES, :PREE, :PREP, :PREX, :PREY, :PREZ, :PYES, :QUEY, :REED, :REEF, :REES, :RUED, :RUER, :RUES, :RYES, :SEED, :SEEM, :SEEN, :SEEP, :SEER, :SEES, :SMEW, :SNED, :SPED, :SPEW, :STEM, :STEP, :STET, :STEW, :STEY, :SUED, :SUER, :SUES, :SUET, :TEED, :TEEM, :TEEN, :TEES, :TREE, :TREF, :TRET, :TREY, :TWEE, :TYEE, :TYER, :TYES, :UREA, :USED, :USER, :USES, :UVEA, :VEEP, :VEER, :VEES, :WAES, :WEED, :WEEN, :WEEP, :WEER, :WEES, :WEET, :WREN, :WYES, :ZEES]
