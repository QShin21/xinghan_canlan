local jishan = fk.CreateSkill{
  name = "xh__jishan",
}

Fk:loadTranslationTable{
  ["xh__jishan"] = "积善",
  [":xh__jishan"] = "每回合限一次，当一名角色受到伤害时，你可以防止此伤害并失去2点体力，然后其摸一张牌，你摸一张牌。",

  ["#xh__jishan-invoke"] = "积善：你可以失去2点体力，防止 %dest 受到的伤害，然后你与其各摸一张牌",

  ["$xh__jishan1"] = "勿以善小而不为。",
  ["$xh__jishan2"] = "积善成德，而神明自得。",
}

jishan:addEffect(fk.DamageInflicted, {
  anim_type = "support",
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(jishan.name) and not player.dead and not target.dead and
      player:usedEffectTimes(self.name, Player.HistoryTurn) == 0 and
      data and data.damage and data.damage > 0
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    if room:askToSkillInvoke(player, {
      skill_name = jishan.name,
      prompt = "#xh__jishan-invoke::" .. target.id,
    }) then
      event:setCostData(self, { tos = { target } })
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    data:preventDamage()

    room:loseHp(player, 2, jishan.name)

    if not target.dead then
      target:drawCards(1, jishan.name)
    end
    if not player.dead then
      player:drawCards(1, jishan.name)
    end
  end,
})

return jishan