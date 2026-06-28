local liyong = fk.CreateSkill{
  name = "xh__liyong",
  tags = { Skill.Switch },
}

local YANG_USED_MARK = "xh__liyong_yang-phase"
local YIN_USED_MARK = "xh__liyong_yin-phase"

local function getLiyongDiscardCandidates(room, player)
  if not room or not room.discard_pile then return {} end
  local suits = player:getTableMark("@xh__liyong-turn")
  if #suits == 0 then return {} end
  return table.filter(room.discard_pile, function(id)
    local card = Fk:getCardById(id)
    return card and table.contains(suits, card:getSuitString(true))
  end)
end

Fk:loadTranslationTable{
  ["xh__liyong"] = "历勇",
  [":xh__liyong"] = "转换技，出牌阶段每项限一次，阳：你可以将一张本回合你未使用过的花色的牌当【决斗】使用；阴：你可以从弃牌堆中获得一张你本回合使用过的花色的牌，令一名角色视为对你使用一张【决斗】。",

  ["#xh__liyong-yang"] = "历勇：将一张本回合未使用花色的牌当【决斗】使用",
  ["#xh__liyong-yin"] = "历勇：获得弃牌堆中一张本回合已使用花色的牌，选择一名角色视为对你使用【决斗】",
  ["#xh__liyong-get"] = "历勇：请选择要获得的牌",
  ["@xh__liyong-turn"] = "历勇",

  ["$xh__liyong1"] = "今日，我虽死，却未辱武安之名！",
  ["$xh__liyong2"] = "我受文举恩义，今当以死报之！",
}

liyong:addEffect("active", {
  anim_type = "switch",
  min_card_num = 0,
  max_card_num = 1,
  min_target_num = 1,
  prompt = function(self, player)
    return "#xh__liyong-" .. player:getSwitchSkillState(liyong.name, false, true)
  end,
  can_use = function(self, player)
    if player.phase ~= Player.Play then return false end
    local state = player:getSwitchSkillState(liyong.name, false)
    if state == fk.SwitchYang then
      return player:getMark(YANG_USED_MARK) == 0
    elseif state == fk.SwitchYin then
      return player:getMark(YIN_USED_MARK) == 0 and #player:getTableMark("@xh__liyong-turn") > 0
    end
    return false
  end,
  card_filter = function(self, player, to_select, selected)
    if player:getSwitchSkillState(liyong.name, false) == fk.SwitchYang and #selected == 0 then
      local suit = Fk:getCardById(to_select):getSuitString(true)
      if suit == "log_nosuit" then return end
      local card = Fk:cloneCard("duel")
      card.skillName = liyong.name
      card:addSubcard(to_select)
      return player:canUse(card) and not table.contains(player:getTableMark("@xh__liyong-turn"), suit)
    end
  end,
  target_filter = function(self, player, to_select, selected, selected_cards)
    if player:getSwitchSkillState(liyong.name, false) == fk.SwitchYang and #selected_cards == 1 then
      local card = Fk:cloneCard("duel")
      card.skillName = liyong.name
      card:addSubcards(selected_cards)
      return card.skill:targetFilter(player, to_select, selected, {}, card)
    elseif player:getSwitchSkillState(liyong.name, false) == fk.SwitchYin then
      local duel = Fk:cloneCard("duel")
      duel.skillName = liyong.name
      return #selected == 0 and to_select ~= player and
        to_select:canUseTo(duel, player, { bypass_times = true })
    end
  end,
  feasible = function(self, player, selected, selected_cards)
    if #selected_cards == 1 and player:getSwitchSkillState(liyong.name, false) == fk.SwitchYang then
      local card = Fk:cloneCard("duel")
      card.skillName = liyong.name
      card:addSubcards(selected_cards)
      return card.skill:feasible(player, selected, {}, card)
    elseif #selected_cards == 0 and player:getSwitchSkillState(liyong.name, false) == fk.SwitchYin then
      return #selected == 1
    end
  end,
  on_use = function(self, room, effect)
    local player = effect.from
    if #effect.cards > 0 then
      room:setPlayerMark(player, YANG_USED_MARK, 1)
      local card = Fk:getCardById(effect.cards[1])
      if card and card.suit ~= Card.NoSuit then
        room:addTableMarkIfNeed(player, "@xh__liyong-turn", card:getSuitString(true))
      end
      room:sortByAction(effect.tos)
      room:useVirtualCard("duel", effect.cards, player, effect.tos, liyong.name)
    else
      local cards = getLiyongDiscardCandidates(room, player)
      if #cards == 0 then return end

      room:setPlayerMark(player, YIN_USED_MARK, 1)

      local card_id = cards[1]
      if #cards > 1 then
        room:fillAG(player, cards)
        card_id = room:askToAG(player, {
          skill_name = liyong.name,
          prompt = "#xh__liyong-get",
          cancelable = false,
        })
        room:closeAG(player)
      end

      if card_id then
        room:obtainCard(player, card_id, true, fk.ReasonGetFromDiscard, player, liyong.name)
      end

      local target = effect.tos[1]
      if not player.dead and not target.dead then
        room:useVirtualCard("duel", nil, target, player, liyong.name, true)
      end
    end
  end,
})

liyong:addEffect(fk.AfterCardUseDeclared, {
  can_refresh = function(self, event, target, player, data)
    return target == player and player:hasSkill(liyong.name, true) and
      player.room.current == player and data.card.suit ~= Card.NoSuit
  end,
  on_refresh = function(self, event, target, player, data)
    player.room:addTableMarkIfNeed(player, "@xh__liyong-turn", data.card:getSuitString(true))
  end,
})

liyong:addAcquireEffect(function (self, player, is_start)
  if player.room.current == player then
    local room = player.room
    local mark = {}
    room.logic:getEventsOfScope(GameEvent.UseCard, 1, function (e)
      local use = e.data
      if use.from == player and use.card.suit ~= Card.NoSuit then
        table.insertIfNeed(mark, use.card:getSuitString(true))
      end
    end, Player.HistoryTurn)
    if #mark > 0 then
      room:setPlayerMark(player, "@xh__liyong-turn", mark)
    end
  end
end)

return liyong
