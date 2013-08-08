# encoding: UTF-8

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
words = (File.read("/Users/mvj3/github/joycehan/strikingly-interview-test-instructions/data/words.txt").split("\n") + %w[a i]).map(&:upcase)

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

class Array
  def median
    sorted = self.sort
    len = sorted.length
    return ((sorted[(len - 1) / 2] + sorted[len / 2]) / 2.0).round(1)
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

ws1 = %w[COMAKER CUMULATE ERUPTIVE FACTUAL MONADISM MUS NAGGING OSES REMEMBERED SPODUMENES STEREOISOMERS TOXICS TRICHROMATS TRIOSE UNIFORMED]
ws2 = %w[affability kinglinesses papeteries bro ironer kyboshed hoodie settlors stonefish feloniousnesses butyrophenone ensile impartment penalty belatednesses overchilled veery ridglings globe amortised matzohs nonelective jacqueries narratological cacophonous catheterization outdared harpsichordist guttered dekes salutations iterate hegumen transshapes spearmints committals text connecting inkjet minestrones waveform pyrophyllites bullrings unbridling asphyxies partyers judgmatically shirtsleeve ascetically dirl enlightening douma pinkoes sightlessness moulding swingby waveshape intercessional tusses field yeshiva explorational rigour fictivenesses gusto ahoy schmelze whooshed yellower athetoid ordeal monoxide peacockish deadbeat anecdote uncoalesced hackmatack offishness almsgivings effervescence gravel renovative desertifications bamming toepieces gluttonously crams overmedicates commonsense birthdates desorbed psst retrogradation sphygmomanometer barouche unharness correlational martyrologies winglet heptarch spectroscopies oversensitivities immunofluorescence totalities thimbleberry penates slipup oughted oedema preening meropic redialing hyperparathyroidisms flicked buttocks readout whitewashes arioso appeasements preventers snarkier pratfalls surbased excogitative idolators disaccharides rebuy establisher embays extorting apocalyptist emetics microdissection misalters mortalities fuglemen symposiums host prelims sizeable titivated agrarianisms microinjected strobes soymilks scrawnier tapir blowouts overdrink counterviolences cranky bombyx neurophysiology uprightness clownishly guitarfish rump hardset quietened cockiness roquelaures osmoregulatory rune dotardly medallion advertized labored lineality springers counterespionages substratum gauffered summered inevitably dewy outweighing antistrophe denunciative chimbley speculums perniciousnesses tenacities outmaneuvering gimped yardwands hospices electrodesiccations palliates weighmen decentre plasterings smirk exuberating sedulity mild becrawl relit stumble rugose resistants professedly flemishing bibelot pinpricking songwriter hath whists condemners bonnyclabber acreages sanitary hindrances reanimates takeouts coccidiosis lensing norite punkies overstaying aureolae lobsticks cheekinesses outscored judges wops inhumanities defoliations mysticly communicators bagging agapeic intubates afterlife forwards resultant straightjacketing arsenopyrites skirt codiscovering microphyll vicunas radishes tintinnabulations fodders solidaristic dizzily transferrable cookings subdepot antiparasitics synthesist controverted grison rescinders possessive substitutive nucleonics scientific misphrasing serviceberry shipwrecks ferbam ionospheric waitstaff dynamometries ascendant zeroth neuropathologic refocussed craniosacral contractually corrupts poilu openheartedness butterflyers goldfinch wordage provoking deism idolism cunningness greys lithoid thenceforwards darkling woefulness electrolyte cheongsam hypercorrectnesses relets rehems arabic coppered safflower sprats bloodstream elegizing reiving yirred beachcombers derogate arcing honeycombing incensed remorsefulnesses internationalize moles peristaltic reexpresses orthographical allseed heathendoms recruitment talkativenesses hydroplane rouletting dormins purpuras policyholders arbitrable militiaman veinlike nargile pile snuffles fondles laciness filling nonregulated animal vilifiers gerrymandering gentrice rescript lodgments acaudal pointman whaleman genome glassworkers seggar deliriums sibilations hallows euxenites speedwell soling tying promontories gulpy loopiest mailes inbreeding wry fets detoxicants infestation planetaria trindle sonneteerings caid quadrivium avulses washrooms keeper step occipita scheming swale obsessives endeavoring thoroughgoing rotator skimmed methylations bluster atavism birses costermonger emplacing mantas uncock backtracks soil blanch lateens oxidising deface gharials wheeziest sodium subalpine fardels triethyl surceases mantelshelf pedologies chuckled peneplane perry stomachy damped desmosomes curiae flannelettes arisen snowberries saltant filariases lealties abetted doubtful aventails hydrobiology coordinators unlawfulness dethroning septuagenarian subcapsular ta dovishness atemoya spiraeas lycopods incident tsorriss stranding haustorium deerberry screamed podestas sibilances modiste limbing eupatrids mustiest angstrom palace syrphid lepidopterists toilsomenesses jettons conciser tambourine coached unconditional backrooms prototypically fetoscopy sedimentologic genes concessively limonites planless recombing gundog lobations slid eutaxy boodler intercalating photobiologic scorpions noospheres jactitations rhizoctonia exaltation unactorish surtaxing reaccredits valiantnesses cardamums egocentrics discerned bumptiousnesses fearers intersterile demeanours couteaux setback bioelectricities snooded logicising lolled andalusites phenolphthaleins muckraker dalliers noncolored grandsirs becrawls singling swellheads spiks bushidos necropsied pedlary resinifies hyoscines pronunciamentos cremating puttied calcareously bildungsromans readjustment outjump wispish lithified anodizes residuary pewters antimaterialists humerus inventorial antibaryon paleomagnetically gleeds trapesed quintuplicate cuttled feelingly unhair deifical bratwurst journalese teocallis restrooms teniae vexatious citrins eviction noncontemporary busloads onomatopoetic coassumed enframes nincompooperies sousaphones snoopily sociogram dangerous semisynthetic astrophysics phonemicists carabins upraise wrasse harks regretfulnesses semiwild maximization drachmas mountainously isinglasses ulamas purls arboured pregnabilities incomparability overweens groan assiduousness teawares theoretically accentuates spiracle methodises missives tenable warpower prepregs nonutility sambo puttyroot sufferances irreligious autumn outraised jinricksha harborages federalization reformulating pantisocratists hehs metages staccati demulcents overburned odometries smokeable simplenesses zymosan pharmacologists circuses canoness tictocking nucleoplasms profligate oilholes sermonizes drifty wetwares estranger kelsons colligated delocalize denervate grayish polyclonal shuddery tapestried pemphixes portrays ultravirile olivenites nitrating trochanteral indiscriminately kolkhozniks embellish defaces egging qat splats budgerigars whoopie nostalgic benignities endemically coifed redips semigroups vigintillion escalloping postconception swillers anorexies valencias frugivores cozens accouchement planters sprucier immediatenesses dissuasiveness uncharitableness haptens loafing cajoles floccus reshown driveled lapidary princeliest caporal collectivized analogue strangeness prosthodontists pyknics indexation otoliths heartaches weakhearted practised drying diamantes tacitly suttas zorils chillum camouflageable ruptured ventricose dwelt drooping rewrapped octavo jackasses misgrafted forks oarsman wooled keeks unfitnesses audiometries unhousing dermatologists superficiality hypermedias mugged harts sensualities nonclassical groundbreaker weakside scrupulously handwork holdup unavailingness redelivers albinotic reconsolidated buttock lexicality knapsack redefecting tweeted martial primipara mistook gegenscheins shivareeing talcum gestating electrodes whitewashes commutative unravelling logion bauhinias thermostated dados umbonic rhythmist egression restudies laypeople erasures unscrewing sirenian outpace oversuds teetotally asthenics parenteral overshot spale scoriaceous noters inventor pommeling fuehrer disintermediations resegregate mahuang prolocutors insectan machicolation casked leukodystrophy malposition cycled raveners paraphrases counterstrikes nertz stouter cavetti salterns rectification choreographic subaudible newie premodifications truckles wapitis tort showcases romancing thous burnous wore graphite pingoes xu uncrown famousnesses caudate beleaps malarial synonymized dropsy ingulfed alant nosologic usurper reimpression quandary recentrifuge overmixing plumbism insolations cleavable acclaims boosting succinctest bardolater veer sorbitol torched warrants benison willowlike propjet radiobiologies doable greenbug begirding effectualities smogless sockdologers hominesses soroses mizzens hospice tawsing smaragds retries orthopteroids bewilderedly retires zoogeographers dystonic fearlessness germ mycobacterium peacekeeper quantified troubleshooters interferometric nereids ineluctability wayfaring utilizable cyclized uxorious inhumanities tearier amiablenesses turbojet grouter etude adjutancy ribbon anilinguses fashionably latish umbrageousness paroled theorematic hexosans counterthreats learn short layman orphaned gypsophila crumbly boodling carling linear diageneses enemy cheerfulness prolonges frizzed platings diarchy sourdine rooflike mahoe disadvantages atheneum adulterous photodissociation provocatively slot celoms impetuous mitt bejeezus spindlier chiliastic postindependence prudishly summerwoods retear butled indirectnesses manslaughter flagrances bureaucratically overstaffed abattoirs playbooks bogged frized jacinthes cabbageworms becrust mestino inhabiter trochili rancidity outleap sodalities odorizes anticholinergics heptarchs haulms velarized undotted blousiest disestablishment uncaked termed citrated officialeses endbrains conglomerations epilogue destination bourgeoise ulcer hognoses jiggles pallidnesses screeches oriole anatomized homebrews immunoprecipitating spuriously blowfish batts lentigo adorers monetise trimming hypercritic superficialities astrological obstructor driftage scatter inflictions supermales finalities advocating racemic physiography rubeolas bendaying warmongerings inhibit silk autochthons knosp surreys correctors coordinative tailleurs gaen braininesses uneasinesses hydrophobicities orchestra araks scapegoats picoting rieslings horrified lamentedly hyponeas devolved adzes bedstead santo logogriphs reearning pandy spearmen hiking aspirational mosquito careen ruffianism sporocarps profound phalanx subgum curatorships scrimmaging encyclical fatheaded occultism coenamor metamorphisms rashes mus]

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

# TODO http://www.datagenetics.com/blog/april12012/index.html#result
