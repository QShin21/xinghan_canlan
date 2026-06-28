local yisuan = fk.CreateSkill{
  name = "xh__yisuan",
}

Fk:loadTranslationTable{
  ["xh__yisuan"] = "亦算",
  [":xh__yisuan"] = "出牌阶段限一次，当你使用的普通锦囊牌结算结束后，你可以失去1点体力或减1点体力上限，然后获得此牌。",

  ["#xh__yisuan-invoke"] = "亦算：是否付出代价获得%arg？",
  ["#xh__yisuan-choice"] = "亦算：选择代价",
  ["$xh__yisuan1"] = "吾亦能善算谋划。",
  ["$xh__yisuan2"] = "算计人心，我也可略施一二。",
}

yisuan:addEffect(fk.CardUseFinished, {
  anim_type = "drawcard",
  can_trigger = function(self, event, target, player, data)
    if target ~= player then return false end
    if not player:hasSkill(yisuan.name) then return false end
    if player.phase ~= Player.Play then return false end
    if player:usedSkillTimes(yisuan.name, Player.HistoryPhase) > 0 then return false end
    if not data.card or not data.card:isCommonTrick() then return false end
    return player.room:getCardArea(data.card) == Card.Processing
  end,

  on_cost = function(self, event, target, player, data)
    local room = player.room
    if room:askToSkillInvoke(player, {
      skill_name = yisuan.name,
      prompt = "#xh__yisuan-invoke:::" .. data.card:toLogString(),
    }) then
      local choice = room:askToChoice(player, {
        choices = { "loseHp", "loseMaxHp" },
        skill_name = yisuan.name,
        prompt = "#xh__yisuan-choice",
      })
      event:setCostData(self, { choice = choice })
      return true
    end
  end,

  on_use = function(self, event, target, player, data)
    local room = player.room
    local cost = event:getCostData(self) or {}
    local choice = cost.choice
    if choice == "loseMaxHp" then
      room:changeMaxHp(player, -1)
    else
      room:loseHp(player, 1, yisuan.name)
    end
    if player.dead then return end

    if room:getCardArea(data.card) == Card.Processing then
      room:obtainCard(player, data.card, true, fk.ReasonJustMove, player, yisuan.name)
    end
  end,
})

return yisuan
