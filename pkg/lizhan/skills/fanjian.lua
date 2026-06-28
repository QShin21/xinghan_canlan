

local fanjian = fk.CreateSkill{
  name = "wzzz__fanjian",
}

Fk:loadTranslationTable{
  ["wzzz__fanjian"] = "反间",
  [":wzzz__fanjian"] = "出牌阶段限一次，你可以展示一张手牌，将之交给一名其他角色并令其本回合非锁定技失效，然后其需选择一项："..
  "1.展示所有手牌，然后弃置与此牌花色相同的所有牌（至少两张）；2.失去1点体力。",

  ["#wzzz__fanjian"] = "反间：展示一张手牌并交给一名角色，其本回合非锁定技失效，选择弃牌或失去体力",
  ["@@wzzz__fanjian-turn"] = "非锁定技失效",
  ["wzzz__fanjian_show"] = "展示手牌，弃置所有%arg牌",

  ["$wzzz__fanjian1"] = "与我为敌，就当这般生不如死！",
  ["$wzzz__fanjian2"] = "抉择吧！在苦与痛的地狱中！",
}

fanjian:addEffect("active", {
  anim_type = "control",
  card_num = 1,
  target_num = 1,
  prompt = "#wzzz__fanjian",
  can_use = function(self, player)
    return player:usedSkillTimes(fanjian.name, Player.HistoryPhase) == 0
  end,
  card_filter = function(self, player, to_select, selected)
    return #selected == 0 and table.contains(player:getCardIds("h"), to_select)
  end,
  target_filter = function(self, player, to_select, selected)
    return #selected == 0 and to_select ~= player
  end,
  on_use = function(self, room, effect)
    local player = effect.from
    local target = effect.tos[1]
    local cid = effect.cards[1]
    player:showCards(cid)
    if player.dead or target.dead or not table.contains(player:getCardIds("h"), cid) then return end
    local suit = Fk:getCardById(cid):getSuitString(true)
    room:obtainCard(target, cid, true, fk.ReasonGive, player, fanjian.name)
    if target.dead then return end
    room:addPlayerMark(target, MarkEnum.UncompulsoryInvalidity.."-turn", 1)
    room:setPlayerMark(target, "@@wzzz__fanjian-turn", 1)
    local choices = { "wzzz__fanjian_show:::" .. suit, "loseHp" }
    if #table.filter(target:getCardIds("he"), function (id)
      return Fk:getCardById(id).suit == Fk:getCardById(cid).suit and not target:prohibitDiscard(id)
    end) < 2 then
      table.remove(choices, 1)
    end
    local choice = room:askToChoice(target, {
      choices = choices,
      skill_name = fanjian.name,
    })
    if choice == "loseHp" then
      room:loseHp(target, 1, fanjian.name)
    else
      local cards = target:getCardIds("h")
      target:showCards(cards)
      room:delay(1000)
      if target.dead then return end
      local discards = table.filter(target:getCardIds("he"), function(id)
        return Fk:getCardById(id):getSuitString(true) == suit and not target:prohibitDiscard(id)
      end)
      if #discards > 0 then
        room:throwCard(discards, fanjian.name, target, target)
      end
    end
  end,
})

return fanjian
