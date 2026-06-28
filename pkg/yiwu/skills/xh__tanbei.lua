local tanbei = fk.CreateSkill {
  name = "xh__tanbei",
}

Fk:loadTranslationTable{
  ["xh__tanbei"] = "贪狈",
  [":xh__tanbei"] = "出牌阶段限一次，你可以令一名其他角色选择一项：1.其交给你一张手牌，你此阶段不能再对其使用牌；2.令你此阶段对其使用牌无距离和次数限制。",

  ["#xh__tanbei"] = "贪狈：令一名角色选择交给你一张手牌，或令你此阶段对其使用牌无距离和次数限制",
  ["xh__tanbei1"] = "%src获得你一张手牌，此阶段不能再对你使用牌",
  ["xh__tanbei2"] = "%src此阶段对你使用牌无距离和次数限制",
  ["#xh__tanbei-give"] = "贪狈：交给 %src 一张手牌",
  ["@@xh__tanbei-phase"] = "贪狈",

  ["$xh__tanbei1"] = "此机，我怎么会错失！",
  ["$xh__tanbei2"] = "你的东西，现在是我的了！",
}

tanbei:addEffect("active", {
  anim_type = "offensive",
  prompt = "#xh__tanbei",
  card_num = 0,
  target_num = 1,
  max_phase_use_time = 1,
  can_use = function(self, player)
    return player.phase == Player.Play and player:usedSkillTimes(tanbei.name, Player.HistoryPhase) == 0
  end,
  card_filter = Util.FalseFunc,
  target_filter = function(self, player, to_select, selected)
    return #selected == 0 and to_select ~= player
  end,
  on_use = function(self, room, effect)
    local player = effect.from
    local target = effect.tos[1]
    if not target or target.dead then return end

    local choices = { "xh__tanbei2:" .. player.id }
    if not target:isKongcheng() then
      table.insert(choices, 1, "xh__tanbei1:" .. player.id)
    end

    local choice = room:askToChoice(target, {
      choices = choices,
      skill_name = tanbei.name,
    })

    if choice:startsWith("xh__tanbei1") then
      room:addTableMark(player, "xh__tanbei_forbid-phase", target.id)
      local give = room:askToCards(target, {
        min_num = 1,
        max_num = 1,
        include_equip = false,
        skill_name = tanbei.name,
        prompt = "#xh__tanbei-give:" .. player.id,
        cancelable = false,
      })
      if #give > 0 then
        room:obtainCard(player, give[1], false, fk.ReasonGive, target, tanbei.name)
      end
    else
      room:addTableMark(player, "xh__tanbei_free-phase", target.id)
      room:setPlayerMark(target, "@@xh__tanbei-phase", 1)
    end
  end,
})

tanbei:addEffect("prohibit", {
  is_prohibited = function(self, from, to, card)
    return from and to and from.phase == Player.Play and
      table.contains(from:getTableMark("xh__tanbei_forbid-phase"), to.id)
  end,
})

tanbei:addEffect("targetmod", {
  bypass_times = function(self, player, skill, scope, card, to)
    return card and to and player.phase == Player.Play and
      table.contains(player:getTableMark("xh__tanbei_free-phase"), to.id)
  end,
  bypass_distances = function(self, player, skill, card, to)
    return card and to and player.phase == Player.Play and
      table.contains(player:getTableMark("xh__tanbei_free-phase"), to.id)
  end,
})

return tanbei