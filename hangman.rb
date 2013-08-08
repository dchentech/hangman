# encoding: UTF-8

# `curl -k -X POST -d 'name=hello1' --user your@email.com:password https://api.bitbucket.org/1.0/repositories -v`
# `curl -X POST -H "Content-Type: application/json" -d '{"username":"xyz","password":"xyz"}' http://localhost:3000/api/login`

# 需求
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

# 核心思想是贪婪算法，每次排除掉尽可能多的单词，让猜测步骤尽可能少。
#
# 复杂度估计
# a. 最笨的次数是猜20次以上，也就是枚举所有字母了。
# b. 最少是该单词唯一字母的个数，所以一般来说底线是单词长度。
#
# 步骤
# 1
# 第一个猜的字母用统计数据的词频，返回可能部分被*掩盖的单词，
# 1.1 如果是A或I，判断就终止了;
# 1.2 如果全是*，继续字母频度的下一个;
# 1.3 如果不全是*，那么进入第二步
# 2
# 在第一步里我们知道了单词的长度，
# 那么第二个猜的字母根据刚才含有位置信息的字母去找到字典索引找到全部匹配的单词列表，
# 并统计其中字母频度，并按该结果取出第二个字母（第一个我们刚才用掉了嘛），
# 并一直直到确认第二个字母匹配。
# 2.1 如果这个单词只有两个字母，那么到这里就结束了,
# 2.2
# 如果是两个以上字母，那么剩余的字母频度就从这个过滤好的单词列表里继续抽取了，
# 如此反复，直到最终找到那个单词为止。
#
# Ruby程序优化原则
# 1. 使用Symbol节省内存
# 2. 使用Hash O(1) 查找
#
# 猜词策略，元音和辅音间隔猜。
#
#
# 作为一个程序员，我先是选择算法和其他现成做法
# https://github.com/spydez/hangman hanman solver program for job interview
# http://blade.nagaokaut.ac.jp/cgi-bin/scat.rb/ruby/ruby-talk/258405
# http://www.learnstreet.com/cg/simple/project/hangman-ruby
# http://www.datagenetics.com/blog/april12012/index.html 统计学意义上
# http://en.wikipedia.org/wiki/Hangman_(game)
# http://zh.wikipedia.org/wiki/字母频率
# https://github.com/fredley/pyngman/blob/master/pyngman.py


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

VowelList = %w[A E I O]
ConsonantList = ('A'..'Z').to_a - VowelList + %w[U]

# 获取单词列表
# http://nifty.stanford.edu/2011/schwarz-evil-hangman/dictionary.txt
words = (File.read("/Users/mvj3/github/joycehan/strikingly-interview-test-instructions/data/words.txt").split("\n") + %w[a i]).map(&:upcase)
# TODO 复词等类型, activesupport


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

module Enumerable
  def frequencies
    group_by {|c| c }.map {|c, cs| [c, cs.length] }
  end
end

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

# 如果前一个是元音，那么下一个就是辅音，如果没找到，继续辅音，
# 知道找到，才切换下一个为元音。
# 辅音同理。
def select_next_vowel_or_consonant
  # require 'pry-debugger';binding.pry
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

  # 第一步: 找出第一个匹配的字母及其一或多个位置
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
    puts "@w1_length:#{@w1_length}, c1:#{c1}"
  end

  _w = @char_with_idx_array.sort_by {|c3| c3.to_s[1..-1].to_i }.map {|c3| c3[0] }.join
  puts "猜测 次数:#{@guessed_time} 单词:#{_w} 单词长度:#{_w.length} 顺序:#{@guessed_chars}"
  puts
  raise "猜测次数 不可能少于 单词含有的唯一字母个数" if @guessed_time < _w.chars.to_a.uniq.length
  return @guessed_time
end

ws1 = %w[COMAKER CUMULATE ERUPTIVE FACTUAL MONADISM MUS NAGGING OSES REMEMBERED SPODUMENES STEREOISOMERS TOXICS TRICHROMATS TRIOSE UNIFORMED]
ws2 = %w[affability kinglinesses papeteries bro ironer kyboshed hoodie settlors stonefish feloniousnesses butyrophenone ensile impartment penalty belatednesses overchilled veery ridglings globe amortised matzohs nonelective jacqueries narratological cacophonous catheterization outdared harpsichordist guttered dekes salutations iterate hegumen transshapes spearmints committals text connecting inkjet minestrones waveform pyrophyllites bullrings unbridling asphyxies partyers judgmatically shirtsleeve ascetically dirl enlightening douma pinkoes sightlessness moulding swingby waveshape intercessional tusses field yeshiva explorational rigour fictivenesses gusto ahoy schmelze whooshed yellower athetoid ordeal monoxide peacockish deadbeat anecdote uncoalesced hackmatack offishness almsgivings effervescence gravel renovative desertifications bamming toepieces gluttonously crams overmedicates commonsense birthdates desorbed psst retrogradation sphygmomanometer barouche unharness correlational martyrologies winglet heptarch spectroscopies oversensitivities immunofluorescence totalities thimbleberry penates slipup oughted oedema preening meropic redialing hyperparathyroidisms flicked buttocks readout whitewashes arioso appeasements preventers snarkier pratfalls surbased excogitative idolators disaccharides rebuy establisher embays extorting apocalyptist emetics microdissection misalters mortalities fuglemen symposiums host prelims sizeable titivated agrarianisms microinjected strobes soymilks scrawnier tapir blowouts overdrink counterviolences cranky bombyx neurophysiology uprightness clownishly guitarfish rump hardset quietened cockiness roquelaures osmoregulatory rune dotardly medallion advertized labored lineality springers counterespionages substratum gauffered summered inevitably dewy outweighing antistrophe denunciative chimbley speculums perniciousnesses tenacities outmaneuvering gimped yardwands hospices electrodesiccations palliates weighmen decentre plasterings smirk exuberating sedulity mild becrawl relit stumble rugose resistants professedly flemishing bibelot pinpricking songwriter hath whists condemners bonnyclabber acreages sanitary hindrances reanimates takeouts coccidiosis lensing norite punkies overstaying aureolae lobsticks cheekinesses outscored judges wops inhumanities defoliations mysticly communicators bagging agapeic intubates afterlife forwards resultant straightjacketing arsenopyrites skirt codiscovering microphyll vicunas radishes tintinnabulations fodders solidaristic dizzily transferrable cookings subdepot antiparasitics synthesist controverted grison rescinders possessive substitutive nucleonics scientific misphrasing serviceberry shipwrecks ferbam ionospheric waitstaff dynamometries ascendant zeroth neuropathologic refocussed craniosacral contractually corrupts poilu openheartedness butterflyers goldfinch wordage provoking deism idolism cunningness greys lithoid thenceforwards darkling woefulness electrolyte cheongsam hypercorrectnesses relets rehems arabic coppered safflower sprats bloodstream elegizing reiving yirred beachcombers derogate arcing honeycombing incensed remorsefulnesses internationalize moles peristaltic reexpresses orthographical allseed heathendoms recruitment talkativenesses hydroplane rouletting dormins purpuras policyholders arbitrable militiaman veinlike nargile pile snuffles fondles laciness filling nonregulated animal vilifiers gerrymandering gentrice rescript lodgments acaudal pointman whaleman genome glassworkers seggar deliriums sibilations hallows euxenites speedwell soling tying promontories gulpy loopiest mailes inbreeding wry fets detoxicants infestation planetaria trindle sonneteerings caid quadrivium avulses washrooms keeper step occipita scheming swale obsessives endeavoring thoroughgoing rotator skimmed methylations bluster atavism birses costermonger emplacing mantas uncock backtracks soil blanch lateens oxidising deface gharials wheeziest sodium subalpine fardels triethyl surceases mantelshelf pedologies chuckled peneplane perry stomachy damped desmosomes curiae flannelettes arisen snowberries saltant filariases lealties abetted doubtful aventails hydrobiology coordinators unlawfulness dethroning septuagenarian subcapsular ta dovishness atemoya spiraeas lycopods incident tsorriss stranding haustorium deerberry screamed podestas sibilances modiste limbing eupatrids mustiest angstrom palace syrphid lepidopterists toilsomenesses jettons conciser tambourine coached unconditional backrooms prototypically fetoscopy sedimentologic genes concessively limonites planless recombing gundog lobations slid eutaxy boodler intercalating photobiologic scorpions noospheres jactitations rhizoctonia exaltation unactorish surtaxing reaccredits valiantnesses cardamums egocentrics discerned bumptiousnesses fearers intersterile demeanours couteaux setback bioelectricities snooded logicising lolled andalusites phenolphthaleins muckraker dalliers noncolored grandsirs becrawls singling swellheads spiks bushidos necropsied pedlary resinifies hyoscines pronunciamentos cremating puttied calcareously bildungsromans readjustment outjump wispish lithified anodizes residuary pewters antimaterialists humerus inventorial antibaryon paleomagnetically gleeds trapesed quintuplicate cuttled feelingly unhair deifical bratwurst journalese teocallis restrooms teniae vexatious citrins eviction noncontemporary busloads onomatopoetic coassumed enframes nincompooperies sousaphones snoopily sociogram dangerous semisynthetic astrophysics phonemicists carabins upraise wrasse harks regretfulnesses semiwild maximization drachmas mountainously isinglasses ulamas purls arboured pregnabilities incomparability overweens groan assiduousness teawares theoretically accentuates spiracle methodises missives tenable warpower prepregs nonutility sambo puttyroot sufferances irreligious autumn outraised jinricksha harborages federalization reformulating pantisocratists hehs metages staccati demulcents overburned odometries smokeable simplenesses zymosan pharmacologists circuses canoness tictocking nucleoplasms profligate oilholes sermonizes drifty wetwares estranger kelsons colligated delocalize denervate grayish polyclonal shuddery tapestried pemphixes portrays ultravirile olivenites nitrating trochanteral indiscriminately kolkhozniks embellish defaces egging qat splats budgerigars whoopie nostalgic benignities endemically coifed redips semigroups vigintillion escalloping postconception swillers anorexies valencias frugivores cozens accouchement planters sprucier immediatenesses dissuasiveness uncharitableness haptens loafing cajoles floccus reshown driveled lapidary princeliest caporal collectivized analogue strangeness prosthodontists pyknics indexation otoliths heartaches weakhearted practised drying diamantes tacitly suttas zorils chillum camouflageable ruptured ventricose dwelt drooping rewrapped octavo jackasses misgrafted forks oarsman wooled keeks unfitnesses audiometries unhousing dermatologists superficiality hypermedias mugged harts sensualities nonclassical groundbreaker weakside scrupulously handwork holdup unavailingness redelivers albinotic reconsolidated buttock lexicality knapsack redefecting tweeted martial primipara mistook gegenscheins shivareeing talcum gestating electrodes whitewashes commutative unravelling logion bauhinias thermostated dados umbonic rhythmist egression restudies laypeople erasures unscrewing sirenian outpace oversuds teetotally asthenics parenteral overshot spale scoriaceous noters inventor pommeling fuehrer disintermediations resegregate mahuang prolocutors insectan machicolation casked leukodystrophy malposition cycled raveners paraphrases counterstrikes nertz stouter cavetti salterns rectification choreographic subaudible newie premodifications truckles wapitis tort showcases romancing thous burnous wore graphite pingoes xu uncrown famousnesses caudate beleaps malarial synonymized dropsy ingulfed alant nosologic usurper reimpression quandary recentrifuge overmixing plumbism insolations cleavable acclaims boosting succinctest bardolater veer sorbitol torched warrants benison willowlike propjet radiobiologies doable greenbug begirding effectualities smogless sockdologers hominesses soroses mizzens hospice tawsing smaragds retries orthopteroids bewilderedly retires zoogeographers dystonic fearlessness germ mycobacterium peacekeeper quantified troubleshooters interferometric nereids ineluctability wayfaring utilizable cyclized uxorious inhumanities tearier amiablenesses turbojet grouter etude adjutancy ribbon anilinguses fashionably latish umbrageousness paroled theorematic hexosans counterthreats learn short layman orphaned gypsophila crumbly boodling carling linear diageneses enemy cheerfulness prolonges frizzed platings diarchy sourdine rooflike mahoe disadvantages atheneum adulterous photodissociation provocatively slot celoms impetuous mitt bejeezus spindlier chiliastic postindependence prudishly summerwoods retear butled indirectnesses manslaughter flagrances bureaucratically overstaffed abattoirs playbooks bogged frized jacinthes cabbageworms becrust mestino inhabiter trochili rancidity outleap sodalities odorizes anticholinergics heptarchs haulms velarized undotted blousiest disestablishment uncaked termed citrated officialeses endbrains conglomerations epilogue destination bourgeoise ulcer hognoses jiggles pallidnesses screeches oriole anatomized homebrews immunoprecipitating spuriously blowfish batts lentigo adorers monetise trimming hypercritic superficialities astrological obstructor driftage scatter inflictions supermales finalities advocating racemic physiography rubeolas bendaying warmongerings inhibit silk autochthons knosp surreys correctors coordinative tailleurs gaen braininesses uneasinesses hydrophobicities orchestra araks scapegoats picoting rieslings horrified lamentedly hyponeas devolved adzes bedstead santo logogriphs reearning pandy spearmen hiking aspirational mosquito careen ruffianism sporocarps profound phalanx subgum curatorships scrimmaging encyclical fatheaded occultism coenamor metamorphisms rashes mus]

_guess_count = 0
ws = ws2
ws.each do |w|
  _guess_count += guess_word(1..13, w)
end
puts "*"*30
puts "GUESS_AVG:#{(_guess_count / ws.count).round(1)}, GUESS_TOTAL:#{_guess_count}. WORD_NUM:#{ws.count}, CHARS_COUNT_AVG:#{ws.map(&:length).reduce(:+) / ws.count}."
puts "*"*30

# 别人结果有: AVG: 7.782 NUM: 1000 TOTAL: 7782
# 2013-08-08 14:23
# GUESS_AVG:11.0, GUESS_TOTAL:11927. WORD_NUM:1001, CHARS_COUNT_AVG:9.
# 2013-08-08 14:33 去掉U之后
# GUESS_AVG:11.0, GUESS_TOTAL:11896. WORD_NUM:1001, CHARS_COUNT_AVG:9.

def gw word
  l = word.length
  guess_word l..l, word
end
__END__

%w[affability kinglinesses papeteries bro ironer kyboshed hoodie settlors stonefish feloniousnesses butyrophenone ensile impartment penalty belatednesses overchilled veery ridglings globe amortised matzohs nonelective jacqueries narratological cacophonous catheterization outdared harpsichordist guttered dekes salutations iterate hegumen transshapes spearmints committals text connecting inkjet minestrones waveform pyrophyllites bullrings unbridling asphyxies partyers judgmatically shirtsleeve ascetically dirl enlightening douma pinkoes sightlessness moulding swingby waveshape intercessional tusses field yeshiva explorational rigour fictivenesses gusto ahoy schmelze whooshed yellower athetoid ordeal monoxide peacockish deadbeat anecdote uncoalesced hackmatack offishness almsgivings effervescence gravel renovative desertifications bamming toepieces gluttonously crams overmedicates commonsense birthdates desorbed psst retrogradation sphygmomanometer barouche unharness correlational martyrologies winglet heptarch spectroscopies oversensitivities immunofluorescence totalities thimbleberry penates slipup oughted oedema preening meropic redialing hyperparathyroidisms flicked buttocks readout whitewashes arioso appeasements preventers snarkier pratfalls surbased excogitative idolators disaccharides rebuy establisher embays extorting apocalyptist emetics microdissection misalters mortalities fuglemen symposiums host prelims sizeable titivated agrarianisms microinjected strobes soymilks scrawnier tapir blowouts overdrink counterviolences cranky bombyx neurophysiology uprightness clownishly guitarfish rump hardset quietened cockiness roquelaures osmoregulatory rune dotardly medallion advertized labored lineality springers counterespionages substratum gauffered summered inevitably dewy outweighing antistrophe denunciative chimbley speculums perniciousnesses tenacities outmaneuvering gimped yardwands hospices electrodesiccations palliates weighmen decentre plasterings smirk exuberating sedulity mild becrawl relit stumble rugose resistants professedly flemishing bibelot pinpricking songwriter hath whists condemners bonnyclabber acreages sanitary hindrances reanimates takeouts coccidiosis lensing norite punkies overstaying aureolae lobsticks cheekinesses outscored judges wops inhumanities defoliations mysticly communicators bagging agapeic intubates afterlife forwards resultant straightjacketing arsenopyrites skirt codiscovering microphyll vicunas radishes tintinnabulations fodders solidaristic dizzily transferrable cookings subdepot antiparasitics synthesist controverted grison rescinders possessive substitutive nucleonics scientific misphrasing serviceberry shipwrecks ferbam ionospheric waitstaff dynamometries ascendant zeroth neuropathologic refocussed craniosacral contractually corrupts poilu openheartedness butterflyers goldfinch wordage provoking deism idolism cunningness greys lithoid thenceforwards darkling woefulness electrolyte cheongsam hypercorrectnesses relets rehems arabic coppered safflower sprats bloodstream elegizing reiving yirred beachcombers derogate arcing honeycombing incensed remorsefulnesses internationalize moles peristaltic reexpresses orthographical allseed heathendoms recruitment talkativenesses hydroplane rouletting dormins purpuras policyholders arbitrable militiaman veinlike nargile pile snuffles fondles laciness filling nonregulated animal vilifiers gerrymandering gentrice rescript lodgments acaudal pointman whaleman genome glassworkers seggar deliriums sibilations hallows euxenites speedwell soling tying promontories gulpy loopiest mailes inbreeding wry fets detoxicants infestation planetaria trindle sonneteerings caid quadrivium avulses washrooms keeper step occipita scheming swale obsessives endeavoring thoroughgoing rotator skimmed methylations bluster atavism birses costermonger emplacing mantas uncock backtracks soil blanch lateens oxidising deface gharials wheeziest sodium subalpine fardels triethyl surceases mantelshelf pedologies chuckled peneplane perry stomachy damped desmosomes curiae flannelettes arisen snowberries saltant filariases lealties abetted doubtful aventails hydrobiology coordinators unlawfulness dethroning septuagenarian subcapsular ta dovishness atemoya spiraeas lycopods incident tsorriss stranding haustorium deerberry screamed podestas sibilances modiste limbing eupatrids mustiest angstrom palace syrphid lepidopterists toilsomenesses jettons conciser tambourine coached unconditional backrooms prototypically fetoscopy sedimentologic genes concessively limonites planless recombing gundog lobations slid eutaxy boodler intercalating photobiologic scorpions noospheres jactitations rhizoctonia exaltation unactorish surtaxing reaccredits valiantnesses cardamums egocentrics discerned bumptiousnesses fearers intersterile demeanours couteaux setback bioelectricities snooded logicising lolled andalusites phenolphthaleins muckraker dalliers noncolored grandsirs becrawls singling swellheads spiks bushidos necropsied pedlary resinifies hyoscines pronunciamentos cremating puttied calcareously bildungsromans readjustment outjump wispish lithified anodizes residuary pewters antimaterialists humerus inventorial antibaryon paleomagnetically gleeds trapesed quintuplicate cuttled feelingly unhair deifical bratwurst journalese teocallis restrooms teniae vexatious citrins eviction noncontemporary busloads onomatopoetic coassumed enframes nincompooperies sousaphones snoopily sociogram dangerous semisynthetic astrophysics phonemicists carabins upraise wrasse harks regretfulnesses semiwild maximization drachmas mountainously isinglasses ulamas purls arboured pregnabilities incomparability overweens groan assiduousness teawares theoretically accentuates spiracle methodises missives tenable warpower prepregs nonutility sambo puttyroot sufferances irreligious autumn outraised jinricksha harborages federalization reformulating pantisocratists hehs metages staccati demulcents overburned odometries smokeable simplenesses zymosan pharmacologists circuses canoness tictocking nucleoplasms profligate oilholes sermonizes drifty wetwares estranger kelsons colligated delocalize denervate grayish polyclonal shuddery tapestried pemphixes portrays ultravirile olivenites nitrating trochanteral indiscriminately kolkhozniks embellish defaces egging qat splats budgerigars whoopie nostalgic benignities endemically coifed redips semigroups vigintillion escalloping postconception swillers anorexies valencias frugivores cozens accouchement planters sprucier immediatenesses dissuasiveness uncharitableness haptens loafing cajoles floccus reshown driveled lapidary princeliest caporal collectivized analogue strangeness prosthodontists pyknics indexation otoliths heartaches weakhearted practised drying diamantes tacitly suttas zorils chillum camouflageable ruptured ventricose dwelt drooping rewrapped octavo jackasses misgrafted forks oarsman wooled keeks unfitnesses audiometries unhousing dermatologists superficiality hypermedias mugged harts sensualities nonclassical groundbreaker weakside scrupulously handwork holdup unavailingness redelivers albinotic reconsolidated buttock lexicality knapsack redefecting tweeted martial primipara mistook gegenscheins shivareeing talcum gestating electrodes whitewashes commutative unravelling logion bauhinias thermostated dados umbonic rhythmist egression restudies laypeople erasures unscrewing sirenian outpace oversuds teetotally asthenics parenteral overshot spale scoriaceous noters inventor pommeling fuehrer disintermediations resegregate mahuang prolocutors insectan machicolation casked leukodystrophy malposition cycled raveners paraphrases counterstrikes nertz stouter cavetti salterns rectification choreographic subaudible newie premodifications truckles wapitis tort showcases romancing thous burnous wore graphite pingoes xu uncrown famousnesses caudate beleaps malarial synonymized dropsy ingulfed alant nosologic usurper reimpression quandary recentrifuge overmixing plumbism insolations cleavable acclaims boosting succinctest bardolater veer sorbitol torched warrants benison willowlike propjet radiobiologies doable greenbug begirding effectualities smogless sockdologers hominesses soroses mizzens hospice tawsing smaragds retries orthopteroids bewilderedly retires zoogeographers dystonic fearlessness germ mycobacterium peacekeeper quantified troubleshooters interferometric nereids ineluctability wayfaring utilizable cyclized uxorious inhumanities tearier amiablenesses turbojet grouter etude adjutancy ribbon anilinguses fashionably latish umbrageousness paroled theorematic hexosans counterthreats learn short layman orphaned gypsophila crumbly boodling carling linear diageneses enemy cheerfulness prolonges frizzed platings diarchy sourdine rooflike mahoe disadvantages atheneum adulterous photodissociation provocatively slot celoms impetuous mitt bejeezus spindlier chiliastic postindependence prudishly summerwoods retear butled indirectnesses manslaughter flagrances bureaucratically overstaffed abattoirs playbooks bogged frized jacinthes cabbageworms becrust mestino inhabiter trochili rancidity outleap sodalities odorizes anticholinergics heptarchs haulms velarized undotted blousiest disestablishment uncaked termed citrated officialeses endbrains conglomerations epilogue destination bourgeoise ulcer hognoses jiggles pallidnesses screeches oriole anatomized homebrews immunoprecipitating spuriously blowfish batts lentigo adorers monetise trimming hypercritic superficialities astrological obstructor driftage scatter inflictions supermales finalities advocating racemic physiography rubeolas bendaying warmongerings inhibit silk autochthons knosp surreys correctors coordinative tailleurs gaen braininesses uneasinesses hydrophobicities orchestra araks scapegoats picoting rieslings horrified lamentedly hyponeas devolved adzes bedstead santo logogriphs reearning pandy spearmen hiking aspirational mosquito careen ruffianism sporocarps profound phalanx subgum curatorships scrimmaging encyclical fatheaded occultism coenamor metamorphisms rashes mus].map {|w| gw w }

# 开始猜测单词
[1..5, 1..8, 1..12, 12..20].each do |range|
  frequent_characters_hash = Hash[range.map {|num| PopularityOfLettersInLength[num] }.flatten.group_by {|c| c }.map {|c, cs| [c, cs.length] }]

  20.times do |idx|
  end
end if nil
