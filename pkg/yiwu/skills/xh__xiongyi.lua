local xiongyi = fk.CreateSkill{
  name = "xh__xiongyi",
  tags = { Skill.Limited },
}

Fk:loadTranslationTable{
  ["xh__xiongyi"] = "雄异",
  [":xh__xiongyi"] = "限定技，出牌阶段，你可以令与你势力相同的所有角色各摸三张牌，然后若你的体力值为场上唯一最小，你回复1点体力。当你脱离濒死状态时，本技能视为未发动过并删除回复体力的效果。",

  ["#xh__xiongyi"] = "雄异：令与你势力相同的所有角色各摸三张牌",
  ["$xh__xiongyi1"] = "弟兄们，我们的机会来啦！",
  ["$xh__xiongyi2"] = "此时不战，更待何时！",
}

local function getKingdom(player)
  if player.kingdom == "wild" then
    return player.role
  end
  return player.kingdom
end

local function sameKingdom(p, me)
  return p.kingdom ~= "unknown" and me.kingdom ~= "unknown" and getKingdom(p) == getKingdom(me)
end

local function isUniqueMinHp(room, me)
  return table.every(room:getOtherPlayers(me, false), function(p)
    return p.hp > me.hp
  end)
end

xiongyi:addEffect("active", {
  anim_type = "drawcard",
  prompt = "#xh__xiongyi",
  card_num = 0,
  target_num = 0,
  card_filter = Util.FalseFunc,

  can_use = function(self, player)
    return player.phase == Player.Play and player:usedSkillTimes(xiongyi.name, Player.HistoryGame) == 0
  end,

  on_use = function(self, room, effect)
    local player = effect.from

    local targets = table.filter(room:getAlivePlayers(), function(p)
      return not p.dead and sameKingdom(p, player)
    end)
    for _, p in ipairs(targets) do
      if not p.dead then
        p:drawCards(3, xiongyi.name)
      end
    end

    if player.dead then return end
    if player:getMark("xh__xiongyi_noheal") > 0 then return end
    if not player:isWounded() then return end
    if not isUniqueMinHp(room, player) then return end

    room:recover{
      who = player,
      num = 1,
      recoverBy = player,
      skillName = xiongyi.name,
    }
  end,
})

xiongyi:addEffect(fk.AfterDying, {
  can_refresh = function(self, event, target, player, data)
    return target == player and not player.dead and player:usedSkillTimes(xiongyi.name, Player.HistoryGame) > 0
  end,
  on_refresh = function(self, event, target, player, data)
    player:setSkillUseHistory(xiongyi.name, 0, Player.HistoryGame)
    player.room:setPlayerMark(player, "xh__xiongyi_noheal", 1)
  end,
})

return xiongyi
