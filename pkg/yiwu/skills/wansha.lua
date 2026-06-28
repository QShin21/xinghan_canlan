local wansha = fk.CreateSkill {
  name = "wzzz__wansha",
  tags = { Skill.Compulsory },
}

Fk:loadTranslationTable {
  ["wzzz__wansha"] = "完杀",
  [":wzzz__wansha"] = "锁定技，当其他角色于你的回合内进入濒死状态时，你令其死亡。",

  ["$wzzz__wansha1"] = "有谁敢试试？",
  ["$wzzz__wansha2"] = "斩草务尽，以绝后患。",
}

wansha:addEffect(fk.EnterDying, {
  anim_type = "offensive",
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(wansha.name) and target ~= player and player.room.current == player
  end,
  on_cost = function (self, event, target, player, data)
    event:setCostData(self, { tos = {target} })
    return true
  end,
  on_use = function(self, event, target, player, data)
    player.room:killPlayer({
      who = target,
      killer = player,
    })
  end,
})

return wansha