# encoding: UTF-8

require File.expand_path('../test_helper.rb', __FILE__)

ws1 = %w[COMAKER CUMULATE ERUPTIVE FACTUAL MONADISM MUS NAGGING OSES REMEMBERED SPODUMENES STEREOISOMERS TOXICS TRICHROMATS TRIOSE UNIFORMED]

ws2 = File.read(File.expand_path('../../data/1000words.txt', __FILE__)).split


class TestHangman < Test::Unit::TestCase
  def setup
    puts "单词长度对应的所有单词总数表"
    Hangman::Length_to__words_count_hash.each {|k,v| puts "#{k}:#{v}" }
    puts 
    @si = StrikinglyInterview.new(ENV['EMAIL'] || "moc.liamg@emojvm".reverse)
  end

  def test_hangman
    @scores = []

    100.times do
    1.upto(@si.data['numberOfWordsToGuess']) do |time|
      @hangman = Hangman.new(@si)
      @hangman.init_guess

      puts "该单词长度为#{@si.word.size}， 可以猜#{@si.remain_time} 次。"
      while (!@hangman.done? && !@si.remain_time.zero?) do
        print "#{@si.remain_time}."
        begin
          @hangman.guess
        rescue => e
          e.class; require 'pry-debugger'; binding.pry
          # TODO EOFError: end of file reached
        end
      end
      print "\n"

      @hangman.done?
      puts "第#{time}次 #{@hangman.done? ? '成功' : '失败'}"
      puts "依次猜过的#{@hangman.guessed_chars.count}个字母: #{@hangman.guessed_chars.inspect}"
      puts "最终匹配结果 #{@hangman.source.inspect}"
      if @hangman.matched_words.count == 1
        puts "猜中的单词是#{@hangman.word}！"
      else
        puts "还没猜完的#{@hangman.matched_words.count}个单词: #{@hangman.matched_words.inspect}"
      end
      puts
    end

    result = @si.get_test_results
    total = result['data']['numberOfWordsTried'].to_f
    score = @si.current_response['data']['numberOfCorrectWords']
    if ((score / total) > 0.75) && (score > @scores.max.to_i)
      @si.submit_test_results 
    end

    @scores << score
    `echo #{score} >> scores`
    puts @scores.sort.inspect
    end

  end
end
