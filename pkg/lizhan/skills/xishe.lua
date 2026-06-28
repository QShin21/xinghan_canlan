local xishe = fk.CreateSkill {
  name = "wzzz__xishe",
}

Fk:loadTranslationTable {
  ["wzzz__xishe"] = "袭射",
  [":wzzz__xishe"] = "其他角色的准备阶段，你可以弃置一张装备区内的牌，视为对其使用一张无距离限制的【杀】，若其体力值小于你，此【杀】不能被响应，"..
  "然后你可以重复此流程。",

  ["#wzzz__xishe-invoke"] = "袭射：你可以弃置一张装备，视为对 %dest 使用【杀】",

  ["$wzzz__xishe1"] = "伏箭灭破虏，坚城拒讨逆。",
  ["$wzzz__xishe2"] = "什么江东猛虎？还不是我箭下之鬼！",
}

xishe:addEffect(fk.EventPhaseStart, {
  anim_type = "offensive",
  can_trigger = function(self, event, target, player, data)
    return target ~= player and player:hasSkill(xishe.name) and target.phase == Player.Start and
      table.find(player:getCardIds("e"), function(id)
        return not player:prohibitDiscard(id)
      end)
  end,
  on_cost = function (self, event, target, player, data)
    local room = player.room
    local card = room:askToDiscard(player, {
      min_num = 1,
      max_num = 1,
      include_equip = true,
      skill_name = xishe.name,
      pattern = ".|.|.|equip",
      prompt = "#wzzz__xishe-invoke::" .. target.id,
      cancelable = true,
      skip = true,
    })
    if #card > 0 then
      event:setCostData(self, { cards = card })
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local card = event:getCostData(self).cards or {}
    room:throwCard(card, xishe.name, player, player)
    if target.dead then return end
    local slash = Fk:cloneCard("slash")
    slash.skillName = xishe.name
    if player:canUseTo(slash, target, { bypass_distances = true, bypass_times = true }) then
      local use = {
        from = player,
        tos = { target },
        card = slash,
        extraUse = true,
      }
      if player.hp > target.hp then
        use.disresponsiveList = { target }
      end
      room:useCard(use)
    end
    while #player:getCardIds("e") > 0 and not player.dead and not target.dead do
      card = room:askToDiscard(player, {
        min_num = 1,
        max_num = 1,
        include_equip = true,
        skill_name = xishe.name,
        pattern = ".|.|.|equip",
        prompt = "#wzzz__xishe-invoke::" .. target.id,
        cancelable = true,
      })
      if #card == 0 or target.dead then return end
      if player:canUseTo(slash, target, { bypass_distances = true, bypass_times = true }) then
        local use = {
          from = player,
          tos = { target },
          card = slash,
          extraUse = true,
        }
        if player.hp > target.hp then
          use.disresponsiveList = { target }
        end
        room:useCard(use)
      end
    end
  end,
})

return xishe
