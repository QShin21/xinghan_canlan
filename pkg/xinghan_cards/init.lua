-- SPDX-License-Identifier: GPL-3.0-or-later
-- 星汉灿烂 1v1 牌堆配置
-- 共108张牌，基于官方比赛规则设计

local extension = Package:new("xinghan_cards", Package.CardPack)

-- 这个牌堆不定义新卡牌，只定义卡牌的花色和点数分布
-- 所有卡牌类型都来自标准牌堆和军争包

-- A点数（10张）
extension:addCardSpec("archery_attack", Card.Heart, 1)      -- ♥A 万箭齐发
extension:addCardSpec("god_salvation", Card.Heart, 1)       -- ♥A 桃园结义
extension:addCardSpec("nullification", Card.Heart, 1)       -- ♥A 无懈可击
extension:addCardSpec("duel", Card.Diamond, 1)              -- ♦A 决斗
extension:addCardSpec("fan", Card.Diamond, 1)               -- ♦A 朱雀羽扇
extension:addCardSpec("peach", Card.Diamond, 1)             -- ♦A 桃
extension:addCardSpec("crossbow", Card.Club, 1)             -- ♣A 诸葛连弩
extension:addCardSpec("silver_lion", Card.Club, 1)          -- ♣A 白银狮子
extension:addCardSpec("peach", Card.Club, 1)                -- ♣A 桃
extension:addCardSpec("lightning", Card.Spade, 1)           -- ♠A 闪电
extension:addCardSpec("duel", Card.Spade, 1)                -- ♠A 决斗
extension:addCardSpec("guding_blade", Card.Spade, 1)        -- ♠A 古锭刀

-- 2点数（8张）
extension:addCardSpec("jink", Card.Heart, 2)                -- ♥2 闪
extension:addCardSpec("jink", Card.Heart, 2)                -- ♥2 闪
extension:addCardSpec("peach", Card.Diamond, 2)             -- ♦2 桃
extension:addCardSpec("jink", Card.Diamond, 2)              -- ♦2 闪
extension:addCardSpec("vine", Card.Club, 2)                 -- ♣2 藤甲
extension:addCardSpec("eight_diagram", Card.Club, 2)        -- ♣2 八卦阵
extension:addCardSpec("double_swords", Card.Spade, 2)       -- ♠2 雌雄双股剑
extension:addCardSpec("ice_sword", Card.Spade, 2)           -- ♠2 寒冰剑

-- 3点数（8张）
extension:addCardSpec("amazing_grace", Card.Heart, 3)       -- ♥3 五谷丰登
extension:addCardSpec("fire_attack", Card.Heart, 3)         -- ♥3 火攻
extension:addCardSpec("snatch", Card.Diamond, 3)            -- ♦3 顺手牵羊
extension:addCardSpec("peach", Card.Diamond, 3)             -- ♦3 桃
extension:addCardSpec("slash", Card.Club, 3)                -- ♣3 杀
extension:addCardSpec("analeptic", Card.Club, 3)            -- ♣3 酒
extension:addCardSpec("dismantlement", Card.Spade, 3)       -- ♠3 过河拆桥
extension:addCardSpec("analeptic", Card.Spade, 3)           -- ♠3 酒

-- 4点数（8张）
extension:addCardSpec("peach", Card.Heart, 4)               -- ♥4 桃
extension:addCardSpec("fire__slash", Card.Heart, 4)         -- ♥4 火杀
extension:addCardSpec("snatch", Card.Diamond, 4)            -- ♦4 顺手牵羊
extension:addCardSpec("fire__slash", Card.Diamond, 4)       -- ♦4 火杀
extension:addCardSpec("slash", Card.Club, 4)                -- ♣4 杀
extension:addCardSpec("supply_shortage", Card.Club, 4)      -- ♣4 兵粮寸断
extension:addCardSpec("dismantlement", Card.Spade, 4)       -- ♠4 过河拆桥
extension:addCardSpec("thunder__slash", Card.Spade, 4)      -- ♠4 雷杀

-- 5点数（8张）
extension:addCardSpec("kylin_bow", Card.Heart, 5)           -- ♥5 麒麟弓
extension:addCardSpec("chitu", Card.Heart, 5)               -- ♥5 赤兔
extension:addCardSpec("axe", Card.Diamond, 5)               -- ♦5 贯石斧
extension:addCardSpec("fire__slash", Card.Diamond, 5)       -- ♦5 火杀
extension:addCardSpec("dilu", Card.Club, 5)                 -- ♣5 的卢
extension:addCardSpec("thunder__slash", Card.Club, 5)       -- ♣5 雷杀
extension:addCardSpec("blade", Card.Spade, 5)               -- ♠5 青龙偃月刀
extension:addCardSpec("thunder__slash", Card.Spade, 5)      -- ♠5 雷杀

-- 6点数（8张）
extension:addCardSpec("indulgence", Card.Heart, 6)          -- ♥6 乐不思蜀
extension:addCardSpec("peach", Card.Heart, 6)               -- ♥6 桃
extension:addCardSpec("slash", Card.Diamond, 6)             -- ♦6 杀
extension:addCardSpec("jink", Card.Diamond, 6)              -- ♦6 闪
extension:addCardSpec("slash", Card.Club, 6)                -- ♣6 杀
extension:addCardSpec("thunder__slash", Card.Club, 6)       -- ♣6 雷杀
extension:addCardSpec("indulgence", Card.Spade, 6)          -- ♠6 乐不思蜀
extension:addCardSpec("thunder__slash", Card.Spade, 6)      -- ♠6 雷杀

-- 7点数（8张）
extension:addCardSpec("ex_nihilo", Card.Heart, 7)           -- ♥7 无中生有
extension:addCardSpec("peach", Card.Heart, 7)               -- ♥7 桃
extension:addCardSpec("jink", Card.Diamond, 7)              -- ♦7 闪
extension:addCardSpec("jink", Card.Diamond, 7)              -- ♦7 闪
extension:addCardSpec("savage_assault", Card.Club, 7)       -- ♣7 南蛮入侵
extension:addCardSpec("thunder__slash", Card.Club, 7)       -- ♣7 雷杀
extension:addCardSpec("savage_assault", Card.Spade, 7)      -- ♠7 南蛮入侵
extension:addCardSpec("slash", Card.Spade, 7)               -- ♠7 杀

-- 8点数（8张）
extension:addCardSpec("ex_nihilo", Card.Heart, 8)           -- ♥8 无中生有
extension:addCardSpec("peach", Card.Heart, 8)               -- ♥8 桃
extension:addCardSpec("jink", Card.Diamond, 8)              -- ♦8 闪
extension:addCardSpec("jink", Card.Diamond, 8)              -- ♦8 闪
extension:addCardSpec("slash", Card.Club, 8)                -- ♣8 杀
extension:addCardSpec("thunder__slash", Card.Club, 8)       -- ♣8 雷杀
extension:addCardSpec("slash", Card.Spade, 8)               -- ♠8 杀
extension:addCardSpec("slash", Card.Spade, 8)               -- ♠8 杀

-- 9点数（8张）
extension:addCardSpec("peach", Card.Heart, 9)               -- ♥9 桃
extension:addCardSpec("jink", Card.Heart, 9)                -- ♥9 闪
extension:addCardSpec("jink", Card.Diamond, 9)              -- ♦9 闪
extension:addCardSpec("analeptic", Card.Diamond, 9)         -- ♦9 酒
extension:addCardSpec("slash", Card.Club, 9)                -- ♣9 杀
extension:addCardSpec("slash", Card.Club, 9)                -- ♣9 杀
extension:addCardSpec("slash", Card.Spade, 9)               -- ♠9 杀
extension:addCardSpec("slash", Card.Spade, 9)               -- ♠9 杀

-- 10点数（8张）
extension:addCardSpec("slash", Card.Heart, 10)              -- ♥10 杀
extension:addCardSpec("fire__slash", Card.Heart, 10)        -- ♥10 火杀
extension:addCardSpec("slash", Card.Diamond, 10)            -- ♦10 杀
extension:addCardSpec("jink", Card.Diamond, 10)             -- ♦10 闪
extension:addCardSpec("slash", Card.Club, 10)               -- ♣10 杀
extension:addCardSpec("slash", Card.Club, 10)               -- ♣10 杀
extension:addCardSpec("slash", Card.Spade, 10)              -- ♠10 杀
extension:addCardSpec("supply_shortage", Card.Spade, 10)    -- ♠10 兵粮寸断

-- J点数（8张）
extension:addCardSpec("ex_nihilo", Card.Heart, 11)          -- ♥J 无中生有
extension:addCardSpec("jink", Card.Heart, 11)               -- ♥J 闪
extension:addCardSpec("jink", Card.Diamond, 11)             -- ♦J 闪
extension:addCardSpec("jink", Card.Diamond, 11)             -- ♦J 闪
extension:addCardSpec("slash", Card.Club, 11)               -- ♣J 杀
extension:addCardSpec("slash", Card.Club, 11)               -- ♣J 杀
extension:addCardSpec("snatch", Card.Spade, 11)             -- ♠J 顺手牵羊
extension:addCardSpec("iron_chain", Card.Spade, 11)         -- ♠J 铁索连环

-- Q点数（10张）
extension:addCardSpec("dismantlement", Card.Heart, 12)      -- ♥Q 过河拆桥
extension:addCardSpec("lightning", Card.Heart, 12)          -- ♥Q 闪电
extension:addCardSpec("peach", Card.Heart, 12)              -- ♥Q 桃
extension:addCardSpec("peach", Card.Diamond, 12)            -- ♦Q 桃
extension:addCardSpec("nullification", Card.Diamond, 12)    -- ♦Q 无懈可击
extension:addCardSpec("fire_attack", Card.Diamond, 12)      -- ♦Q 火攻
extension:addCardSpec("collateral", Card.Club, 12)          -- ♣Q 借刀杀人
extension:addCardSpec("nullification", Card.Club, 12)       -- ♣Q 无懈可击
extension:addCardSpec("iron_chain", Card.Club, 12)          -- ♣Q 铁索连环
extension:addCardSpec("spear", Card.Spade, 12)              -- ♠Q 丈八蛇矛
extension:addCardSpec("dismantlement", Card.Spade, 12)      -- ♠Q 过河拆桥
extension:addCardSpec("peach", Card.Spade, 12)              -- ♠Q 桃

-- K点数（8张）
extension:addCardSpec("zhuahuangfeidian", Card.Heart, 13)   -- ♥K 爪黄飞电
extension:addCardSpec("jink", Card.Heart, 13)               -- ♥K 闪
extension:addCardSpec("slash", Card.Diamond, 13)            -- ♦K 杀
extension:addCardSpec("hualiu", Card.Diamond, 13)           -- ♦K 骅骝
extension:addCardSpec("collateral", Card.Club, 13)          -- ♣K 借刀杀人
extension:addCardSpec("iron_chain", Card.Club, 13)          -- ♣K 铁索连环
extension:addCardSpec("dayuan", Card.Spade, 13)             -- ♠K 大宛
extension:addCardSpec("nullification", Card.Spade, 13)      -- ♠K 无懈可击

-- 翻译
Fk:loadTranslationTable{
  ["xinghan_cards"] = "星汉灿烂牌堆",
}

return extension
