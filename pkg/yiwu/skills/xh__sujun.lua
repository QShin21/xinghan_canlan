local sujun = fk.CreateSkill {
  name = "xh__sujun",
}

Fk:loadTranslationTable{
  ["xh__sujun"] = "肃军",
  [":xh__sujun"] = "出牌阶段限一次，当你使用牌时，你可以展示所有手牌（无牌则跳过），若你的手牌中基本牌与非基本牌的数量相等，你摸两张牌。",
  ["#xh__sujun-invoke"] = "肃军：展示所有手牌，若基本牌与非基本牌数量相等则摸两张牌",

  ["$xh__sujun1"] = "将为军魂，需以身作则。",
  ["$xh__sujun2"] = "整肃三军，可育虎贲。",
}

sujun:addEffect(fk.CardUsing, {
  anim_type = "drawcard",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(sujun.name) and
      player.phase == Player.Play and
      player:usedSkillTimes(sujun.name, Player.HistoryPhase) == 0
  end,
  on_cost = function(self, event, target, player, data)
    return player.room:askToSkillInvoke(player, {
      skill_name = sujun.name,
      prompt = "#xh__sujun-invoke",
    })
  end,
  on_use = function(self, event, target, player, data)
    local handcards = player:getCardIds("h")
    if #handcards > 0 then
      player:showCards(handcards)
    end
    local basic = #table.filter(player:getCardIds("h"), function(id)
      return Fk:getCardById(id).type == Card.TypeBasic
    end)
    if not player.dead and 2 * basic == player:getHandcardNum() then
      player:drawCards(2, sujun.name)
    end
  end,
})

return sujun
