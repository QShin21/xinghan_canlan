local tunjun = fk.CreateSkill{
  name = "xh__tunjun",
  tags = { Skill.Limited },
}

Fk:loadTranslationTable{
  ["xh__tunjun"] = "屯军",
  [":xh__tunjun"] = "限定技，出牌阶段，你可以亮出牌堆顶的3X张牌，然后依次使用其中的至多X张装备牌（X为你发动过技能“掠命”的次数且至多为4）。",

  ["#xh__tunjun"] = "屯军：亮出牌堆顶的3X张牌，依次使用其中至多X张装备牌",
  ["#xh__tunjun-use"] = "屯军：是否使用%arg？",

  ["$xh__tunjun1"] = "得封侯爵，屯军弘农。",
  ["$xh__tunjun2"] = "屯军弘农，养精蓄锐。",
}

local function getLuemingTimes(player)
  local n = player:usedSkillTimes("xh__lueming", Player.HistoryGame)
  if n == 0 then
    n = player:usedSkillTimes("lueming", Player.HistoryGame)
  end
  if n > 4 then n = 4 end
  return n
end

tunjun:addEffect("active", {
  anim_type = "support",
  prompt = function(self, player)
    local x = getLuemingTimes(player)
    return "#xh__tunjun:::" .. x
  end,
  card_num = 0,
  target_num = 0,
  card_filter = Util.FalseFunc,

  can_use = function(self, player)
    return player.phase == Player.Play and
      player:usedSkillTimes(tunjun.name, Player.HistoryGame) == 0 and
      getLuemingTimes(player) > 0
  end,

  on_use = function(self, room, effect)
    local player = effect.from
    local x = getLuemingTimes(player)
    if x <= 0 then return false end

    local ids = room:getNCards(3 * x)
    if not ids or #ids == 0 then return false end

    room:turnOverCardsFromDrawPile(player, ids, tunjun.name)
    room:delay(300)

    local used = 0
    for _, id in ipairs(ids) do
      if player.dead then break end
      if used >= x then break end

      local card = Fk:getCardById(id)
      if card and card.type == Card.TypeEquip and player:canUseTo(card, player) then
        if room:askToSkillInvoke(player, {
          skill_name = tunjun.name,
          prompt = "#xh__tunjun-use:::" .. card:toLogString(),
        }) then
          room:useCard{
            from = player,
            tos = { player },
            card = card,
          }
          used = used + 1
        end
      end
    end

    room:cleanProcessingArea(ids, tunjun.name)
  end,
})

return tunjun
