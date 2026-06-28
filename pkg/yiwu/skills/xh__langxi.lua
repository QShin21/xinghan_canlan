-- SPDX-License-Identifier: GPL-3.0-or-later
-- xh_langxi
-- 准备阶段，你可以选择一名体力值不大于你的角色，然后你进行判定，
-- 若结果为黑色，你对其造成1点伤害。

local langxi = fk.CreateSkill{
  name = "xh__langxi",
}

Fk:loadTranslationTable{
  ["xh__langxi"] = "狼袭",
  [":xh__langxi"] = "准备阶段，你可以选择一名体力值不大于你的角色，然后你进行判定，若结果为黑色，你对其造成1点伤害。",
  ["#xh__langxi-choose"] = "狼袭：选择一名体力值不大于你的角色进行判定，若为黑色则对其造成1点伤害",
  ["$xh__langxi1"] = "袭夺之势，如狼噬骨。",
  ["$xh__langxi2"] = "引吾至此，怎能不袭掠之？",
}

langxi:addEffect(fk.EventPhaseStart, {
  anim_type = "offensive",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(langxi.name) and
      player.phase == Player.Start and
      table.find(player.room.alive_players, function(p)
        return not p.dead and p.hp <= player.hp
      end)
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local targets = table.filter(room.alive_players, function(p)
      return not p.dead and p.hp <= player.hp
    end)
    local to = room:askToChoosePlayers(player, {
      targets = targets,
      min_num = 1,
      max_num = 1,
      prompt = "#xh__langxi-choose",
      skill_name = langxi.name,
      cancelable = true,
    })
    if #to > 0 then
      event:setCostData(self, {tos = to})
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local to = event:getCostData(self).tos[1]
    if not to or to.dead or player.dead then return end

    local judge = {
      who = player,
      reason = langxi.name,
      pattern = ".|.|spade,club",
    }
    room:judge(judge)

    if player.dead or to.dead then return end
    local j = room.logic:getCurrentEvent():findParent(GameEvent.Judge)
    -- 兼容不同环境：优先从判定事件取结果，否则从 judge 结构取 card
    local jc = (j and j.data and j.data.card) or judge.card
    if jc and jc.color == Card.Black then
      room:damage{
        from = player,
        to = to,
        damage = 1,
        skillName = langxi.name,
      }
    end
  end,
})

return langxi