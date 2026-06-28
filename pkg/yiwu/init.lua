-- SPDX-License-Identifier: GPL-3.0-or-later
-- 星汉灿烂 - 义武武将包
local extension = Package:new("xinhan_yiwu")
extension.extensionName = "xinghan_canlan"

-- 加载技能
extension:loadSkillSkelsByPath("./packages/xinghan_canlan/pkg/yiwu/skills")

Fk:loadTranslationTable {
  ["xinhan_yiwu"] = "星汉灿烂·义武",
}


-- 以下为魏国武将

-- 曹洪，男，魏，4勾玉
General:new(extension, "xh__caohong", "wei", 4):addSkills { "xh__yuanhu" }
Fk:loadTranslationTable {
  ["xh__caohong"] = "曹洪",
  ["#xh__caohong"] = "忠烈护主",
  ["illustrator:xh__caohong"] = "KayaK",
  ["~xh__caohong"] = "将军走好！",
}

-- 曹仁，男，魏，4勾玉
General:new(extension, "xh__caoren", "wei", 4):addSkills { "xh__sujun", "xh__lifeng" }
Fk:loadTranslationTable {
  ["xh__caoren"] = "曹仁",
  ["#xh__caoren"] = "大将军",
  ["illustrator:xh__caoren"] = "KayaK",
  ["~xh__caoren"] = "实在是守不住了……",
}


-- 夏侯惇，男，魏，4勾玉
General:new(extension, "xh__xiahoudun", "wei", 4):addSkills { "ex__ganglie", "ex__qingjian" }
Fk:loadTranslationTable {
  ["xh__xiahoudun"] = "夏侯惇",
  ["#xh__xiahoudun"] = "独眼的罗刹",
  ["illustrator:xh__xiahoudun"] = "KayaK",
  ["~xh__xiahoudun"] = "独目残躯，不惧生死。",
}

-- 许褚，男，魏，4勾玉
General:new(extension, "xh__xuchu", "wei", 4):addSkills { "xh__luoyi" }
Fk:loadTranslationTable {
  ["xh__xuchu"] = "许褚",
  ["#xh__xuchu"] = "虎痴",
  ["illustrator:xh__xuchu"] = "KayaK",
  ["~xh__xuchu"] = "冷……好冷……",
}

-- 张辽，男，魏，4勾玉
General:new(extension, "xh__zhangliao", "wei", 4):addSkills { "ex__tuxi" }
Fk:loadTranslationTable {
  ["xh__zhangliao"] = "张辽",
  ["#xh__zhangliao"] = "前将军",
  ["illustrator:xh__zhangliao"] = "KayaK",
  ["~xh__zhangliao"] = "真的没想到……",
}

-- 荀彧，男，魏，3勾玉
General:new(extension, "xh__xunyu", "wei", 3):addSkills { "quhu", "m_ex__jieming" }
Fk:loadTranslationTable {
  ["xh__xunyu"] = "荀彧",
  ["#xh__xunyu"] = "王佐之才",
  ["illustrator:xh__xunyu"] = "KayaK",
  ["~xh__xunyu"] = "主公，臣去矣……",
}

-- 郭嘉，男，魏，3勾玉
General:new(extension, "xh__guojia", "wei", 3):addSkills { "xh__tiandu", "xh__yiji" }
Fk:loadTranslationTable {
  ["xh__guojia"] = "郭嘉",
  ["#xh__guojia"] = "早终的先知",
  ["illustrator:xh__guojia"] = "KayaK",
  ["~xh__guojia"] = "咳……咳……",
}

-- 乐进，男，魏，4勾玉
General:new(extension, "xh__lejin", "wei", 4):addSkills { "ty__xiaoguo" }
Fk:loadTranslationTable {
  ["xh__lejin"] = "乐进",
  ["#xh__lejin"] = "奋强突固",
  ["illustrator:xh__lejin"] = "KayaK",
  ["~xh__lejin"] = "力竭……",
}

-- 于禁，男，魏，4勾玉
General:new(extension, "xh__yujin", "wei", 4):addSkills { "ty_ex__zhenjun" }
Fk:loadTranslationTable {
  ["xh__yujin"] = "于禁",
  ["#xh__yujin"] = "弗克其终",
  ["illustrator:xh__yujin"] = "KayaK",
  ["~xh__yujin"] = "将军走好！",
}

-- 李典，男，魏，3勾玉
General:new(extension, "xh__lidian", "wei", 3):addSkills { "xunxun", "ol_ex__wangxi" }
Fk:loadTranslationTable {
  ["xh__lidian"] = "李典",
  ["#xh__lidian"] = "深明大义",
  ["illustrator:xh__lidian"] = "KayaK",
  ["~xh__lidian"] = "报国无门……",
}

-- 以下为蜀国武将

-- 赵云，男，蜀，4勾玉
General:new(extension, "xh__zhaoyun", "shu", 4):addSkills { "ol_ex__longdan", "ol_ex__yajiao" }
Fk:loadTranslationTable {
  ["xh__zhaoyun"] = "赵云",
  ["#xh__zhaoyun"] = "常山赵子龙",
  ["illustrator:xh__zhaoyun"] = "KayaK",
  ["~xh__zhaoyun"] = "这，就是失败的滋味吗……",
}

-- 张飞，男，蜀，4勾玉
General:new(extension, "xh__zhangfei", "shu", 4):addSkills { "ex__paoxiao", "ex__tishen" }
Fk:loadTranslationTable {
  ["xh__zhangfei"] = "张飞",
  ["#xh__zhangfei"] = "万夫不当",
  ["illustrator:xh__zhangfei"] = "KayaK",
  ["~xh__zhangfei"] = "实在是……打不动了……",
}

-- 关羽，男，蜀，4勾玉
General:new(extension, "xh__guanyu", "shu", 4):addSkills { "ex__wusheng", "ex__yijue" }
Fk:loadTranslationTable {
  ["xh__guanyu"] = "关羽",
  ["#xh__guanyu"] = "武圣",
  ["illustrator:xh__guanyu"] = "KayaK",
  ["~xh__guanyu"] = "什么？此地竟有……",
}



-- 以下为吴国武将



-- 孙坚，男，吴，4/5勾玉
General:new(extension, "xh__sunjian", "wu", 4, 5):addSkills { "yinghun" }
Fk:loadTranslationTable {
  ["xh__sunjian"] = "孙坚",
  ["#xh__sunjian"] = "江东猛虎",
  ["illustrator:xh__sunjian"] = "KayaK",
  ["~xh__sunjian"] = "有埋伏……呃……",
}

-- 黄盖，男，吴，4勾玉
General:new(extension, "xh__huanggai", "wu", 4):addSkills { "ex__kurou", "zhaxiang" }
Fk:loadTranslationTable {
  ["xh__huanggai"] = "黄盖",
  ["#xh__huanggai"] = "轻身为国",
  ["illustrator:xh__huanggai"] = "KayaK",
  ["~xh__huanggai"] = "再无……苦肉计了……",
}

-- 韩当，男，吴，4勾玉
General:new(extension, "xh__handang", "wu", 4):addSkills { "ty_ex__gongqi", "ty_ex__jiefan" }
Fk:loadTranslationTable {
  ["xh__handang"] = "韩当",
  ["#xh__handang"] = "石城侯",
  ["illustrator:xh__handang"] = "KayaK",
  ["~xh__handang"] = "江东……",
}

--以下为群雄武将


-- 贾诩，男，群，3勾玉
General:new(extension, "xh__jiaxu", "qun", 3):addSkills { "wzzz__wansha", "ol_ex__luanwu", "xh__weimu" }
Fk:loadTranslationTable {
  ["xh__jiaxu"] = "贾诩",
  ["#xh__jiaxu"] = "冷酷的毒士",
  ["illustrator:xh__jiaxu"] = "KayaK",
  ["~xh__jiaxu"] = "我的时辰……到了……",
}

-- 吕布，男，群，5勾玉
General:new(extension, "xh__lvbu", "qun", 5):addSkills { "wushuang", "liyu" }
Fk:loadTranslationTable {
  ["xh__lvbu"] = "吕布",
  ["#xh__lvbu"] = "武的化身",
  ["illustrator:xh__lvbu"] = "KayaK",
  ["~xh__lvbu"] = "不可能！",
}

-- 貂蝉，女，群，3勾玉
General:new(extension, "xh__diaochan", "qun", 3, 3, General.Female):addSkills { "xh__biyue" }
Fk:loadTranslationTable {
  ["xh__diaochan"] = "貂蝉",
  ["#xh__diaochan"] = "绝世的舞姬",
  ["illustrator:xh__diaochan"] = "KayaK",
  ["~xh__diaochan"] = "父亲大人，对不起……",
}

-- 董卓，男，群，4勾玉
General:new(extension, "xh__dongzhuo", "qun", 4):addSkills { "jiuchi", "xh__hengzheng" }
Fk:loadTranslationTable {
  ["xh__dongzhuo"] = "董卓",
  ["#xh__dongzhuo"] = "魔王",
  ["illustrator:xh__dongzhuo"] = "KayaK",
  ["~xh__dongzhuo"] = "汉室……亡了……",
}


-- 李傕，男，群，4勾玉
General:new(extension, "xh__lijue", "qun", 4):addSkills { "xh__langxi", "xh__yisuan" }
Fk:loadTranslationTable {
  ["xh__lijue"] = "李傕",
  ["#xh__lijue"] = "狼子野心",
  ["illustrator:xh__lijue"] = "KayaK",
  ["~xh__lijue"] = "西凉……",
}

-- 郭汜，男，群，4勾玉
General:new(extension, "xh__guosi", "qun", 4):addSkills { "xh__tanbei", "sidao" }
Fk:loadTranslationTable {
  ["xh__guosi"] = "郭汜",
  ["#xh__guosi"] = "贪婪之徒",
  ["illustrator:xh__guosi"] = "KayaK",
  ["~xh__guosi"] = "西凉……",
}

-- 王允，男，群，3勾玉
General:new(extension, "xh__wangyun", "qun", 3):addSkills { "wzzz__jiexuan", "wzzz__zhongliu" }
Fk:loadTranslationTable {
  ["xh__wangyun"] = "王允",
  ["#xh__wangyun"] = "连环计主",
  ["illustrator:xh__wangyun"] = "KayaK",
  ["~xh__wangyun"] = "汉室……",
}


-- 张济，男，群，4勾玉
General:new(extension, "xh__zhangji_qun", "qun", 4):addSkills { "xh__lueming", "xh__tunjun" }
Fk:loadTranslationTable {
  ["xh__zhangji_qun"] = "张济",
  ["#xh__zhangji_qun"] = "西凉军阀",
  ["illustrator:xh__zhangji_qun"] = "KayaK",
  ["~xh__zhangji_qun"] = "西凉……",
}

-- 徐荣，男，群，4勾玉
General:new(extension, "xh__xurong", "qun", 4):addSkills { "xh__xionghuo" }
Fk:loadTranslationTable {
  ["xh__xurong"] = "徐荣",
  ["#xh__xurong"] = "凶镬之将",
  ["illustrator:xh__xurong"] = "KayaK",
  ["~xh__xurong"] = "西凉……",
}


-- 袁绍，男，群，4勾玉
General:new(extension, "xh__yuanshao", "qun", 4):addSkills { "mou__luanji" }
Fk:loadTranslationTable {
  ["xh__yuanshao"] = "袁绍",
  ["#xh__yuanshao"] = "高贵的名门",
  ["illustrator:xh__yuanshao"] = "KayaK",
  ["~xh__yuanshao"] = "老天不公啊！",
}


-- 公孙瓒，男，群，4勾玉
General:new(extension, "xh__gongsunzan", "qun", 4):addSkills { "qiaomeng", "ty_ex__yicong" }
Fk:loadTranslationTable {
  ["xh__gongsunzan"] = "公孙瓒",
  ["#xh__gongsunzan"] = "白马将军",
  ["illustrator:xh__gongsunzan"] = "KayaK",
  ["~xh__gongsunzan"] = "白马……",
}

-- 韩遂，男，群，4勾玉
General:new(extension, "xh__hansui", "qun", 4):addSkills { "mobile__niluan", "mobile__xiaoxi" }
Fk:loadTranslationTable {
  ["xh__hansui"] = "韩遂",
  ["#xh__hansui"] = "西凉军阀",
  ["illustrator:xh__hansui"] = "KayaK",
  ["~xh__hansui"] = "西凉……",
}

-- 鲍信，男，群，4勾玉
General:new(extension, "xh__baoxin", "qun", 4):addSkills { "xh__mutao", "xh__yimou" }
Fk:loadTranslationTable {
  ["xh__baoxin"] = "鲍信",
  ["#xh__baoxin"] = "义兵首领",
  ["illustrator:xh__baoxin"] = "KayaK",
  ["~xh__baoxin"] = "义兵……",
}

-- 孔融，男，群，3勾玉
General:new(extension, "xh__kongrong", "qun", 3):addSkills { "ty__mingshi", "xh__lirang" }
Fk:loadTranslationTable {
  ["xh__kongrong"] = "孔融",
  ["#xh__kongrong"] = "名士",
  ["illustrator:xh__kongrong"] = "KayaK",
  ["~xh__kongrong"] = "名士……",
}


-- 杨奉，男，群，4勾玉
General:new(extension, "xh__yangfeng", "qun", 4):addSkills { "xuetu" }
Fk:loadTranslationTable {
  ["xh__yangfeng"] = "杨奉",
  ["#xh__yangfeng"] = "白波军帅",
  ["illustrator:xh__yangfeng"] = "KayaK",
  ["~xh__yangfeng"] = "白波……",
}

-- 张燕，男，群，4勾玉
General:new(extension, "xh__zhangyan", "qun", 4):addSkills { "suji", "xh__langdao" }
Fk:loadTranslationTable {
  ["xh__zhangyan"] = "张燕",
  ["#xh__zhangyan"] = "黑山军帅",
  ["illustrator:xh__zhangyan"] = "KayaK",
  ["~xh__zhangyan"] = "黑山……",
}

-- 梁兴，男，群，4勾玉
General:new(extension, "xh__liangxing", "qun", 4):addSkills { "xh__lulve" }
Fk:loadTranslationTable {
  ["xh__liangxing"] = "梁兴",
  ["#xh__liangxing"] = "西凉悍将",
  ["illustrator:xh__liangxing"] = "KayaK",
  ["~xh__liangxing"] = "西凉……",
}


-- 华雄，男，群，4勾玉
General:new(extension, "xh__huaxiong", "qun", 4):addSkills { "mou__yaowu", "mou__yangwei" }
Fk:loadTranslationTable {
  ["xh__huaxiong"] = "华雄",
  ["#xh__huaxiong"] = "西凉猛将",
  ["illustrator:xh__huaxiong"] = "KayaK",
  ["~xh__huaxiong"] = "西凉……",
}


-- 孙策(群)，男，群，4勾玉
General:new(extension, "xhsp__sunce", "qun", 4):addSkills { "liantao" }
Fk:loadTranslationTable {
  ["xhsp__sunce"] = "孙策",
  ["#xhsp__sunce"] = "江东小霸王",
  ["illustrator:xhsp__sunce"] = "KayaK",
  ["~xhsp__sunce"] = "大业未成……",
}


-- 牛辅，男，群，4/5勾玉
General:new(extension, "xh__niufu", "qun", 4, 5):addSkills { "xh__xiaoxi", "xh__xiongrao" }
Fk:loadTranslationTable {
  ["xh__niufu"] = "牛辅",
  ["#xh__niufu"] = "西凉女婿",
  ["illustrator:xh__niufu"] = "KayaK",
  ["~xh__niufu"] = "西凉……",
}


-- 刘备(群)，男，群，4勾玉
General:new(extension, "xhqi__liubei", "qun", 4):addSkills { "xh__jishan", "zhenqiao" }
Fk:loadTranslationTable {
  ["xhqi__liubei"] = "刘备",
  ["#xhqi__liubei"] = "乱世枭雄",
  ["illustrator:xhqi__liubei"] = "KayaK",
  ["~xhqi__liubei"] = "乱世……",
}


-- 袁术，男，群，4勾玉
General:new(extension, "xh__yuanshu", "qun", 4):addSkills { "xh__yongsi" }
Fk:loadTranslationTable {
  ["xh__yuanshu"] = "袁术",
  ["#xh__yuanshu"] = "仲家",
  ["illustrator:xh__yuanshu"] = "KayaK",
  ["~xh__yuanshu"] = "仲家……",
}


-- 潘凤，男，群，4勾玉
General:new(extension, "xh__panfeng", "qun", 4):addSkills { "ty__kuangfu" }
Fk:loadTranslationTable {
  ["xh__panfeng"] = "潘凤",
  ["#xh__panfeng"] = "无双上将",
  ["illustrator:xh__panfeng"] = "KayaK",
  ["~xh__panfeng"] = "上将……",
}

-- 纪灵，男，群，4勾玉
General:new(extension, "xh__jiling", "qun", 4):addSkills { "ty__shuangren" }
Fk:loadTranslationTable {
  ["xh__jiling"] = "纪灵",
  ["#xh__jiling"] = "山东名将",
  ["illustrator:xh__jiling"] = "KayaK",
  ["~xh__jiling"] = "山东……",
}

-- 颜良文丑，男，群，4勾玉
General:new(extension, "xh__yanliangwenchou", "qun", 4):addSkills { "ol_ex__shuangxiong" }
Fk:loadTranslationTable {
  ["xh__yanliangwenchou"] = "颜良文丑",
  ["#xh__yanliangwenchou"] = "虎狼兄弟",
  ["illustrator:xh__yanliangwenchou"] = "KayaK",
  ["~xh__yanliangwenchou"] = "河北……",
}


-- 田丰，男，群，3勾玉
General:new(extension, "xh__tianfeng", "qun", 3):addSkills { "ty__sijian", "ty__suishi" }
Fk:loadTranslationTable {
  ["xh__tianfeng"] = "田丰",
  ["#xh__tianfeng"] = "河北谋士",
  ["illustrator:xh__tianfeng"] = "KayaK",
  ["~xh__tianfeng"] = "吾命休矣……",
}

-- 马腾，男，群，4勾玉
General:new(extension, "xh__mateng", "qun", 4):addSkills { "mashu", "xh__xiongyi" }
Fk:loadTranslationTable {
  ["xh__mateng"] = "马腾",
  ["#xh__mateng"] = "西凉太守",
  ["illustrator:xh__mateng"] = "KayaK",
  ["~xh__mateng"] = "西凉……完了……",
}

-- 李儒，男，群，3勾玉
General:new(extension, "xh__liru", "qun", 3):addSkills { "mieji", "juece", "fencheng" }
Fk:loadTranslationTable {
  ["xh__liru"] = "李儒",
  ["#xh__liru"] = "魔士",
  ["illustrator:xh__liru"] = "KayaK",
  ["~xh__liru"] = "主公……",
}


-- 武安国，男，群，4勾玉
General:new(extension, "xh__wuananguo", "qun", 4):addSkills { "xh__liyong" }
Fk:loadTranslationTable {
  ["xh__wuananguo"] = "武安国",
  ["#xh__wuananguo"] = "断腕猛将",
  ["illustrator:xh__wuananguo"] = "KayaK",
  ["~xh__wuananguo"] = "北海……",
}


-- 高顺，男，群，4勾玉
General:new(extension, "xh__gaoshun", "qun", 4):addSkills { "ty_ex__xianzhen", "ty_ex__jinjiu" }
Fk:loadTranslationTable {
  ["xh__gaoshun"] = "高顺",
  ["#xh__gaoshun"] = "陷阵营主",
  ["illustrator:xh__gaoshun"] = "KayaK",
  ["~xh__gaoshun"] = "陷阵……败了……",
}


return extension
