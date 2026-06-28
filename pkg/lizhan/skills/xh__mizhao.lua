local mizhao = fk.CreateSkill{
  name = "xh__mizhao",
}

Fk:loadTranslationTable{
  ["xh__mizhao"] = "密诏",
  [":xh__mizhao"] = "出牌阶段限一次，你可以与对手拼点，拼点赢的角色视为对拼点没赢的角色使用一张无距离和次数限制的普通【杀】。",
  ["#xh__mizhao"] = "密诏：与一名角色拼点，胜者视为对败者使用无距离和次数限制的【杀】",

  ["$xh__mizhao1"] = "爱卿世受皇恩，堪此重任。",
  ["$xh__mizhao2"] = "此诏事关重大，切记小心行事。",
}

mizhao:addEffect("active", {
  anim_type = "control",
  prompt = "#xh__mizhao",
  card_num = 0,
  target_num = 1,
  card_filter = Util.FalseFunc,

  can_use = function(self, player)
    return player.phase == Player.Play and player:usedEffectTimes(self.name, Player.HistoryPhase) == 0
  end,

  target_filter = function(self, player, to_select, selected)
    if #selected > 0 then return false end
    if to_select == player then return false end
    return player:canPindian(to_select)
  end,

  on_use = function(self, room, effect)
    local player = effect.from
    local target = effect.tos[1]
    if player.dead or target.dead then return end

    local pindian = player:pindian({ target }, mizhao.name)
    local res = pindian and pindian.results and pindian.results[target]
    if not res or not res.winner then
      return
    end

    local winner = res.winner
    local loser = (winner == player) and target or player
    if winner.dead or loser.dead then return end

    room:useVirtualCard(
      "slash",
      nil,
      winner,
      loser,
      mizhao.name,
      true,
      { bypass_distances = true, bypass_times = true }
    )
  end,
})

return mizhao