local yinghun = fk.CreateSkill {
  name = "yinghun",
}

Fk:loadTranslationTable{
  ["yinghun"] = "英魂",
  [":yinghun"] = "准备阶段，若你已受伤，你可以选择一名其他角色并选择一项：1.令其摸X张牌，然后弃置一张牌；2.令其摸一张牌，然后弃置X张牌"..
  "（X为你已损失的体力值）。",

  ["#yinghun-choose"] = "英魂：你可以令一名其他角色：摸%arg张牌然后弃置一张牌，或摸一张牌然后弃置%arg张牌",
  ["#yinghun-draw"] = "摸%arg张牌，弃置1张牌",
  ["#yinghun-discard"] = "摸1张牌，弃置%arg张牌",

  ["$yinghun1"] = "以吾魂魄，保佑吾儿之基业。",
  ["$yinghun2"] = "不诛此贼三族，则吾死不瞑目！",
}

yinghun:addEffect(fk.EventPhaseStart, {
  mute = true,
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(yinghun.name) and player.phase == Player.Start and player:isWounded() and
      #player.room:getOtherPlayers(player, false) > 0
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local to = room:askToChoosePlayers(player, {
      min_num = 1,
      max_num = 1,
      targets = room:getOtherPlayers(player, false),
      skill_name = yinghun.name,
      prompt = "#yinghun-choose:::"..player:getLostHp(),
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
    local n = player:getLostHp()
    local choices = {"#yinghun-draw:::" .. n, "#yinghun-discard:::" .. n}
    local choice = room:askToChoice(player, {
      choices = choices,
      skill_name = yinghun.name,
    })
    if choice:startsWith("#yinghun-draw") then
      player:broadcastSkillInvoke(yinghun.name, 1)
      room:notifySkillInvoked(player, yinghun.name, "support", {to.id})
      to:drawCards(n, yinghun.name)
      if not to.dead then
        room:askToDiscard(to, {
          skill_name = yinghun.name,
          cancelable = false,
          min_num = 1,
          max_num = 1,
          include_equip = true,
        })
      end
    else
      player:broadcastSkillInvoke(yinghun.name, 2)
      room:notifySkillInvoked(player, yinghun.name, "control", {to.id})
      to:drawCards(1, yinghun.name)
      if not to.dead then
        room:askToDiscard(to, {
          skill_name = yinghun.name,
          cancelable = false,
          min_num = n,
          max_num = n,
          include_equip = true,
        })
      end
    end
  end,
})

return yinghun
