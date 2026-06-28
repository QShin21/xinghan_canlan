local zhongliu = fk.CreateSkill{
  name = "wzzz__zhongliu",
  tags = { Skill.Compulsory },
}

Fk:loadTranslationTable{
  ["wzzz__zhongliu"] = "中流",
  [":wzzz__zhongliu"] = "锁定技，当你使用牌时，若不为你的手牌，你视为未发动〖解悬〗。",

  ["$wzzz__zhongliu1"] = "天命如潮，中流汹涌，不可立川徒观之。",
  ["$wzzz__zhongliu2"] = "柱国之石，势遏浊汹，可立于中流。",
}

zhongliu:addEffect(fk.CardUsing, {
  anim_type = "special",
  can_trigger = function(self, event, target, player, data)
    if target == player and player:hasSkill(zhongliu.name) then
      if data.subcardsFromInfo == nil or #data.subcardsFromInfo == 0 then return true end
      for _, info in ipairs(data.subcardsFromInfo) do
        if info.fromArea == Card.PlayerHand and info.from == player then
          return false
        end
      end
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    player:setSkillUseHistory("wzzz__jiexuan", 0, Player.HistoryPhase)
  end,
})

return zhongliu
