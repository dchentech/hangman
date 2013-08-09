# encoding: UTF-8

require File.expand_path('../test_helper.rb', __FILE__)

class HangmanTest < Test::Unit::TestCase
  def setup
    @ws1 = %w[COMAKER CUMULATE ERUPTIVE FACTUAL MONADISM MUS NAGGING OSES REMEMBERED SPODUMENES STEREOISOMERS TOXICS TRICHROMATS TRIOSE UNIFORMED]
    @ws2 = File.read(File.expand_path('../../data/1000words.txt', __FILE__)).split
    #@local1 = Hangman::Local.new(%w[WORD])
    #@h = Hangman.new(@local1)
  end


  def test_local
    play_hangman Hangman.new(Hangman::Local.new(%w[WORD]))
  end if not ENV['StrikinglyInterview']

  def test_idxes_of_char_in_the_word
    @h = Hangman.new(Hangman::Local.new(%w[WORD]))
    @h.init_guess

    assert_equal [1, 2], @h.idxes_of_char_in_the_word('WOOD', 'O')
  end

  def test_current_guess_char
    @h = Hangman.new(Hangman::Local.new(%w[WORD]))
    @h.init_guess

    assert_equal "A", @h.current_guess_char
    assert_equal "E", @h.current_guess_char
  end

  def test_matched_chars_with_idx
    @h = Hangman.new(Hangman::Local.new(%w[WORD]))
    @h.init_guess

    assert_equal([], @h.matched_chars_with_idx)
  end

  def test_others
    @h = Hangman.new(Hangman::Local.new(%w[WORD]))
    @h.init_guess

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

  def test_words
    # Hangman::Words.select {|w| w[2..4] == 'EAC' }.select {|w| w.size == 10 } => ["BLEACHABLE", "PREACHIEST", "PREACHMENT"]
    # *E**E*BE*
    # Hangman::Words.select {|w| w[2..4] == 'EAC' }.select {|w| w.size == 10 } => ["BLEACHABLE", "PREACHIEST", "PREACHMENT"]
    # test PSALM
    #@local1 = Hangman::Local.new(["BLEACHABLE", "PREACHIEST", "PREACHMENT"])
    #@h = Hangman.new(@local1)
    # 20.times { @h.guess }
  end

  def test_PSALM
    @h = Hangman.new(Hangman::Local.new(%w[PSALM]))
    @h.init_guess

    15.times { @h.guess }
  end

  private
  def hg words
    s = Hangman.new(Hangman::Local.new(words))
    s.init_guess
    s
  end
end
