# encoding: UTF-8

require File.expand_path('../test_helper.rb', __FILE__)

ws2 = File.read(File.expand_path('../../data/1000words.txt', __FILE__)).split

ws1 = %w[COMAKER CUMULATE ERUPTIVE FACTUAL MONADISM MUS NAGGING OSES REMEMBERED SPODUMENES STEREOISOMERS TOXICS TRICHROMATS TRIOSE UNIFORMED]

if true
_guess_counts_array = []
ws = ws2 #.shuffle[0..79]
ws = ws2.select {|w| w.length < 6 }
ws = ws2.select {|w| w.length == 10 }
ws.each do |w|
  _guess_counts_array << guess_word(1..13, w)
end
_guess_total_count = _guess_counts_array.reduce(:+)
puts "*"*30
puts "GUESS_AVG:#{(_guess_total_count / ws.count).round(1)}, GUESS_TOTAL:#{_guess_total_count}, GUESS_COUNT_MEDIAN:#{_guess_counts_array.median}"
puts "WORD_NUM:#{ws.count}, CHARS_COUNT_AVG:#{ws.map(&:length).reduce(:+) / ws.count}, CHARS_COUNT_MEDIAN:#{ws.map(&:length).median}"
puts "*"*30
end

# 别人结果有: AVG: 7.782 NUM: 1000 TOTAL: 7782。不过可疑的是 OUTRANKS = 6，猜测次数少于唯一字母数。
# [2013-08-08 14:23]
#   GUESS_AVG:11.0, GUESS_TOTAL:11927. WORD_NUM:1001, CHARS_COUNT_AVG:9.
# [2013-08-08 14:33] 去掉U之后
#   GUESS_AVG:11.0, GUESS_TOTAL:11896. WORD_NUM:1001, CHARS_COUNT_AVG:9.
# [2013-08-08 15:29] 加上中位数。AVG小于MEDIAN，说明经过一定优化了。
#   GUESS_AVG:11.0, GUESS_TOTAL:11896, GUESS_COUNT_MEDIAN:12.0
#   WORD_NUM:1001, CHARS_COUNT_AVG:9, CHARS_COUNT_MEDIAN:9.0
# [2013-08-08 15:40] 随机抽80个
#   GUESS_AVG:12.0, GUESS_TOTAL:975, GUESS_COUNT_MEDIAN:12.0
#   WORD_NUM:80, CHARS_COUNT_AVG:9, CHARS_COUNT_MEDIAN:9.0
# [2013-08-08 15:42] 随机抽80个
#   GUESS_AVG:12.0, GUESS_TOTAL:963, GUESS_COUNT_MEDIAN:12.0
#   WORD_NUM:80, CHARS_COUNT_AVG:8, CHARS_COUNT_MEDIAN:8.0
# [2013-08-08 15:43] 随机抽80个
#   GUESS_AVG:12.0, GUESS_TOTAL:984, GUESS_COUNT_MEDIAN:12.0
#   WORD_NUM:80, CHARS_COUNT_AVG:8, CHARS_COUNT_MEDIAN:8.0
# [2013-08-08 16:35] 单词长度等于10
#   GUESS_AVG:11.0, GUESS_TOTAL:1366, GUESS_COUNT_MEDIAN:11.0
#   WORD_NUM:119, CHARS_COUNT_AVG:10, CHARS_COUNT_MEDIAN:10.0



