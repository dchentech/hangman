# encoding: UTF-8

require File.expand_path('../ruby_ext.rb', __FILE__)
require File.expand_path('../remote.rb', __FILE__)

# popularity of letters in dictionary words grouped by the length of those words
# copied from http://www.datagenetics.com/blog/april12012/index.html 统计学意义上
class Hangman
  PopularityOfLettersData = <<-EOF
    1 2 3	4	5	6	7	8	9	10	11	12	13	14	15	16	17	18	19	20
#1	A	A	A	A	S	E	E	E	E E   E   E   I   I   I   I   I   I   I   I
#2	I	O	E	E	E	S	S	S	S I   I   I   E   E   E   E   E   S   E   O
#3	.	E	O	S	A	A	I	I	I S   S   S   N   T   T   T   T   E   T   E
#4	.	I	I	O	R	R	A	A	R R   N   N   T   S   N   S   N   T   O   T
#5	.	M	T	I	O	I	R	R	A A   A   T   S   N   S   N   S   O   N   R
#6	.	H	S	R	I	O	N	N	N N   R   A   A   A   O   A   O   N   A   S
#7	.	N	U	L	L	L	T	T	T T   T   R   O   O   A   O   A   R   S   A
#8	.	U	P	T	T	N	O	O	O O   O   O   R   R   R   R   R   A   R   N
#9	.	S	R	N	N	T	L	L	L L   L   L   L   L   L   L   L   L   L   C
#10	.	T	N	U	U	D	D	D	C C   C   C   C   C   C   C   C   C   C   L
#11	.	Y	D	D	D	U	U	C	D D   U   P   P   P   P   P   P   P   P   P
#12	.	B	B	P	C	C	C	U	U U   D   U   U   U   U   U   U   M   M   H
#13	.	L	G	M	Y	M	G	G	G G   P   M   M   M   M   M   M   U   U   U
#14	.	P	M	H	P	P	P	M	M M   M   D   G   D   D   H   H   H   H   M
#15	.	X	Y	C	M	G	M	P	P P   G   G   D   H   H   D   D   D   D   Y
#16	.	D	L	B	H	H	H	H	H H   H   H   H   G   G   Y   G   G   G   D
#17	.	F	H	K	G	B	B	B	B B   B   Y   Y   Y   Y   G   Y   Y   Y   G
#18	.	R	W	G	B	Y	Y	Y	Y Y   Y   B   B   B   B   B   B   B   B   B
#19	.	W	F	Y	K	K	F	F	F F   F   V   V   V   V   V   V   V   V   Z
#20	.	G	C	W	F	F	K	K	V V   V   F   F   F   F   F   F   Z   F   V
#21	.	J	K	F	W	W	W	W	K K   K   Z   Z   Z   Z   Z   Z   F   Z   F
#22	.	K	X	V	V	V	V	V	W W   W   K   X   X   X   X   X   X   X   K
#23	.	.	V	J	Z	Z	Z	Z	Z Z   Z   W   K   K   W   W   Q   Q   K   X
#24	.	.	J	Z	X	X	X	X	X X   X   X   W   W   K   Q   W   W   J   J
#25	.	.	Z	X	J	J	J	Q	Q Q   Q   Q   Q   Q   Q   K   J   K   Q   Q
#26	.	.	Q	Q	Q	Q	Q	J	J J   J   J   J   J   J   J   K   .   W   .
EOF

  # 构造 {length => [character, ]}
  data_lines = PopularityOfLettersData.split("\n").map(&:chomp).map(&:split)
  PopularityOfLettersInLength = data_lines[0].inject({}) do |h, idx|
    idx = idx.to_i
    h[idx] = data_lines[1..-1].map {|a| a[idx] }.reject {|i| i == '.' }
    h
  end

  # 1000单词中，U 占两百多，AEIOS找五六七百
  VowelList = %w[A E I O]
  ConsonantList = ('A'..'Z').to_a - VowelList + %w[U]

  # 获取单词列表
  # http://nifty.stanford.edu/2011/schwarz-evil-hangman/dictionary.txt
  # 里面已包含 Plural, Tenses Adjectives
  words = (File.read(File.expand_path('../../data/words.txt', __FILE__)).split("\n") + %w[a i]).map(&:upcase)

  # 建立有位置信息的字母 映射到 单词 的哈希表
  # {len => { :char_pos => words } }
  #
  # TODO 其他数据结构，但这个只能提高查找效率，不能减少猜字母的次数。
  # {:len_char_pos => words }
  # {:len => {char => { pos => words } } }
  _h = Hash.new { 0 }
  Length_to__char_num_to_words__hash = words.inject({}) do |h, w|
    _h[w.length] += 1

    h[w.length] ||= {}
    w.chars.each_with_index do |c, c_idx|
      _sym = "#{c}#{c_idx}".to_sym
      h[w.length][_sym] ||= []
      h[w.length][_sym] << w.to_sym
    end
    h
  end
  Length_to__words_count_hash = _h
  Length_to__char_num_to_words__hash.keys

  def select_guess_chars_order_by_frequency_in_range range
    Hash[range.map {|num| PopularityOfLettersInLength[num] }.flatten.frequencies].keys
  end

  # return "**N***N"
  def match_result w, c
    w.chars.map {|c1| (c == c1) ? c : '*' }.join
  end

  # return %W[C Z J]
  def next_guess_chars matched_words
    matched_words.map {|_w1| _w1.to_s.chars.to_a }.flatten.frequencies.map(&:first) - @guessed_chars
  end

  # return [:N2, :N6]
  def matched_char_with_idx_in_str _result
    _a = []
    _result.chars.each_with_index do |c1, idx|
      _a << "#{c1}#{idx}".to_sym if c1 != '*'
    end
    _a
  end

  def guessing_word
    @char_with_idx_array.sort_by {|c3| c3.to_s[1..-1].to_i }.map {|c3| c3[0] }.join
  end

  # 如果前一个是元音，那么下一个就是辅音，如果没找到，继续辅音，
  # 知道找到，才切换下一个为元音。
  # 辅音同理。
  def select_next_vowel_or_consonant
    _cs = next_guess_chars(@matched_words)
    _list = VowelList.index(@guessed_chars[-1]) ? ConsonantList : VowelList
    _c1 = _cs.detect {|c| _list.index(c) }
    _c1 || _cs[0] # 兼容元音数量少的情况
  end

  def guess_word range, w1 = nil
    w1.upcase!
    @w1_length = nil
    @matched_chars_count = 0
    @guessed_time = 0
    @char_with_idx_array = []
    @guessed_chars = []
    @matched_words = nil

    # 第一步: 依据词典词频找出第一个匹配的字母及其一或多个位置
    select_guess_chars_order_by_frequency_in_range(range).each do |c1|
      @guessed_time += 1
      @guessed_chars << c1
      result = match_result(w1, c1)
      @w1_length ||= result.length
      puts "[字频匹配] #{c1}: #{result}"
      @matched_chars_count += (@w1_length - result.count('*'))
      if @matched_chars_count > 0
        @char_with_idx_array += matched_char_with_idx_in_str(result)
        break
      end
    end

    # 退出，比如全部都是重复字母，包括一两个字母，比如A, AA
    return @guessed_time if @char_with_idx_array.length == @w1_length

    # 依据上面匹配字母及其位置找到所有符合单词
    matched_words_array = @char_with_idx_array.map do |_char_with_idx|
      Length_to__char_num_to_words__hash[@w1_length][_char_with_idx]
    end
    if matched_words_array.size.zero?
      puts "no matched word" 
      return @guessed_time
    end
    matched_words_array.each do |_a1|
      @matched_words ||= _a1 # init data
      @matched_words = @matched_words & _a1
    end

    # 第二步: 查找剩余字母，直到找完位置
    while (@matched_chars_count != @w1_length) do
      # 如果所有单词都不匹配
      break if @matched_words.size.zero?

      # 并求出接下来的字母及其位置
      # 当找到一个匹配后，就重新选择下一个最大机会匹配字母
      c1 = select_next_vowel_or_consonant
      break if c1.nil? # 兼容无单词情况, 比如猜测词是SUNDAY，但是词典里只SUNDAE有

      @guessed_chars << c1
      @guessed_time  += 1
      result         = match_result w1, c1

      _count = (@w1_length - result.count('*'))
      # 有匹配
      if _count > 0
        # 根据匹配的位置继续过滤 候选单词列表
        # return { char => [3, 5] }
        _char_to_idx_hash = {}
        result.chars.each_with_index do |c2, idx|
          _char_to_idx_hash[c2] ||= []
          _char_to_idx_hash[c2] << idx
        end
        _char_to_idx_hash[c1].map do |idx|
          Length_to__char_num_to_words__hash[@w1_length]["#{c1}#{idx}".to_sym]
        end.each do |_words|
          @matched_words = @matched_words & _words
        end
        @matched_chars_count += _count
        @char_with_idx_array += matched_char_with_idx_in_str(result)
        # break # 成功后继续猜 下一个字母
      # 无匹配
      else
        # next
      end

      puts "[剩余单词数量#{@matched_words.count}] : [已匹配字母数量#{@matched_chars_count}] #{c1}: #{result}"
      puts @matched_words.inspect if ENV['DEBUG']
    end

    # 察看是否完全匹配
    _w = (@w1_length > @matched_chars_count) ? "没有找到" : guessing_word

    puts "猜测 次数:#{@guessed_time} 单词:#{_w} 单词长度:#{_w.length} 顺序:#{@guessed_chars}"
    puts
    raise "猜测次数 不可能少于 单词含有的唯一字母个数" if @guessed_time < _w.chars.to_a.uniq.length
    return @guessed_time
  end
end

# TODO http://www.datagenetics.com/blog/april12012/index.html#result
