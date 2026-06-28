local lulve = fk.CreateSkill {
  name = "xh__lulve",
}

Fk:loadTranslationTable{
  ["xh__lulve"] = "掳掠",
  [":xh__lulve"] = "出牌阶段开始时，你可以选择一名有手牌且手牌数小于你的角色，然后其选择一项：1.交给你所有手牌，然后你结束此阶段；2.你视为对其使用一张造成伤害+1的【杀】。",

  ["#xh__lulve-choose"] = "掳掠：你可以令一名有手牌且手牌数小于你的角色选择一项",
  ["xh__lulve_give"] = "将所有手牌交给%src，然后%src结束此阶段",
  ["xh__lulve_slash"] = "%src视为对你使用一张造成伤害+1的【杀】",

  ["$xh__lulve1"] = "趁火打劫，乘危掳掠。",
  ["$xh__lulve2"] = "天下大乱，掳掠以自保。",
}

lulve:addEffect(fk.EventPhaseStart, {
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(lulve.name) and player.phase == Player.Play and
      table.find(player.room:getOtherPlayers(player, false), function(p)
        return not p.dead and (not p:isKongcheng()) and p:getHandcardNum() < player:getHandcardNum()
      end)
  end,

  on_cost = function(self, event, target, player, data)
    local room = player.room
    local targets = table.filter(room:getOtherPlayers(player, false), function(p)
      return not p.dead and (not p:isKongcheng()) and p:getHandcardNum() < player:getHandcardNum()
    end)
    local to = room:askToChoosePlayers(player, {
      targets = targets,
      min_num = 1,
      max_num = 1,
      prompt = "#xh__lulve-choose",
      skill_name = lulve.name,
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

    local choice = room:askToChoice(to, {
      choices = {"xh__lulve_give:" .. player.id, "xh__lulve_slash:" .. player.id},
      skill_name = lulve.name,
    })

    if choice:startsWith("xh__lulve_give") then
      local ids = to:getCardIds("h")
      if #ids > 0 then
        room:moveCardTo(ids, Player.Hand, player, fk.ReasonGive, lulve.name, nil, false, to)
      end
      if not player.dead then
        -- 修复点：结束本阶段用阶段数据标记
        data.phase_end = true
      end
    else
      if player.dead or to.dead then return end
      room:setPlayerMark(to, "xh__lulve_slashplus", player.id)
      room:useVirtualCard("slash", nil, player, to, lulve.name, true)
    end
  end,
})

lulve:addEffect(fk.DamageCaused, {
  anim_type = "offensive",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(lulve.name) and data.card and data.to and
      data.card.trueName == "slash" and data.card.skillName == lulve.name and
      data.to:getMark("xh__lulve_slashplus") == player.id
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:setPlayerMark(data.to, "xh__lulve_slashplus", 0)
    data:changeDamage(1)
  end,
})

lulve:addEffect(fk.CardUseFinished, {
  can_refresh = function(self, event, target, player, data)
    return target == player and data.card and data.card.trueName == "slash" and data.card.skillName == lulve.name
  end,
  on_refresh = function(self, event, target, player, data)
    local room = player.room
    for _, p in ipairs(data.tos or {}) do
      if p and not p.dead and p:getMark("xh__lulve_slashplus") == player.id then
        room:setPlayerMark(p, "xh__lulve_slashplus", 0)
      end
    end
  end,
})

return lulve