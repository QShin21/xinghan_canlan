Fk:loadTranslationTable{
  ["xh__luoyi"] = "裸衣",
  [":xh__luoyi"] = "摸牌阶段开始时，你亮出牌堆顶的三张牌，然后你可以获得其中的基本牌、武器牌和【决斗】。若如此做，你放弃摸牌，且直到你"..
  "下回合开始，你使用【杀】或【决斗】造成伤害+1。",

  ["@@xh__luoyi"] = "裸衣",
  ["#xh__luoyi-show"] = "裸衣：是否亮出牌堆顶三张牌？",
  ["#xh__luoyi-get"] = "裸衣：是否放弃摸牌，获得其中的基本牌、武器和【决斗】，造成伤害+1？",

  ["$xh__luoyi1"] = "过来打一架，对，就是你！",
  ["$xh__luoyi2"] = "废话少说，放马过来吧！",
}

local luoyi = fk.CreateSkill{
  name = "xh__luoyi",
}

luoyi:addEffect(fk.EventPhaseStart, {
  anim_type = "offensive",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(luoyi.name) and player.phase == Player.Draw
  end,
  on_cost = function(self, event, target, player, data)
    return player.room:askToSkillInvoke(player, {
      skill_name = luoyi.name,
      prompt = "#xh__luoyi-show",
    })
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local cids = room:getNCards(3)
    room:turnOverCardsFromDrawPile(player, cids, luoyi.name)
    local cards = table.filter(cids, function(id)
      local card = Fk:getCardById(id)
      return card.type == Card.TypeBasic or card.sub_type == Card.SubtypeWeapon or card.name == "duel"
    end)
    if #cards > 0 and
      room:askToSkillInvoke(player, {
        skill_name = luoyi.name,
        prompt = "#xh__luoyi-get",
      }) then
      room:obtainCard(player, cards, true, fk.ReasonJustMove, player)
      if not player.dead then
        room:addPlayerMark(player, "@@xh__luoyi")
      end
      data.phase_end = true
    end
    room:cleanProcessingArea(cids)
  end,
})

-- 修复点：清标记应在“你下回合开始”时发生
luoyi:addEffect(fk.TurnStart, {
  can_refresh = function(self, event, target, player, data)
    return target == player and player:getMark("@@xh__luoyi") > 0
  end,
  on_refresh = function(self, event, target, player, data)
    player.room:setPlayerMark(player, "@@xh__luoyi", 0)
  end,
})

luoyi:addEffect(fk.DamageCaused, {
  anim_type = "offensive",
  is_delay_effect = true,
  can_trigger = function(self, event, target, player, data)
    return target == player and player:getMark("@@xh__luoyi") > 0 and
      data.card and (data.card.trueName == "slash" or data.card.name == "duel") and
      data.by_user
  end,
  on_use = function(self, event, target, player, data)
    data:changeDamage(1)
  end,
})

luoyi:addTest(function(room, me)
  local comp2 = room.players[2] ---@type ServerPlayer, ServerPlayer
  FkTest.runInRoom(function()
    room:handleAddLoseSkills(me, luoyi.name)
  end)
  local slash = Fk:getCardById(1)
  FkTest.setNextReplies(me, { "1", json.encode {
    cards = {},
    choice = "xh__luoyi_get"
  }, json.encode {
    card = 1,
    targets = { comp2.id }
  } })
  FkTest.setNextReplies(comp2, { "__cancel" })

  local origin_hp = comp2.hp
  FkTest.runInRoom(function()
    room:obtainCard(me, 1)
    GameEvent.Turn:create(TurnData:new(me, "game_rule")):exec()
  end)
  lu.assertEquals(comp2.hp, origin_hp - 2)

  -- 旧测例这里需要改：修复后标记会持续到你下回合开始，回合外出杀也会加伤
  origin_hp = comp2.hp
  FkTest.runInRoom(function()
    room:useCard{
      from = me,
      tos = { comp2 },
      card = slash,
    }
  end)
  -- 修复后此处应为 -2
  lu.assertEquals(comp2.hp, origin_hp - 2)
end)

return luoyi
