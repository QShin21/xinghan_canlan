-- SPDX-License-Identifier: GPL-3.0-or-later
-- 貂蝉 闭月
-- 结束阶段，你可以摸一张牌，若你本回合未造成过伤害，则改为摸两张牌。

local biyue = fk.CreateSkill{
  name = "xh__biyue",
}

Fk:loadTranslationTable{
  ["xh__biyue"] = "闭月",
  [":xh__biyue"] = "结束阶段，你可以摸一张牌，若你本回合未造成过伤害，则改为摸两张牌。",
  ["#xh__biyue-invoke"] = "闭月：摸一张牌（若本回合未造成伤害则摸两张）",

  ["$xh__biyue1"] = "夫君，我要……",
  ["$xh__biyue2"] = "失礼了……",
}

-- 后台标记：仅用于记录本回合是否造成过伤害
-- 使用 -turn 后缀，回合结束会自动清除，同时不在 UI 显示
local DAMAGE_MARK = "xh__biyue_damage-turn"

biyue:addEffect(fk.EventPhaseStart, {
  anim_type = "draw",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(biyue.name) and player.phase == Player.Finish
  end,
  on_cost = function(self, event, target, player, data)
    return player.room:askToSkillInvoke(player, {
      skill_name = biyue.name,
      prompt = "#xh__biyue-invoke",
    })
  end,
  on_use = function(self, event, target, player, data)
    local has_damage = player:getMark(DAMAGE_MARK) > 0
    if has_damage then
      player:drawCards(1, biyue.name)
    else
      player:drawCards(2, biyue.name)
    end
  end,
})

-- 记录本回合是否造成过伤害
biyue:addEffect(fk.Damage, {
  mute = true,
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(biyue.name)
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    player.room:addPlayerMark(player, DAMAGE_MARK, 1)
  end,
})

-- 兜底清理：无论是否发动闭月，回合结束时都清除记录
biyue:addEffect(fk.TurnEnd, {
  mute = true,
  can_trigger = function(self, event, target, player, data)
    return target == player and player:getMark(DAMAGE_MARK) > 0
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    player.room:setPlayerMark(player, DAMAGE_MARK, 0)
  end,
})

return biyue