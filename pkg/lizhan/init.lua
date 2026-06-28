-- SPDX-License-Identifier: GPL-3.0-or-later
-- 星汉灿烂 - 励战武将包
local extension = Package:new("xinhan_lizhan")
extension.extensionName = "xinghan_canlan"

-- 加载技能
extension:loadSkillSkelsByPath("./packages/xinghan_canlan/pkg/lizhan/skills")

Fk:loadTranslationTable {
  ["xinhan_lizhan"] = "星汉灿烂·励战",
}



-- 曹操，男，魏，4勾玉
local caocao=General:new(extension, "xh__caocao", "wei", 4)
caocao:addSkills { "xh__shuzhi" }
caocao:addRelatedSkills { "ex__jianxiong", "ofl__qingzheng" }
Fk:loadTranslationTable {
  ["xh__caocao"] = "曹操",
  ["#xh__caocao"] = "魏武帝",
  ["illustrator:xh__caocao"] = "KayaK",
  ["~xh__caocao"] = "孤……不甘心……",
}

-- 曹仁，男，魏，4勾玉
General:new(extension, "xhsp__caoren", "wei", 4):addSkills { "weikui", "lizhan" }
Fk:loadTranslationTable {
  ["xhsp__caoren"] = "曹仁",
  ["#xhsp__caoren"] = "大将军",
  ["illustrator:xhsp__caoren"] = "KayaK",
  ["~xhsp__caoren"] = "实在是守不住了……",
}

-- 曹昂，男，魏，4勾玉
General:new(extension, "xh__caoang", "wei", 4):addSkills { "kangkai" }
Fk:loadTranslationTable {
  ["xh__caoang"] = "曹昂",
  ["#xh__caoang"] = "丰愍王",
  ["illustrator:xh__caoang"] = "KayaK",
  ["~xh__caoang"] = "父亲……快走……",
}

-- 王朗，男，魏，3勾玉
General:new(extension, "xh__wanglang", "wei", 3):addSkills { "gushe", "jici" }
Fk:loadTranslationTable {
  ["xh__wanglang"] = "王朗",
  ["#xh__wanglang"] = "凤鸣",
  ["illustrator:xh__wanglang"] = "KayaK",
  ["~xh__wanglang"] = "诸葛村夫……",
}

-- 华歆，男，魏，3勾玉
General:new(extension, "xh__huaxin", "wei", 3):addSkills { "wanggui", "xibing" }
Fk:loadTranslationTable {
  ["xh__huaxin"] = "华歆",
  ["#xh__huaxin"] = "一龙",
  ["illustrator:xh__huaxin"] = "KayaK",
  ["~xh__huaxin"] = "管宁……",
}

-- 关羽(魏)，男，魏，4勾玉
local guanyu = General:new(extension, "xhsp__guanyu", "wei", 4)
guanyu:addSkills { "ex__wusheng", "xh__danqi" }
guanyu:addRelatedSkills { "mashu", "nuzhan" }
Fk:loadTranslationTable {
  ["xhsp__guanyu"] = "关羽",
  ["#xhsp__guanyu"] = "武圣",
  ["illustrator:xhsp__guanyu"] = "KayaK",
  ["~xhsp__guanyu"] = "什么？此地竟有……",
}

-- 荀攸，男，魏，3勾玉
General:new(extension, "xh__xunyou", "wei", 3):addSkills { "qice", "ty_ex__zhiyu" }
Fk:loadTranslationTable {
  ["xh__xunyou"] = "荀攸",
  ["#xh__xunyou"] = "谋主",
  ["illustrator:xh__xunyou"] = "KayaK",
  ["~xh__xunyou"] = "主公……",
}

-- 典韦，男，魏，4勾玉
General:new(extension, "xh__dianwei", "wei", 4):addSkills { "ol__qiangxi", "ninge" }
Fk:loadTranslationTable {
  ["xh__dianwei"] = "典韦",
  ["#xh__dianwei"] = "古之恶来",
  ["illustrator:xh__dianwei"] = "KayaK",
  ["~xh__dianwei"] = "主公……快走……",
}

-- 以下为蜀国武将


-- 刘备，男，蜀，4勾玉
General:new(extension, "xh__liubei", "shu", 4):addSkills { "v11__renwang" }
Fk:loadTranslationTable {
  ["xh__liubei"] = "刘备",
  ["#xh__liubei"] = "乱世的枭雄",
  ["illustrator:xh__liubei"] = "KayaK",
  ["~xh__liubei"] = "这就是……桃园吗……",
}

-- 诸葛亮，男，蜀，3勾玉
General:new(extension, "xh__zhugeliang", "shu", 3):addSkills { "bazhen", "ol_ex__huoji", "kanpo" }
Fk:loadTranslationTable {
  ["xh__zhugeliang"] = "诸葛亮",
  ["#xh__zhugeliang"] = "卧龙",
  ["illustrator:xh__zhugeliang"] = "KayaK",
  ["~xh__zhugeliang"] = "将星陨落……",
}

-- 黄月英，女，蜀，3勾玉
General:new(extension, "xh__huangyueying", "shu", 3, 3, General.Female):addSkills { "xh__jizhi", "ex__qicai" }
Fk:loadTranslationTable {
  ["xh__huangyueying"] = "黄月英",
  ["#xh__huangyueying"] = "归隐的杰女",
  ["illustrator:xh__huangyueying"] = "KayaK",
  ["~xh__huangyueying"] = "亮……",
}

-- 孙乾，男，蜀，3勾玉
General:new(extension, "xh__sunqian", "shu", 3):addSkills { "shuimeng" }
Fk:loadTranslationTable {
  ["xh__sunqian"] = "孙乾",
  ["#xh__sunqian"] = "说客",
  ["illustrator:xh__sunqian"] = "KayaK",
  ["~xh__sunqian"] = "主公……",
}

-- 张世平，男，蜀，3勾玉
General:new(extension, "xh__zhangshiping", "shu", 3):addSkills { "hongji" }
Fk:loadTranslationTable {
  ["xh__zhangshiping"] = "张世平",
  ["#xh__zhangshiping"] = "商贾",
  ["illustrator:xh__zhangshiping"] = "KayaK",
  ["~xh__zhangshiping"] = "生意……",
}

-- 马超，男，蜀，4勾玉
General:new(extension, "xh__machao", "shu", 4):addSkills { "mashu", "ex__tieji" }
Fk:loadTranslationTable {
  ["xh__machao"] = "马超",
  ["#xh__machao"] = "一骑当千",
  ["illustrator:xh__machao"] = "KayaK",
  ["~xh__machao"] = "西凉……",
}

-- 关平，男，蜀，4勾玉
General:new(extension, "xh__guanping", "shu", 4):addSkills { "ty_ex__longyin", "ty_ex__jiezhong" }
Fk:loadTranslationTable {
  ["xh__guanping"] = "关平",
  ["#xh__guanping"] = "忠义",
  ["illustrator:xh__guanping"] = "KayaK",
  ["~xh__guanping"] = "父亲……",
}

-- 魏延，男，蜀，4勾玉
General:new(extension, "xh__weiyan", "shu", 4):addSkills { "ol_ex__kuanggu", "m_ex__qimou" }
Fk:loadTranslationTable {
  ["xh__weiyan"] = "魏延",
  ["#xh__weiyan"] = "狂骨",
  ["illustrator:xh__weiyan"] = "KayaK",
  ["~xh__weiyan"] = "谁敢杀我！",
}

-- 黄忠，男，蜀，4勾玉
General:new(extension, "xh__huangzhong", "shu", 4):addSkills { "ol_ex__liegong" }
Fk:loadTranslationTable {
  ["xh__huangzhong"] = "黄忠",
  ["#xh__huangzhong"] = "老当益壮",
  ["illustrator:xh__huangzhong"] = "KayaK",
  ["~xh__huangzhong"] = "老矣……",
}

-- 徐庶，男，蜀，4勾玉
local xushu = General:new(extension, "xh__xushu", "shu", 4)
xushu:addSkills { "ty_ex__zhuhai", "xh__qianxin" }
xushu:addRelatedSkill("xh__jianyan")
Fk:loadTranslationTable {
  ["xh__xushu"] = "徐庶",
  ["#xh__xushu"] = "忠孝",
  ["illustrator:xh__xushu"] = "KayaK",
  ["~xh__xushu"] = "母亲……",
}


-- 以下为吴国武将

-- 孙权，男，吴，4勾玉
General:new(extension, "xh__sunquan", "wu", 4):addSkills { "xh__zhiheng" }
Fk:loadTranslationTable {
  ["xh__sunquan"] = "孙权",
  ["#xh__sunquan"] = "江东之主",
  ["illustrator:xh__sunquan"] = "KayaK",
  ["~xh__sunquan"] = "江东……",
}

-- 孙坚sp，男，吴，4/5勾玉
General:new(extension, "xhsp__sunjian", "wu", 4, 5):addSkills { "xh__hulie" }
Fk:loadTranslationTable {
  ["xhsp__sunjian"] = "孙坚",
  ["#xhsp__sunjian"] = "江东猛虎",
  ["illustrator:xhsp__sunjian"] = "KayaK",
  ["~xhsp__sunjian"] = "有埋伏……呃……",
}

-- 孙策(吴)，男，吴，4勾玉
local sunce=General:new(extension, "xh__sunce", "wu", 4)
sunce:addSkills { "jiang", "m_ex__hunzi" }
sunce:addRelatedSkills { "ex__yingzi", "yinghun" }
Fk:loadTranslationTable {
  ["xh__sunce"] = "孙策",
  ["#xh__sunce"] = "江东小霸王",
  ["illustrator:xh__sunce"] = "KayaK",
  ["~xh__sunce"] = "内事不决问张昭，外事不决问周瑜……",
}

-- 周瑜，男，吴，3勾玉
General:new(extension, "xh__zhouyu", "wu", 3):addSkills { "ex__yingzi", "wzzz__fanjian" }
Fk:loadTranslationTable {
  ["xh__zhouyu"] = "周瑜",
  ["#xh__zhouyu"] = "大都督",
  ["illustrator:xh__zhouyu"] = "KayaK",
  ["~xh__zhouyu"] = "既生瑜，何生亮……",
}

-- 庞统，男，吴，3勾玉
General:new(extension, "xh__pangtong", "wu", 3):addSkills { "guolun", "zhanji" }
Fk:loadTranslationTable {
  ["xh__pangtong"] = "庞统",
  ["#xh__pangtong"] = "凤雏",
  ["illustrator:xh__pangtong"] = "KayaK",
  ["~xh__pangtong"] = "落凤坡……",
}

--以下为群雄武将


-- 刘表，男，群，3勾玉
General:new(extension, "xh__liubiao", "qun", 3):addSkills { "re__zishou", "m_ex__zongshi" }
Fk:loadTranslationTable {
  ["xh__liubiao"] = "刘表",
  ["#xh__liubiao"] = "荆州牧",
  ["illustrator:xh__liubiao"] = "KayaK",
  ["~xh__liubiao"] = "荆州……",
}

-- 杨彪，男，群，3勾玉
General:new(extension, "xh__yangbiao", "qun", 3):addSkills { "js__zhaohan", "js__rangjie", "js__yizheng" }
Fk:loadTranslationTable {
  ["xh__yangbiao"] = "杨彪",
  ["#xh__yangbiao"] = "汉室忠臣",
  ["illustrator:xh__yangbiao"] = "KayaK",
  ["~xh__yangbiao"] = "汉室……",
}


-- 刘繇，男，群，4勾玉
General:new(extension, "xh__liuyao", "qun", 4):addSkills { "xh__kannan" }
Fk:loadTranslationTable {
  ["xh__liuyao"] = "刘繇",
  ["#xh__liuyao"] = "扬州刺史",
  ["illustrator:xh__liuyao"] = "KayaK",
  ["~xh__liuyao"] = "扬州……",
}


-- 许贡，男，群，3勾玉
General:new(extension, "xh__xugong", "qun", 3):addSkills { "mobile__biaozhao" }
Fk:loadTranslationTable {
  ["xh__xugong"] = "许贡",
  ["#xh__xugong"] = "吴郡太守",
  ["illustrator:xh__xugong"] = "KayaK",
  ["~xh__xugong"] = "吴郡……",
}


-- 高干，男，群，4勾玉
General:new(extension, "xh__gaogan", "qun", 4):addSkills { "xh__juguan" }
Fk:loadTranslationTable {
  ["xh__gaogan"] = "高干",
  ["#xh__gaogan"] = "并州刺史",
  ["illustrator:xh__gaogan"] = "KayaK",
  ["~xh__gaogan"] = "并州……",
}

-- 袁谭袁尚袁熙，男，群，4勾玉
General:new(extension, "xh__yuantanyuanshangyuanxi", "qun", 4):addSkills { "xh__neifa" }
Fk:loadTranslationTable {
  ["xh__yuantanyuanshangyuanxi"] = "袁谭袁尚袁熙",
  ["#xh__yuantanyuanshangyuanxi"] = "袁氏兄弟",
  ["illustrator:xh__yuantanyuanshangyuanxi"] = "KayaK",
  ["~xh__yuantanyuanshangyuanxi"] = "袁氏……",
}

-- 刘辟，男，群，4勾玉
General:new(extension, "xh__liupi", "qun", 4):addSkills { "yichengl" }
Fk:loadTranslationTable {
  ["xh__liupi"] = "刘辟",
  ["#xh__liupi"] = "黄巾渠帅",
  ["illustrator:xh__liupi"] = "KayaK",
  ["~xh__liupi"] = "黄巾……",
}

-- 邹氏，女，群，3勾玉
General:new(extension, "xh__zoushi", "qun", 3, 3, General.Female):addSkills { "xh__huoshui", "xh__qingcheng" }
Fk:loadTranslationTable {
  ["xh__zoushi"] = "邹氏",
  ["#xh__zoushi"] = "祸水红颜",
  ["illustrator:xh__zoushi"] = "KayaK",
  ["~xh__zoushi"] = "祸水……",
}


-- 黄祖，男，群，4勾玉
General:new(extension, "xh__huangzu", "qun", 4):addSkills { "wzzz__xishe" }
Fk:loadTranslationTable {
  ["xh__huangzu"] = "黄祖",
  ["#xh__huangzu"] = "江夏太守",
  ["illustrator:xh__huangzu"] = "KayaK",
  ["~xh__huangzu"] = "江夏……",
}

-- 董卓(新)，男，群，4勾玉
General:new(extension, "xhsp__dongzhuo", "qun", 4):addSkills { "xiongni", "fengshang" }
Fk:loadTranslationTable {
  ["xhsp__dongzhuo"] = "董卓",
  ["#xhsp__dongzhuo"] = "魔王",
  ["illustrator:xhsp__dongzhuo"] = "KayaK",
  ["~xhsp__dongzhuo"] = "汉室……亡了……",
}


-- 段煨，男，群，4勾玉
General:new(extension, "xh__duanwei", "qun", 4):addSkills { "ty__langmie" }
Fk:loadTranslationTable {
  ["xh__duanwei"] = "段煨",
  ["#xh__duanwei"] = "忠义之士",
  ["illustrator:xh__duanwei"] = "KayaK",
  ["~xh__duanwei"] = "忠义……",
}


-- 沮授，男，群，3勾玉
General:new(extension, "xh__jushou", "qun", 3):addSkills { "ty_ex__jianying", "ty_ex__shibei" }
Fk:loadTranslationTable {
  ["xh__jushou"] = "沮授",
  ["#xh__jushou"] = "河北谋士",
  ["illustrator:xh__jushou"] = "KayaK",
  ["~xh__jushou"] = "河北……",
}


-- 郭图，男，群，3勾玉
General:new(extension, "xh__guotu", "qun", 3):addSkills { "qushi", "weijie" }
Fk:loadTranslationTable {
  ["xh__guotu"] = "郭图",
  ["#xh__guotu"] = "河北谋士",
  ["illustrator:xh__guotu"] = "KayaK",
  ["~xh__guotu"] = "河北……",
}

-- 张辽(群)，男，群，4勾玉
General:new(extension, "xhsp__zhangliao", "qun", 4):addSkills { "mubing", "xh__ziqu" }
Fk:loadTranslationTable {
  ["xhsp__zhangliao"] = "张辽",
  ["#xhsp__zhangliao"] = "雁门张辽",
  ["illustrator:xhsp__zhangliao"] = "KayaK",
  ["~xhsp__zhangliao"] = "雁门……",
}



-- 张角，男，群，3勾玉
General:new(extension, "xh__zhangjiao", "qun", 3):addSkills { "ex__leiji", "xh__guidao" }
Fk:loadTranslationTable {
  ["xh__zhangjiao"] = "张角",
  ["#xh__zhangjiao"] = "天公将军",
  ["illustrator:xh__zhangjiao"] = "KayaK",
  ["~xh__zhangjiao"] = "黄天……",
}


-- 张郃，男，群，4勾玉
General:new(extension, "xh__zhanghe_qun", "qun", 4):addSkills { "xh__zhouxuan" }
Fk:loadTranslationTable {
  ["xh__zhanghe_qun"] = "张郃",
  ["#xh__zhanghe_qun"] = "巧变之士",
  ["illustrator:xh__zhanghe_qun"] = "KayaK",
  ["~xh__zhanghe_qun"] = "巧变……",
}



-- 于吉，男，群，3勾玉
General:new(extension, "xh__yuji", "qun", 3):addSkills { "ol_ex__guhuo" }
Fk:loadTranslationTable {
  ["xh__yuji"] = "于吉",
  ["#xh__yuji"] = "太平道人",
  ["illustrator:xh__yuji"] = "KayaK",
  ["~xh__yuji"] = "蛊惑……",
}


-- 樊稠，男，群，4勾玉
General:new(extension, "xh__fanchou", "qun", 4):addSkills { "xh__xingluan" }
Fk:loadTranslationTable {
  ["xh__fanchou"] = "樊稠",
  ["#xh__fanchou"] = "西凉悍将",
  ["illustrator:xh__fanchou"] = "KayaK",
  ["~xh__fanchou"] = "西凉……",
}

-- 张绣，男，群，4勾玉
General:new(extension, "xh__zhangxiu", "qun", 4):addSkills { "ld__fudi", "ld__congjian" }
Fk:loadTranslationTable {
  ["xh__zhangxiu"] = "张绣",
  ["#xh__zhangxiu"] = "宛城侯",
  ["illustrator:xh__zhangxiu"] = "KayaK",
  ["~xh__zhangxiu"] = "宛城……",
}

-- 刘协，男，群，3勾玉
General:new(extension, "xh__liuxie", "qun", 3):addSkills { "xh__tianming", "xh__mizhao" }
Fk:loadTranslationTable {
  ["xh__liuxie"] = "刘协",
  ["#xh__liuxie"] = "汉献帝",
  ["illustrator:xh__liuxie"] = "KayaK",
  ["~xh__liuxie"] = "汉室……",
}

-- 许攸，男，群，3勾玉
General:new(extension, "xh__xuyou", "qun", 3):addSkills { "chenglue", "xh__shicai" }
Fk:loadTranslationTable {
  ["xh__xuyou"] = "许攸",
  ["#xh__xuyou"] = "恃才傲物",
  ["illustrator:xh__xuyou"] = "KayaK",
  ["~xh__xuyou"] = "恃才……",
}

-- 士燮，男，群，3勾玉
General:new(extension, "xh__shixie", "qun", 3):addSkills { "ld__biluan", "xh__lixia" }
Fk:loadTranslationTable {
  ["xh__shixie"] = "士燮",
  ["#xh__shixie"] = "交州牧",
  ["illustrator:xh__shixie"] = "KayaK",
  ["~xh__shixie"] = "交州……",
}


-- 公孙度，男，群，4勾玉
General:new(extension, "xh__gongsundu", "qun", 4):addSkills { "zhenze", "anliao" }
Fk:loadTranslationTable {
  ["xh__gongsundu"] = "公孙度",
  ["#xh__gongsundu"] = "辽东太守",
  ["illustrator:xh__gongsundu"] = "KayaK",
  ["~xh__gongsundu"] = "辽东……",
}


-- 陶谦，男，群，3勾玉
General:new(extension, "xh__taoqian", "qun", 3):addSkills { "ty__yixiang" }
Fk:loadTranslationTable {
  ["xh__taoqian"] = "陶谦",
  ["#xh__taoqian"] = "徐州牧",
  ["illustrator:xh__taoqian"] = "KayaK",
  ["~xh__taoqian"] = "徐州……",
}

-- 张鲁，男，群，3勾玉
General:new(extension, "xh__zhanglu", "qun", 3):addSkills { "yishe", "bushi", "midao" }
Fk:loadTranslationTable {
  ["xh__zhanglu"] = "张鲁",
  ["#xh__zhanglu"] = "汉中太守",
  ["illustrator:xh__zhanglu"] = "KayaK",
  ["~xh__zhanglu"] = "汉中……",
}

-- 陈宫，男，群，3勾玉
General:new(extension, "xh__chengong", "qun", 3):addSkills { "xh__mingce", "xh__yinpan" }
Fk:loadTranslationTable {
  ["xh__chengong"] = "陈宫",
  ["#xh__chengong"] = "智计之士",
  ["illustrator:xh__chengong"] = "KayaK",
  ["~xh__chengong"] = "智计……",
}

-- 刘璋，男，群，3勾玉
General:new(extension, "xh__liuzhang", "qun", 3):addSkills { "xh__jutu", "xh__yaohu" }
Fk:loadTranslationTable {
  ["xh__liuzhang"] = "刘璋",
  ["#xh__liuzhang"] = "益州牧",
  ["illustrator:xh__liuzhang"] = "KayaK",
  ["~xh__liuzhang"] = "益州……",
}

return extension
