local shicai = fk.CreateSkill{
  name = "xh__shicai",
  tags = { Skill.Compulsory },
}

Fk:loadTranslationTable {
  ["xh__shicai"] = "恃才",
  [":xh__shicai"] = "锁定技，当你受到伤害后，若此伤害值为1，则你摸两张牌；大于1，则你弃置所有的手牌。",

  ["$xh__shicai1"] = "吾才满腹，袁本初竟不从之。",
  ["$xh__shicai2"] = "阿瞒有我良计，取冀州便是易如反掌。",
}

shicai:addEffect(fk.Damaged, {
  mute = true,
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(shicai.name)
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    player:broadcastSkillInvoke(shicai.name)
    if data.damage == 1 then
      room:notifySkillInvoked(player, shicai.name, "masochism")
      player:drawCards(2, shicai.name)
    else
      room:notifySkillInvoked(player, shicai.name, "negative")
      player:throwAllCards("h", shicai.name)
    end
  end,
})

return shicai
