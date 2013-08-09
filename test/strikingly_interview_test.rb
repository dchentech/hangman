# encoding: UTF-8

require File.expand_path('../test_helper.rb', __FILE__)

class StrikinglyInterviewTest < HangmanTest
  def test_hangman
    @scores = []

    100.times do
      play_hangman Hangman::StrikinglyInterview.new(ENV['EMAIL'] || "moc.liamg@emojvm".reverse)

      @scores << score
      `echo #{score} >> scores`
      puts @scores.sort.inspect
    end

  end if nil

end


__END__
c = @hangman.guess

if !@hangman.is_current_matched? && (@hangman.matched_words || []).detect {|w| w.to_s.include?(c) }
  require 'pry-debugger'; binding.pry
end

