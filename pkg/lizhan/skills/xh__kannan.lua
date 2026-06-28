local kannan = fk.CreateSkill {
  name = "xh__kannan",
}

Fk:loadTranslationTable{
  ["xh__kannan"] = "戡难",
  [":xh__kannan"] = "出牌阶段限一次，你可与一名其他角色拼点，若你赢，你使用的下一张【杀】的伤害值基数+1；若其赢，其使用的下一张【杀】的伤害值基数+1。",
  ["#xh__kannan"] = "戡难：与一名角色拼点，赢的角色使用下一张【杀】伤害+1",
  ["@xh__kannan"] = "戡难",
  ["$xh__kannan1"] = "俊才之杰，材匪戡难。",
  ["$xh__kannan2"] = "戡，克也，难，攻之。",
}

kannan:addEffect("active", {
  anim_type = "control",
  prompt = "#xh__kannan",
  card_num = 0,
  target_num = 1,

  max_phase_use_time = 1,
  can_use = function(self, player)
    return player.phase == Player.Play and
      player:usedSkillTimes(kannan.name, Player.HistoryPhase) == 0
  end,

  card_filter = Util.FalseFunc,
  target_filter = function(self, player, to_select, selected)
    return #selected == 0 and player:canPindian(to_select)
  end,

  on_use = function(self, room, effect)
    local player = effect.from
    local target = effect.tos[1]
    local pindian = player:pindian({target}, kannan.name)

    if pindian.results[target].winner == player then
      if not player.dead then
        room:addPlayerMark(player, "@xh__kannan", 1)
      end
    elseif pindian.results[target].winner == target then
      if not target.dead then
        room:addPlayerMark(target, "@xh__kannan", 1)
      end
    end
  end,
})

kannan:addEffect(fk.PreCardUse, {
  can_refresh = function(self, event, target, player, data)
    return target == player and player:getMark("@xh__kannan") > 0 and data.card.trueName == "slash"
  end,
  on_refresh = function(self, event, target, player, data)
    data.additionalDamage = (data.additionalDamage or 0) + player:getMark("@xh__kannan")
    player.room:setPlayerMark(player, "@xh__kannan", 0)
  end,
})

return kannan
