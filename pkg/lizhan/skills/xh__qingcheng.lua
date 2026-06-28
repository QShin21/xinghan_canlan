local qingcheng = fk.CreateSkill {
  name = "xh__qingcheng",
}

Fk:loadTranslationTable{
  ["xh__qingcheng"] = "倾城",
  [":xh__qingcheng"] = "出牌阶段限一次，你可以与一名手牌数不大于你的角色交换手牌。",

  ["#xh__qingcheng"] = "倾城：与一名手牌数不大于你的角色交换手牌",

  ["$xh__qingcheng1"] = "我和你们真是投缘呐。",
  ["$xh__qingcheng2"] = "哼，眼睛都都直了呀。",
}

qingcheng:addEffect("active", {
  anim_type = "control",
  prompt = "#xh__qingcheng",
  target_num = 1,
  card_num = 0,
  can_use = function(self, player)
    return player:usedSkillTimes(qingcheng.name, Player.HistoryPhase) == 0 and not player:isKongcheng()
  end,
  card_filter = Util.FalseFunc,
  target_filter = function(self, player, to_select, selected)
    return #selected == 0 and to_select ~= player and player:getHandcardNum() >= to_select:getHandcardNum()
  end,
  on_use = function(self, room, effect)
    local player = effect.from
    local target = effect.tos[1]
    room:swapAllCards(player, {player, target}, qingcheng.name)
  end,
})

return qingcheng