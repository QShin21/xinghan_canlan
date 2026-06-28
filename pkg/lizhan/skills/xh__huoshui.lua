local huoshui = fk.CreateSkill{
  name = "xh__huoshui",
}

Fk:loadTranslationTable{
  ["xh__huoshui"] = "祸水",
  [":xh__huoshui"] = "准备阶段，你可以令一名其他角色依次执行X项效果（X为你已损失的体力值且至少为1）：1.本回合非锁定技失效；2.交给你1张手牌；3.弃置装备区里的所有牌。",
  ["#xh__huoshui-choose_target"] = "祸水：选择一名其他角色执行效果（X为你已损失体力且至少为1）",
  ["#xh__huoshui-give"] = "祸水：请交给 %src 一张手牌",

  ["$xh__huoshui1"] = "呵呵，走不动了嘛。",
  ["$xh__huoshui2"] = "别走了，再玩一会儿嘛。",
}

huoshui:addEffect(fk.EventPhaseStart, {
  anim_type = "control",

  can_trigger = function(self, event, target, player, data)
    return target == player
      and player:hasSkill(huoshui.name)
      and player.phase == Player.Start
      and #player.room:getOtherPlayers(player, false) > 0
  end,

  on_cost = function(self, event, target, player, data)
    local room = player.room
    local tos = room:askToChoosePlayers(player, {
      min_num = 1,
      max_num = 1,
      targets = room:getOtherPlayers(player, false),
      skill_name = huoshui.name,
      prompt = "#xh__huoshui-choose_target",
      cancelable = true,
    })
    if #tos > 0 then
      event:setCostData(self, { to = tos[1] })
      return true
    end
    return false
  end,

  on_use = function(self, event, target, player, data)
    local room = player.room
    local p = event:getCostData(self).to
    if not p or p.dead then return end

    local x = math.max(1, player:getLostHp())
    if x > 3 then x = 3 end

    -- 1. 本回合非锁定技失效
    room:setPlayerMark(p, MarkEnum.UncompulsoryInvalidity .. "-turn", 1)

    -- 2. 交给你1张手牌
    if x >= 2 and not player.dead and not p:isKongcheng() then
      local cards = room:askToCards(p, {
        min_num = 1,
        max_num = 1,
        include_equip = false,
        skill_name = huoshui.name,
        prompt = "#xh__huoshui-give:" .. player.id,
        cancelable = false,
      })
      if cards and #cards > 0 then
        room:moveCardTo(cards, Player.Hand, player, fk.ReasonGive, huoshui.name, nil, false, p)
      end
    end

    -- 3. 弃置装备区里的所有牌
    if x >= 3 and not p.dead then
      p:throwAllCards("e", huoshui.name)
    end
  end,
})

return huoshui