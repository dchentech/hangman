# encoding: UTF-8

require 'json'

class Hangman
  class Source
    attr_accessor :hangman
    attr_reader   :current_response

    InstanceMethods = [
      :word,
      :number_of_words_to_guess,
      :init_guess,
      :make_a_guess,
      :give_me_a_word,
      :network_success?,
      :guessed_time,
      :remain_time,
    ]

  end

end

require File.expand_path("./../source/local.rb", __FILE__)
require File.expand_path("./../source/strikingly_interview.rb", __FILE__)
