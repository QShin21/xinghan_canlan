local hengzheng = fk.CreateSkill {
  name = "xh__hengzheng",
}

Fk:loadTranslationTable{
  ["xh__hengzheng"] = "横征",
  [":xh__hengzheng"] = "准备阶段，若你的体力值为1或你没有手牌，你可以获得一名其他角色区域里的一张牌。",
  ["#xh__hengzheng-choose"] = "横征：你可以获得一名其他角色区域里的一张牌",
}

hengzheng:addEffect(fk.EventPhaseStart, {
  anim_type = "offensive",
  can_trigger = function (self, event, target, player, data)
    return target == player and player:hasSkill(hengzheng.name) and
      player.phase == Player.Start and
      (player:isKongcheng() or player.hp == 1) and
      table.find(player.room:getOtherPlayers(player, false), function (p)
        return not p:isAllNude()
      end)
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local tos = room:askToChoosePlayers(player, {
      targets = table.filter(room:getOtherPlayers(player, false), function(p)
        return not p:isAllNude()
      end),
      min_num = 1,
      max_num = 1,
      prompt = "#xh__hengzheng-choose",
      skill_name = hengzheng.name,
      cancelable = true,
    })
    if #tos > 0 then
      event:setCostData(self, { tos = tos })
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local to = event:getCostData(self).tos[1]
    if not to or to.dead or to:isAllNude() then return end
    local id = room:askToChooseCard(player, {
      target = to,
      flag = "hej",
      skill_name = hengzheng.name,
    })
    if id then
      room:obtainCard(player, id, false, fk.ReasonPrey, player, hengzheng.name)
    end
  end,
})

return hengzheng
