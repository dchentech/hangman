Hangman
===============================
In its purest form, hangman is a word game played between two people. One person selects a secret word, and the other tries to determine the word by guessing it letter-by-letter.

Requirement
-------------------------------
Types of Words
Plural
Tenses
Adjectives
Difficulty of Words
Among the 80 words to guess, there will be in different lengths
1st to 20th word : length <= 5 characters
21st to 40th word : length <= 8 characters
41st to 60th word : length <= 12 characters
61st to 80th word : length > 12 characters

核心思想
-------------------------------
贪婪算法，每次排除掉尽可能多的单词，让猜测步骤尽可能少。

[?]用字母位置信息 解决统计的字母非关联缺陷
http://www.datagenetics.com/blog/april12012/index.html
Let me give an example: If we have a six letter word, our first letter to guess should be 'E'. If the letter 'E' is not in the solution, we should not necessarily try the letter 'S' next (which is what the above table implies)!

复杂度估计
-------------------------------
a. 最笨的次数是猜20次以上，也就是枚举所有字母了。
b. 最少是该单词唯一字母的个数，所以一般来说底线是单词长度。

步骤
-------------------------------
1
第一个猜的字母用统计数据的词频，返回可能部分被*掩盖的单词，
1.1 如果是A或I，判断就终止了;
1.2 如果全是*，继续字母频度的下一个;
1.3 如果不全是*，那么进入第二步
2
在第一步里我们知道了单词的长度，
那么第二个猜的字母根据刚才含有位置信息的字母去找到字典索引找到全部匹配的单词列表，
并统计其中字母频度，并按该结果取出第二个字母（第一个我们刚才用掉了嘛），
并一直直到确认第二个字母匹配。
2.1 如果这个单词只有两个字母，那么到这里就结束了,
2.2
如果是两个以上字母，那么剩余的字母频度就从这个过滤好的单词列表里继续抽取了，
如此反复，直到最终找到那个单词为止。

Ruby程序优化原则
-------------------------------
1. 使用Symbol节省内存
2. 使用Hash O(1) 查找


问题
-------------------------------
a. 猜词策略，元音和辅音间隔猜。
b. 一般不能超过十次，现在平均是十二次
c. 贝叶斯bayes?但是位置信息已经是最大概率。


作为一个程序员，我先是选择算法和其他现成做法
https://github.com/spydez/hangman hanman solver program for job interview
http://blade.nagaokaut.ac.jp/cgi-bin/scat.rb/ruby/ruby-talk/258405
http://www.learnstreet.com/cg/simple/project/hangman-ruby
http://en.wikipedia.org/wiki/Hangman_(game)
http://zh.wikipedia.org/wiki/字母频率
https://github.com/fredley/pyngman/blob/master/pyngman.py
https://docs.google.com/document/d/18s9i0SKThDasIAb3WgTxxSkz2QEjAT9sVyJFQXMpB1I/edit 七种武器：从一个算法的多语言实现看编程语言的横向对比
http://stackoverflow.com/questions/16223305/algorithm-for-classifying-words-for-hangman-difficulty-levels-as-easy-medium
https://github.com/freizl/play-hangman-game/


