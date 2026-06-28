local tiandu = fk.CreateSkill{
  name = "xh__tiandu",
  tags = { Skill.Switch },
}

Fk:loadTranslationTable{
  ["xh__tiandu"] = "天妒",
  [":xh__tiandu"] = "转换技，出牌阶段开始时，你可以阳：弃置两张手牌，然后视为使用任意一张普通锦囊牌；阴：进行判定并获得此判定牌，然后若你因发动此技能而弃置过与结果花色相同的牌，你受到1点无来源伤害。",
  [":xh__tiandu_yang"] = "转换技，出牌阶段开始时，你可以<font color=\"#E0DB2F\">阳：弃置两张手牌，然后视为使用任意一张普通锦囊牌；</font><font color=\"gray\">阴：进行判定并获得此判定牌，然后若你因发动此技能而弃置过与结果花色相同的牌，你受到1点无来源伤害。</font>",
  [":xh__tiandu_yin"] = "转换技，出牌阶段开始时，你可以<font color=\"gray\">阳：弃置两张手牌，然后视为使用任意一张普通锦囊牌；</font><font color=\"#E0DB2F\">阴：进行判定并获得此判定牌，然后若你因发动此技能而弃置过与结果花色相同的牌，你受到1点无来源伤害。</font>",

  ["#xh__tiandu-yang"] = "天妒：你可以弃置两张手牌，然后视为使用任意一张普通锦囊牌",
  ["#xh__tiandu-yin"] = "天妒：你可以进行判定并获得判定牌，若结果花色与你因“天妒”弃置过的牌相同，你受到1点伤害",
  ["#xh__tiandu-use"] = "天妒：你可以视为使用一张普通锦囊牌",
  ["@[suits]xh__tiandu"] = "天妒",

  ["$xh__tiandu1"] = "顺应天命，即为大道所归。",
  ["$xh__tiandu2"] = "计高于人，为天所妒。",
}

tiandu:addEffect(fk.EventPhaseStart, {
  anim_type = "switch",
  mute = true,
  can_trigger = function(self, event, target, player, data)
    if target ~= player or not player:hasSkill(tiandu.name) or player.phase ~= Player.Play then return false end

    if player:getSwitchSkillState(tiandu.name, false) == fk.SwitchYang then
      return player:getHandcardNum() > 1
    end
    return true
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    if player:getSwitchSkillState(tiandu.name, false) == fk.SwitchYang then
      local cards = room:askToDiscard(player, {
        min_num = 2,
        max_num = 2,
        include_equip = false,
        skill_name = tiandu.name,
        cancelable = true,
        pattern = ".",
        prompt = "#xh__tiandu-yang",
        skip = true,
      })
      if #cards > 0 then
        event:setCostData(self, { cards = cards })
        return true
      end
    elseif room:askToSkillInvoke(player, {
      skill_name = tiandu.name,
      prompt = "#xh__tiandu-yin",
    }) then
      event:setCostData(self, { cards = {} })
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local cards = event:getCostData(self).cards

    room:notifySkillInvoked(player, tiandu.name)
    if #cards > 0 then
      player:broadcastSkillInvoke(tiandu.name, 1)

      local suits = player:getTableMark("@[suits]xh__tiandu")
      local changed = false
      for _, id in ipairs(cards) do
        local suit = Fk:getCardById(id).suit
        if suit ~= Card.NoSuit and table.insertIfNeed(suits, suit) then
          changed = true
        end
      end
      if changed then
        room:setPlayerMark(player, "@[suits]xh__tiandu", suits)
      end

      room:throwCard(cards, tiandu.name, player, player)
      if player.dead then return end
      room:askToUseVirtualCard(player, {
        name = Fk:getAllCardNames("t"),
        skill_name = tiandu.name,
        prompt = "#xh__tiandu-use",
        cancelable = true,
      })
    else
      player:broadcastSkillInvoke(tiandu.name, 2)

      local judge = {
        who = player,
        reason = tiandu.name,
      }
      room:judge(judge)

      if not player.dead and table.contains(player:getTableMark("@[suits]xh__tiandu"), judge.card.suit) then
        room:damage{
          to = player,
          damage = 1,
          skillName = tiandu.name,
        }
      end
    end
  end,
})

tiandu:addEffect(fk.FinishJudge, {
  mute = true,
  is_delay_effect = true,
  can_trigger = function(self, event, target, player, data)
    return target == player and data.reason == tiandu.name and player.room:getCardArea(data.card.id) == Card.Processing
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    player.room:obtainCard(player, data.card, true, fk.ReasonJustMove, player, tiandu.name)
  end,
})

tiandu:addLoseEffect(function(self, player)
  player.room:setPlayerMark(player, "@[suits]xh__tiandu", 0)
end)

return tiandu
