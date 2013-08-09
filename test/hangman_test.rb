# encoding: UTF-8

require File.expand_path('../test_helper.rb', __FILE__)

class HangmanTest < Test::Unit::TestCase
  def setup
    @ws1 = %w[COMAKER CUMULATE ERUPTIVE FACTUAL MONADISM MUS NAGGING OSES REMEMBERED SPODUMENES STEREOISOMERS TOXICS TRICHROMATS TRIOSE UNIFORMED]
    @ws2 = File.read(File.expand_path('../../data/1000words.txt', __FILE__)).split
  end

  def test_local
    play_hangman Hangman::Local.new
  end if not ENV['StrikinglyInterview']

end
