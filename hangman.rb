# encoding: UTF-8

# NO try 'e' first
# `curl -k -X POST -d 'name=hello1' --user your@email.com:password https://api.bitbucket.org/1.0/repositories -v`
# `curl -X POST -H "Content-Type: application/json" -d '{"username":"xyz","password":"xyz"}' http://localhost:3000/api/login`



# https://github.com/spydez/hangman hanman solver program for job interview
# http://blade.nagaokaut.ac.jp/cgi-bin/scat.rb/ruby/ruby-talk/258405
# http://www.learnstreet.com/cg/simple/project/hangman-ruby
# http://www.datagenetics.com/blog/april12012/index.html 统计学意义上
# https://github.com/fredley/pyngman/blob/master/pyngman.py



# 1. 作为一个程序员，我先是选择算法和其他现成做法
# 2. 
#
# in C

# 1. 使用Symbol节省内存
# 2. 优化原则是计算字母可能性

# a. 依次试(most frequent character in the range) => match words with length
# b. select match words in the same length, 
# c. 选出里面最常见的字母, 依次试

=begin
Types of Words
Plural
Tenses
Adjectives
Difficulty of Words
Among the 80 words to guess, there will be in different lengths # 使用这里的表格
1st to 20th word : length <= 5 characters
21st to 40th word : length <= 8 characters
41st to 60th word : length <= 12 characters
61st to 80th word : length > 12 characters
=end



# popularity of letters in dictionary words grouped by the length of those words
PopularityOfLettersData = <<-EOF
1  2  3	4	5	6	7	8	9	10	11	12	13	14	15	16	17	18	19	20
#1	A	A	A	A	S	E	E	E	E	E	E	E	I	I	I	I	I	I	I	I
#2	I	O	E	E	E	S	S	S	S	I	I	I	E	E	E	E	E	S	E	O
#3	.	E	O	S	A	A	I	I	I	S	S	S	N	T	T	T	T	E	T	E
#4	.	I	I	O	R	R	A	A	R	R	N	N	T	S	N	S	N	T	O	T
#5	.	M	T	I	O	I	R	R	A	A	A	T	S	N	S	N	S	O	N	R
#6	.	H	S	R	I	O	N	N	N	N	R	A	A	A	O	A	O	N	A	S
#7	.	N	U	L	L	L	T	T	T	T	T	R	O	O	A	O	A	R	S	A
#8	.	U	P	T	T	N	O	O	O	O	O	O	R	R	R	R	R	A	R	N
#9	.	S	R	N	N	T	L	L	L	L	L	L	L	L	L	L	L	L	L	C
#10	.	T	N	U	U	D	D	D	C	C	C	C	C	C	C	C	C	C	C	L
#11	.	Y	D	D	D	U	U	C	D	D	U	P	P	P	P	P	P	P	P	P
#12	.	B	B	P	C	C	C	U	U	U	D	U	U	U	U	U	U	M	M	H
#13	.	L	G	M	Y	M	G	G	G	G	P	M	M	M	M	M	M	U	U	U
#14	.	P	M	H	P	P	P	M	M	M	M	D	G	D	D	H	H	H	H	M
#15	.	X	Y	C	M	G	M	P	P	P	G	G	D	H	H	D	D	D	D	Y
#16	.	D	L	B	H	H	H	H	H	H	H	H	H	G	G	Y	G	G	G	D
#17	.	F	H	K	G	B	B	B	B	B	B	Y	Y	Y	Y	G	Y	Y	Y	G
#18	.	R	W	G	B	Y	Y	Y	Y	Y	Y	B	B	B	B	B	B	B	B	B
#19	.	W	F	Y	K	K	F	F	F	F	F	V	V	V	V	V	V	V	V	Z
#20	.	G	C	W	F	F	K	K	V	V	V	F	F	F	F	F	F	Z	F	V
#21	.	J	K	F	W	W	W	W	K	K	K	Z	Z	Z	Z	Z	Z	F	Z	F
#22	.	K	X	V	V	V	V	V	W	W	W	K	X	X	X	X	X	X	X	K
#23	.	.	V	J	Z	Z	Z	Z	Z	Z	Z	W	K	K	W	W	Q	Q	K	X
#24	.	.	J	Z	X	X	X	X	X	X	X	X	W	W	K	Q	W	W	J	J
#25	.	.	Z	X	J	J	J	Q	Q	Q	Q	Q	Q	Q	Q	K	J	K	Q	Q
#26	.	.	Q	Q	Q	Q	Q	J	J	J	J	J	J	J	J	J	K	.	W	.
EOF

# 构造 {length => [character, ]}
data_lines = PopularityOfLettersData.split("\n").map(&:chomp).map(&:split)
PopularityOfLettersInLength = data_lines[0].inject({}) do |h, idx|
  idx = idx.to_i
  h[idx] = data_lines[1..-1].map {|a| a[idx] }.reject {|i| i == '.' }
  h
end

# 获取单词列表
# http://nifty.stanford.edu/2011/schwarz-evil-hangman/dictionary.txt
words = (File.read("/Users/mvj3/github/joycehan/strikingly-interview-test-instructions/data/words.txt").split("\n") + %w[a i]).map(&:upcase)

# 建立有位置信息的字母 映射到 单词 的哈希表
# 比如 { :o1 => [:word, :wood] }
Length_to__char_num_to_words__hash = words.inject({}) do |h, w|
  h[w.length] ||= {}
  w.chars.each_with_index do |c, c_idx|
    _sym = "#{c}#{c_idx}".to_sym
    h[w.length][_sym] ||= []
    h[w.length][_sym] << w.to_sym
  end
  h
end

Length_to__char_num_to_words__hash.keys

class Enumerator
  def frequencies
    group_by {|c| c }.map {|c, cs| [c, cs.length] }
  end
end

def select_first_guess_character_in_range range
  (Hash[range.map {|num| PopularityOfLettersInLength[num] }.flatten.frequencies].first || {})[0]
end

def match_result w, c
  w.chars.map {|c1| (c == c1) ? c : '*' }.join
end

# 依据上面匹配字母及其位置找到所有符合单词，
# 并求出接下来的字母及其位置
def char_with_idx__to__rest _char_with_idx_array, _word_length, _guessed_chars
  _rest_matched_chars_order_by_count = _char_with_idx_array.map do |_char_with_idx|
    Length_to__char_num_to_words__hash[_word_length][_char_with_idx]
  end.flatten.uniq.map(&:to_s).join.chars.frequencies.map(&:first)
  _rest_matched_chars_order_by_count -= _guessed_chars
end

def matched_char_with_idx_in_str _result
  _a = []
  _result.chars.each_with_index do |c1, idx|
    _a << "#{c1}#{idx}".to_sym if c1 != '*'
  end
  _a
end

def guess_word range, w1
  w1.upcase!
  w1_length = w1.length
  match_count = 0
  guess_time = 0
  result = nil
  char_with_idx_array = []
  guessed_chars = []

  # 找出第一个匹配的字母及其一或多个位置
  PopularityOfLettersInLength[w1_length].each do |c1|
    guess_time += 1
    guessed_chars << c1
    result = match_result(w1, c1)
    puts "#{c1}: #{result}"
    match_count += (w1_length - result.count('*'))
    if match_count > 0
      char_with_idx_array += matched_char_with_idx_in_str(result)
      break
    end
  end

  # 退出，比如只有一两个字母
  return guess_time if char_with_idx_array.length == w1_length

  # 当找到一个匹配后，就重新选择下一个最大机会匹配字母
  while (match_count != w1_length) do
    char_with_idx__to__rest(char_with_idx_array, w1_length, guessed_chars).each do |c1|
      guess_time += 1
      result = match_result w1, c1
      puts "#{c1}: #{result}"
      _count = (w1_length - result.count('*'))
      match_count += _count
      char_with_idx_array += matched_char_with_idx_in_str(result)
      guessed_chars << c1
      break if _count > 0
    end
  end

  puts guess_time
  guess_time
end

guess_word 1..8, "COMAKER"


# 开始猜测单词
[1..5, 1..8, 1..12, 12..20].each do |range|
  frequent_characters_hash = Hash[range.map {|num| PopularityOfLettersInLength[num] }.flatten.group_by {|c| c }.map {|c, cs| [c, cs.length] }]

  20.times do |idx|
  end
end if nil

__END__
irb(main):497:0> guess_word 1..8, "COMAKER"
***A***
*******
*******
*******
*******
*O*****
**M****
*******
*******
C******
*******
******R
*******
*******
*******
*******
*******
*******
*******
*******
*******
*******
*******
****K**
=> 25