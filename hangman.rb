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

# 核心思想是贪婪算法，让猜测步骤尽可能少。
# 1
# 第一个猜的字母用统计数据的词频，返回可能部分被*掩盖的单词，
# 1.1 如果是A或I，判断就终止了;
# 2.2 如果全是*，继续字母频度的下一个;
# 2.3 如果不全是*，那么进入第二步
# 第二个猜的字母根据刚才含有位置信息的字母去找到字典索引找到全部匹配的单词列表，
# 并统计其中字母频度，并按该结果取出第二个字母（第一个我们刚才用掉了嘛），
# 并一直直到确认第二个字母匹配。
# 2.1 如果这个单词只有两个字母，那么到这里就结束了,
# 2.2
# 如果是两个以上字母，那么剩余的字母频度就从这个过滤好的单词列表里继续抽取了，
# 如此反复，直到最终找到那个单词为止。


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
# {len => { :char_pos => words } }
#
# TODO 其他数据结构，但这个只能提高查找效率，不能减少猜字母的次数。
# {:len_char_pos => words }
# {:len => {char => { pos => words } } }
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

# return "**N***N"
def match_result w, c
  w.chars.map {|c1| (c == c1) ? c : '*' }.join
end

# return [:n2, :n6]
def matched_char_with_idx_in_str _result
  _a = []
  _result.chars.each_with_index do |c1, idx|
    _a << "#{c1}#{idx}".to_sym if c1 != '*'
  end
  _a
end

def 

def guess_word range, w1
  w1.upcase!
  w1_length = w1.length
  matched_chars_count = 0
  guess_time = 0
  result = nil
  char_with_idx_array = []
  guessed_chars = []
  next_guess_chars = nil

  # 找出第一个匹配的字母及其一或多个位置
  PopularityOfLettersInLength[w1_length].each do |c1|
    guess_time += 1
    guessed_chars << c1
    result = match_result(w1, c1)
    puts "#{c1}: #{result}"
    matched_chars_count += (w1_length - result.count('*'))
    if matched_chars_count > 0
      char_with_idx_array += matched_char_with_idx_in_str(result)
      break
    end
  end

  # 退出，比如只有一两个字母
  return guess_time if char_with_idx_array.length == w1_length

  # 依据上面匹配字母及其位置找到所有符合单词，
  # 并求出接下来的字母及其位置
  matched_words_array = _char_with_idx_array.map do |_char_with_idx|
    Length_to__char_num_to_words__hash[_word_length][_char_with_idx]
  end
  if matched_words_array.size.zero?
    puts "no matched word" 
    return guess_time
  end
  matched_words = nil
  matched_words_array.each do |_a1|
    if matched_words.nil? # init data
      matched_words = _a1
    else
      matched_words = matched_words & _a1
    end
  end
  next_guess_chars = matched_words.map {|_w1| _w1.to_s.chars }.flatten.frequencies.map(&:first)
  next_guess_chars = next_guess_chars - guessed_chars

  # 当找到一个匹配后，就重新选择下一个最大机会匹配字母
  while (matched_chars_count != w1_length) do
    next_guess_chars.each do |c1|
      guess_time += 1
      result = match_result w1, c1
      puts "#{c1}: #{result}"
      _count = (w1_length - result.count('*'))
      matched_chars_count += _count
      guessed_chars << c1
      break if _count > 0
    end
  end

  puts guess_time
  return guess_time
end
# TODO puts matched length words count in each step

%w[COMAKER CUMULATE ERUPTIVE FACTUAL MONADISM MUS NAGGING OSES REMEMBERED SPODUMENES STEREOISOMERS TOXICS TRICHROMATS TRIOSE UNIFORMED].each do |w|
  guess_word 1..13, w
end


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