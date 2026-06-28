local mingce = fk.CreateSkill{
  name = "xh__mingce",
}

Fk:loadTranslationTable{
  ["xh__mingce"] = "明策",
  [":xh__mingce"] = "出牌阶段限一次，你可以交给一名其他角色一张牌，令其选择一项：1.摸一张牌，并令你摸两张牌；2.失去1点体力。",
  ["#xh__mingce"] = "明策：交给一名角色一张牌，其选择摸一张牌并令你摸两张牌，或失去1点体力",

  ["xh__mingce_draw"] = "摸一张牌，并令%src摸两张牌",
  ["xh__mingce_losehp"] = "失去1点体力",

  ["$xh__mingce1"] = "行吾此计，可使局势转危为安。",
  ["$xh__mingce2"] = "分策而动，彼自乱阵脚。",
}

mingce:addEffect("active", {
  anim_type = "support",
  prompt = "#xh__mingce",
  card_num = 1,
  target_num = 1,

  can_use = function(self, player)
    return player.phase == Player.Play
      and player:usedEffectTimes(self.name, Player.HistoryPhase) == 0
      and not player:isNude()
  end,

  card_filter = function(self, player, to_select, selected)
    if #selected > 0 then return false end
    return table.contains(player:getCardIds("he"), to_select)
  end,

  target_filter = function(self, player, to_select, selected)
    return #selected == 0 and to_select ~= player
  end,

  on_use = function(self, room, effect)
    local player = effect.from
    local target = effect.tos[1]
    local cid = effect.cards[1]
    local skillName = mingce.name

    room:obtainCard(target, cid, false, fk.ReasonGive, player, skillName)
    if player.dead or target.dead then return end

    local choice = room:askToChoice(target, {
      choices = { "xh__mingce_draw:" .. player.id, "xh__mingce_losehp" },
      skill_name = skillName,
    })

    if choice:startsWith("xh__mingce_draw") then
      target:drawCards(1, skillName)
      if not player.dead then
        player:drawCards(2, skillName)
      end
      room:addPlayerMark(target, "xh__mingce_draw", 1)
    else
      room:loseHp(target, 1, skillName)
    end
  end,
})

return mingce
