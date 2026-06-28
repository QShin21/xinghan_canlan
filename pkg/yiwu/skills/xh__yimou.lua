local yimou = fk.CreateSkill{
  name = "xh__yimou",
}

Fk:loadTranslationTable{
  ["xh__yimou"] = "毅谋",
  [":xh__yimou"] = "当与你距离1以内的角色受到伤害后，你可以选择一项：1.令其摸一张牌；2.令其将一张手牌交给另一名角色，然后其摸一张牌。",

  ["xh__yimou_draw"] = "%dest摸一张牌",
  ["xh__yimou_give"] = "%dest将一张手牌交给另一名角色，然后摸一张牌",
  ["#xh__yimou-give"] = "毅谋：将一张手牌交给一名其他角色，然后摸一张牌",

  ["$xh__yimou1"] = "泰然若定，攻敌自溃！",
  ["$xh__yimou2"] = "吾等当为大义，兴大谋，成大事！",
}

yimou:addEffect(fk.Damaged, {
  mute = true,
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(yimou.name) and target and not target.dead and player:distanceTo(target) <= 1
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local choices = { "xh__yimou_draw::" .. target.id }
    if not target:isKongcheng() and #room:getOtherPlayers(target, false) > 0 then
      table.insert(choices, "xh__yimou_give::" .. target.id)
    end
    table.insert(choices, "Cancel")
    local choice = room:askToChoice(player, {
      choices = choices,
      skill_name = yimou.name,
    })
    if choice ~= "Cancel" then
      event:setCostData(self, { tos = { target }, choice = choice })
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local choice = event:getCostData(self).choice
    room:notifySkillInvoked(player, yimou.name, "masochism", { target })

    if choice:startsWith("xh__yimou_draw") then
      player:broadcastSkillInvoke(yimou.name, 1)
      if not target.dead then
        target:drawCards(1, yimou.name)
      end
    else
      player:broadcastSkillInvoke(yimou.name, 2)
      if target.dead or target:isKongcheng() then return end
      local to, cards = room:askToChooseCardsAndPlayers(target, {
        min_card_num = 1,
        max_card_num = 1,
        min_num = 1,
        max_num = 1,
        targets = room:getOtherPlayers(target, false),
        pattern = ".|.|.|hand",
        skill_name = yimou.name,
        prompt = "#xh__yimou-give",
        cancelable = false,
      })
      if #cards > 0 and #to > 0 then
        room:moveCardTo(cards, Player.Hand, to[1], fk.ReasonGive, yimou.name, nil, false, target)
      end
      if not target.dead then
        target:drawCards(1, yimou.name)
      end
    end
  end,
})

return yimou