-- SPDX-License-Identifier: GPL-3.0-or-later
-- 星汉灿烂 1v1模式拓展包
-- 基于新月杀游戏框架开发

local extension = Package:new("xinghan_canlan", Package.SpecialPack)
local prefix = "packages.xinghan_canlan.pkg."

-- 加载规则技能
extension:loadSkillSkelsByPath("./packages/xinghan_canlan/pkg/xinghan_mode/rule_skills")

-- 添加游戏模式
extension:addGameMode(require "packages.xinghan_canlan.pkg.xinghan_mode.xinghan_1v1")

-- 加载翻译
Fk:loadTranslationTable{ ["xinghan_canlan"] = "星汉灿烂" }
Fk:loadTranslationTable(require 'packages.xinghan_canlan.i18n.en_US', 'en_US')

-- 加载牌堆
local xinghan_cards = require(prefix .. "xinghan_cards")

-- Load merged general packs.
local xinhan_yiwu = require(prefix .. "yiwu")
local xinhan_lizhan = require(prefix .. "lizhan")

return {
  extension,
  xinghan_cards,
  xinhan_yiwu,
  xinhan_lizhan,
}
