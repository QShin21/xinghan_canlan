local lueming = fk.CreateSkill {
  name = "xh__lueming",
}

Fk:loadTranslationTable{
  ["xh__lueming"] = "掠命",
  [":xh__lueming"] = "出牌阶段限一次，你可以令一名装备区的牌数小于你的其他角色声明一个点数，然后你进行判定，若判定结果的点数与其声明的相同，你对其造成2点伤害；不同，其交给你一张手牌。",

  ["#xh__lueming"] = "掠命：令一名角色声明点数并判定，相同则对其造成2点伤害，不同则其交给你一张手牌",
  ["#xh__lueming-give"] = "掠命：交给 %src 一张手牌",

  ["$xh__lueming1"] = "劫命掠财，毫不费力。",
  ["$xh__lueming2"] = "人财，皆掠之，哈哈！",
}

lueming:addEffect("active", {
  anim_type = "offensive",
  prompt = "#xh__lueming",
  card_num = 0,
  target_num = 1,
  max_phase_use_time = 1,
  can_use = function(self, player)
    return player.phase == Player.Play and player:usedSkillTimes(lueming.name, Player.HistoryPhase) == 0
  end,
  card_filter = Util.FalseFunc,
  target_filter = function(self, player, to_select, selected)
    return #selected == 0 and to_select ~= player and
      #to_select:getCardIds("e") < #player:getCardIds("e")
  end,
  on_use = function(self, room, effect)
    local player = effect.from
    local target = effect.tos[1]
    if not target or target.dead or player.dead then return end

    local choices = {}
    for i = 1, 13 do
      table.insert(choices, tostring(i))
    end

    local choice = room:askToChoice(target, {
      choices = choices,
      skill_name = lueming.name,
    })

    room:sendLog{
      type = "#Choice",
      from = target.id,
      arg = choice,
      toast = true,
    }

    local judge = {
      who = player,
      reason = lueming.name,
      pattern = ".",
    }
    room:judge(judge)

    if player.dead or target.dead then return end

    if tostring(judge.card.number) == choice then
      room:damage{
        from = player,
        to = target,
        damage = 2,
        skillName = lueming.name,
      }
    else
      if target:isKongcheng() then return end
      local give = room:askToCards(target, {
        min_num = 1,
        max_num = 1,
        include_equip = false,
        skill_name = lueming.name,
        prompt = "#xh__lueming-give:" .. player.id,
        cancelable = false,
      })
      if #give > 0 then
        room:moveCardTo(give, Card.PlayerHand, player, fk.ReasonGive, lueming.name, nil, false, target)
      end
    end
  end,
})

return lueming