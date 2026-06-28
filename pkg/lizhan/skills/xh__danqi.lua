-- SPDX-License-Identifier: GPL-3.0-or-later
-- 关羽(魏) - 单骑技能
-- 觉醒技，准备阶段，若你的手牌数大于体力值，你减少1点体力上限，然后获得"马术"和"怒斩"。

local danqi = fk.CreateSkill {
  name = "xh__danqi",
  tags = { Skill.Wake },
}

Fk:loadTranslationTable {
  ["xh__danqi"] = "单骑",
  [":xh__danqi"] = "觉醒技，准备阶段，若你的手牌数大于体力值，你减少1点体力上限，然后获得\"马术\"和\"怒斩\"。",

  ["#xh__danqi-wake"] = "单骑：手牌数大于体力值，觉醒获得【马术】和【怒斩】",

  ["$xh__danqi1"] = "单骑千里，过关斩将！",
  ["$xh__danqi2"] = "千里走单骑，义薄云天！",
}

danqi:addEffect(fk.EventPhaseStart, {
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(danqi.name) and
      player.phase == Player.Start and
      player:usedSkillTimes(danqi.name, Player.HistoryGame) == 0 and
      player:getHandcardNum() > player.hp
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:notifySkillInvoked(player, danqi.name, "support")
    -- 减少1点体力上限
    room:changeMaxHp(player, -1)
    -- 获得马术和怒斩
    room:handleAddLoseSkills(player, "mashu|nuzhan", nil, false, true)
  end,
})

return danqi
