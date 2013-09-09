# encoding: UTF-8

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

require 'hangman'

puts "单词长度对应的所有单词总数表"
Hangman::Length_to__words_count_hash.each {|k,v| puts "#{k}:#{v}" }
puts


class Test::Unit::TestCase
  def play_hangman source
    1.upto(source.number_of_words_to_guess) do |time|
      @hangman = Hangman.new(source)
      @hangman.init_guess

      puts "该单词长度为#{source.word.to_s.size}， 可以猜#{source.remain_time} 次。"
      while (!@hangman.done? && !source.remain_time.zero?) do
        print "#{source.remain_time}."

        # TODO 兼容不在词典里的，策略是give me a new word
        if @hangman.guess == "no char"
          break # no candidate letters, and @hangman will not connect source any more
        end

        if not @hangman.network_success? # 兼容网络错误
          @hangman = Hangman.new(source)
          @hangman.init_guess
        end

        if @hangman.source.current_response.nil? || @hangman.source.current_response.inspect.match(/HTTPServiceUnavailable/)
          require 'pry-debugger';binding.pry
        end

        begin
          sleep 3 if not source.network_success?
        rescue Timeout::Error, EOFError => e
          next
        rescue => e
          e.class; require 'pry-debugger'; binding.pry
        end
      end; print "\n"

      begin
      puts "第#{time}个单词 => #{@hangman.done? ? '成功' : '失败'}"
      puts "依次猜过的#{@hangman.guessed_chars.count}个字母: #{@hangman.guessed_chars.inspect}"
      puts "最终匹配结果 #{@hangman.source.inspect}"
        
      if (@hangman.matched_words.count == 1) && (@hangman.matched_words[0].to_s == @hangman.word)
        puts "猜中的单词是#{@hangman.word}！"
      else
        puts "还没猜完的#{@hangman.matched_words.count}个单词: #{@hangman.matched_words.inspect}"
      end
      puts
      rescue => e
       require 'pry-debugger';binding.pry
      end

    end

    result = source.get_test_results['data']
    total = result['numberOfWordsTried'].to_f
    score = result['numberOfCorrectWords'].to_f
    puts "猜单词结果是: #{result.inspect}"
    if ((score / total) > 0.75) && (score > @scores.max.to_i)
      # TODO 多个进程共享最大猜测数
      source.submit_test_results if score >= 69 # TODO update
    end if @scores
    return score
  end 

end
