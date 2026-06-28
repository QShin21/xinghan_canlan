local yaohu = fk.CreateSkill {
  name = "xh__yaohu",
}

local PHASE_MARK = "@@xh__yaohu-phase"

Fk:loadTranslationTable{
  ["xh__yaohu"] = "邀虎",
  [":xh__yaohu"] = "每轮限一次，你的回合开始时，你可以选择场上一个势力。被你选择势力的其他角色出牌阶段开始时，其获得你的一张“生”，然后其直到本阶段结束时，若其使用伤害牌指定你为目标时，须交给你两张牌，否则取消之。",

  ["#xh__yaohu-invoke"] = "邀虎：你可以选择场上一个势力，令该势力其他角色出牌阶段开始时受“邀虎”影响",
  ["#xh__yaohu-choice"] = "邀虎：选择你要“邀虎”的势力",
  ["#xh__yaohu-get"] = "邀虎：请选择要获得的“生”",
  ["@xh__yaohu"] = "邀虎",
  ["@@xh__yaohu-phase"] = "邀虎",
  ["#xh__yaohu-give"] = "邀虎：你需交给 %src 两张牌，否则其取消此%arg",

  ["$xh__yaohu1"] = "益州疲敝，还望贤兄相助。",
  ["$xh__yaohu2"] = "内讨米贼，外拒强曹，璋无宗兄万万不可啊。",
}

yaohu:addEffect(fk.TurnStart, {
  anim_type = "support",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(yaohu.name) and
      player:usedEffectTimes(yaohu.name, Player.HistoryRound) == 0
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local kingdoms = {}
    for _, p in ipairs(room.alive_players) do
      table.insertIfNeed(kingdoms, p.kingdom)
    end
    if #kingdoms == 0 or not room:askToSkillInvoke(player, {
      skill_name = yaohu.name,
      prompt = "#xh__yaohu-invoke",
    }) then
      return false
    end

    local choice = room:askToChoice(player, {
      choices = kingdoms,
      skill_name = yaohu.name,
      prompt = "#xh__yaohu-choice",
    })
    if choice then
      event:setCostData(self, choice)
      return true
    end
    return false
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local choice = event:getCostData(self)
    room:setPlayerMark(player, "@xh__yaohu", choice)
  end,
})

yaohu:addEffect(fk.EventPhaseStart, {
  anim_type = "support",
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(yaohu.name) and target ~= player and target.phase == Player.Play and not target.dead and
      player:getMark("@xh__yaohu") == target.kingdom
  end,
  on_cost = function(self, event, target, player, data)
    event:setCostData(self, { tos = { target } })
    return true
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    if not player.dead and not target.dead then
      room:addTableMark(target, PHASE_MARK, player.id)
    end

    local sheng = player:getPile("liuzhang_sheng")
    if #sheng == 0 then return end

    local id = sheng[1]
    if #sheng > 1 then
      room:fillAG(target, sheng)
      id = room:askToAG(target, {
        skill_name = yaohu.name,
        prompt = "#xh__yaohu-get",
        cancelable = false,
      })
      room:closeAG(target)
    end
    if not id then return end

    room:obtainCard(target, id, true, fk.ReasonPrey, target, yaohu.name)
  end,
})

yaohu:addEffect(fk.TargetSpecifying, {
  anim_type = "defensive",
  is_delay_effect = true,
  can_trigger = function(self, event, target, player, data)
    return data and data.card and data.to == player and table.contains(target:getTableMark(PHASE_MARK), player.id) and
      data.card.is_damage_card and not data.cancelled
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    local room = player.room
    if #target:getCardIds("he") < 2 then
      data:cancelCurrentTarget()
    else
      local cards = room:askToCards(target, {
        min_num = 2,
        max_num = 2,
        include_equip = true,
        skill_name = yaohu.name,
        prompt = "#xh__yaohu-give:" .. player.id .. "::" .. data.card:toLogString(),
        cancelable = true,
      })
      if #cards == 2 then
        room:obtainCard(player, cards, false, fk.ReasonGive, target, yaohu.name)
      else
        data:cancelCurrentTarget()
      end
    end
  end,
})

yaohu:addEffect(fk.EventPhaseEnd, {
  mute = true,
  is_delay_effect = true,
  can_refresh = function(self, event, target, player, data)
    return target == player and player.phase == Player.Play and player:getMark(PHASE_MARK) ~= 0
  end,
  on_refresh = function(self, event, target, player, data)
    player.room:setPlayerMark(player, PHASE_MARK, 0)
  end,
})

return yaohu
