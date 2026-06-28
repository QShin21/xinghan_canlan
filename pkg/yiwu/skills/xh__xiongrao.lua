local xiongrao = fk.CreateSkill{
  name = "xh__xiongrao",
  tags = { Skill.Limited },
}

Fk:loadTranslationTable{
  ["xh__xiongrao"] = "熊扰",
  [":xh__xiongrao"] = "限定技，准备阶段，你可以令所有其他角色本回合除锁定技、限定技、觉醒技以外的技能均失效，然后你加体力上限至4点并摸等同于加体力上限数量的牌。",

  ["#xh__xiongrao-invoke"] = "熊扰：你可以令其他角色本回合非锁定技无效，并将你的体力上限加至4点",
  ["@@xh__xiongrao-turn"] = "熊扰",

  ["$xh__xiongrao1"] = "势如熊罴，威震四海！",
  ["$xh__xiongrao2"] = "啸聚熊虎，免走狐惊！",
}

xiongrao:addEffect(fk.EventPhaseStart, {
  anim_type = "offensive",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(xiongrao.name) and player.phase == Player.Start and
      player:usedSkillTimes(xiongrao.name, Player.HistoryGame) == 0 and
      #player.room:getOtherPlayers(player, false) > 0
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    if room:askToSkillInvoke(player, {
      skill_name = xiongrao.name,
      prompt = "#xh__xiongrao-invoke",
    }) then
      event:setCostData(self, {tos = room:getOtherPlayers(player)})
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room

    for _, p in ipairs(room:getOtherPlayers(player, false)) do
      room:setPlayerMark(p, "@@xh__xiongrao-turn", 1)
    end

    local x = 4 - player.maxHp
    if x > 0 then
      room:changeMaxHp(player, x)
      if not player.dead then
        player:drawCards(x, xiongrao.name)
      end
    end
  end,
})

xiongrao:addEffect("invalidity", {
  invalidity_func = function(self, from, skill)
    return from:getMark("@@xh__xiongrao-turn") > 0 and
      not table.find({Skill.Compulsory, Skill.Limited, Skill.Wake}, function(tag)
        return skill:hasTag(tag)
      end) and
      skill:isPlayerSkill(from)
  end
})

return xiongrao