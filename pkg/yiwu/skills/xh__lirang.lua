local lirang = fk.CreateSkill {
  name = "xh__lirang",
}

Fk:loadTranslationTable{
  ["xh__lirang"] = "礼让",
  [":xh__lirang"] = "当你的牌因弃置而置入弃牌堆后，你可以将其中的任意张牌交给其他角色；一名角色的结束阶段，你摸等同于你本回合以此法交给其他角色牌数的牌。",

  ["#xh__lirang-give"] = "礼让：你可以将这些牌分配给任意角色，点“取消”仍弃置",

  ["$xh__lirang1"] = "夫礼先王以承天之道，以治人之情。",
  ["$xh__lirang2"] = "谦者，德之柄也，让者，礼之逐也。",
}

lirang:addEffect(fk.AfterCardsMove, {
  anim_type = "support",
  can_trigger = function(self, event, target, player, data)
    if not player:hasSkill(lirang.name) then return false end
    local room = player.room
    if #room:getOtherPlayers(player, false) == 0 then return false end

    local cards = {}
    for _, move in ipairs(data) do
      if move.from == player and move.moveReason == fk.ReasonDiscard and move.toArea == Card.DiscardPile then
        for _, info in ipairs(move.moveInfo) do
          if info.fromArea == Card.PlayerHand or info.fromArea == Card.PlayerEquip then
            table.insertIfNeed(cards, info.cardId)
          end
        end
      end
    end

    cards = table.filter(cards, function(id)
      return table.contains(room.discard_pile, id)
    end)
    cards = room.logic:moveCardsHoldingAreaCheck(cards)

    if #cards > 0 then
      event:setCostData(self, { cards = cards })
      return true
    end
  end,

  on_cost = function(self, event, target, player, data)
    local room = player.room
    local cards = event:getCostData(self).cards
    local result = room:askToYiji(player, {
      cards = cards,
      targets = room:getOtherPlayers(player, false),
      skill_name = lirang.name,
      min_num = 0,
      max_num = #cards,
      prompt = "#xh__lirang-give",
      expand_pile = cards,
      skip = true,
    })

    local any = false
    for _, ids in pairs(result) do
      if #ids > 0 then
        any = true
        break
      end
    end
    if any then
      event:setCostData(self, { cards = cards, extra_data = result })
      return true
    end
  end,

  on_use = function(self, event, target, player, data)
    local room = player.room
    local result = event:getCostData(self).extra_data
    if not result then return end

    local n = 0
    for _, ids in pairs(result) do
      n = n + #ids
    end
    if n > 0 then
      room:addPlayerMark(player, "xh__lirang_given-turn", n)
      room:doYiji(result, player, lirang.name)
    end
  end,
})

lirang:addEffect(fk.EventPhaseStart, {
  anim_type = "drawcard",
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(lirang.name) and not player.dead and
      target and target.phase == Player.Finish and
      player:getMark("xh__lirang_given-turn") > 0
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    local n = player:getMark("xh__lirang_given-turn")
    player.room:setPlayerMark(player, "xh__lirang_given-turn", 0)
    player:drawCards(n, lirang.name)
  end,
})

return lirang