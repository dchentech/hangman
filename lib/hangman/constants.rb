# encoding: UTF-8

class Hangman
  # popularity of letters in dictionary words grouped by the length of those words
  # copied from http://www.datagenetics.com/blog/april12012/index.html 统计学意义上
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
  Words = (File.read(File.expand_path('../../../data/words.txt', __FILE__)).split("\n") + %w[a i]).map(&:upcase)

  # 建立有位置信息的字母 映射到 单词 的哈希表
  # {len => { :char_pos => words } }
  #
  # TODO 其他数据结构，但这个只能提高查找效率，不能减少猜字母的次数。
  # {:len_char_pos => words }
  # {:len => {char => { pos => words } } }
  _h = Hash.new { 0 }
  Length_to__char_num_to_words__hash = Words.inject({}) do |h, w|
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
end
