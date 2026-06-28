local tianming = fk.CreateSkill{
  name = "xh__tianming",
}

Fk:loadTranslationTable{
  ["xh__tianming"] = "天命",
  [":xh__tianming"] = "当你成为【杀】的目标后，你可以弃置两张牌（不足则全弃），然后摸两张牌。",
  ["#xh__tianming-invoke"] = "天命：你可以弃置两张牌（不足则全弃），然后摸两张牌",
}

tianming:addEffect(fk.TargetConfirmed, {
  anim_type = "defensive",
  can_trigger = function(self, event, target, player, data)
    return target == player
      and player:hasSkill(tianming.name)
      and data.card
      and data.card.trueName == "slash"
  end,

  on_cost = function(self, event, target, player, data)
    return player.room:askToSkillInvoke(player, {
      skill_name = tianming.name,
      prompt = "#xh__tianming-invoke",
    })
  end,

  on_use = function(self, event, target, player, data)
    local room = player.room

    local all = player:getCardIds("he")
    local n = math.min(2, #all)

    if n > 0 then
      room:askToDiscard(player, {
        min_num = n,
        max_num = n,
        include_equip = true,
        skill_name = tianming.name,
        prompt = "#xh__tianming-invoke",
        cancelable = false,
      })
    end

    if not player.dead then
      player:drawCards(2, tianming.name)
    end
  end,
})

return tianming