# encoding: UTF-8

require File.expand_path('../test_helper.rb', __FILE__)

class HangmanTest < Test::Unit::TestCase
  def setup
    @ws1 = %w[COMAKER CUMULATE ERUPTIVE FACTUAL MONADISM MUS NAGGING OSES REMEMBERED SPODUMENES STEREOISOMERS TOXICS TRICHROMATS TRIOSE UNIFORMED]
    @ws2 = File.read(File.expand_path('../../data/1000words.txt', __FILE__)).split
    @local1 = Hangman::Local.new(%w[WORD])
    @h = Hangman.new(@local1)
  end


  def test_local
    play_hangman @local1
  end if not ENV['StrikinglyInterview']

  def test_idxes_of_char_in_the_word
    assert_equal [1, 2], @h.idxes_of_char_in_the_word('WOOD', 'O')
  end

  def test_current_guess_char
    fake_h
    assert_equal "A", @h.current_guess_char
    assert_equal "E", @h.current_guess_char
  end

  def test_matched_chars_with_idx
    fake_h
    assert_equal([], @h.matched_chars_with_idx)
  end

  def test_others
    fake_h

    assert_equal(false,  @h.done?)
    assert_equal "A", @h.guess
    assert_equal nil, @h.matched_words
    assert_equal "E", @h.guess
    assert_equal nil, @h.matched_words
    assert_equal "S", @h.guess
    assert_equal nil, @h.matched_words
    assert_equal "O", @h.guess
    assert_equal "*O**", @h.word
    assert_equal false, @h.matched_words.size.zero?
    # require 'pry-debugger'; binding.pry
    @h.guess
  end

  private
  def fake_h
    @h.init_guess
  end
end
