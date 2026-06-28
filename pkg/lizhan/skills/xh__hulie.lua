local hulie = fk.CreateSkill{
  name = "xh__hulie",
  max_branches_use_time = {
    ["slash"] = {
      [Player.HistoryTurn] = 1
    },
    ["duel"] = {
      [Player.HistoryTurn] = 1
    },
  }
}

Fk:loadTranslationTable{
  ["xh__hulie"] = "虎烈",
  [":xh__hulie"] = "每回合各限一次，你使用【杀】或【决斗】仅指定一名角色为目标后，你可令此牌伤害+1。此牌结算后，若其体力值小于你，其视为对你使用一张【杀】。",

  ["#xh__hulie-invoke"] = "虎烈：是否令此%arg伤害+1？",

  ["$xh__hulie1"] = "匹夫犯我，吾必斩之。",
  ["$xh__hulie2"] = "鼠辈，这一刀下去定让你看不到明天的太阳。",
}

hulie:addEffect(fk.TargetSpecified, {
  anim_type = "offensive",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(hulie.name) and
      (data.card.trueName == "slash" or data.card.trueName == "duel") and
      data:isOnlyTarget(data.to) and hulie:withinBranchTimesLimit(player, data.card.trueName)
  end,
  on_cost = function(self, event, target, player, data)
    if player.room:askToSkillInvoke(player, {
      skill_name = hulie.name,
      prompt = "#xh__hulie-invoke:::" .. data.card:toLogString(),
    }) then
      event:setCostData(self, { history_branch = data.card.trueName })
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    data.extra_data = data.extra_data or {}
    data.extra_data.hulie = player
    data.additionalDamage = (data.additionalDamage or 0) + 1
  end,
}, { check_skill_limit = true })

hulie:addEffect(fk.CardUseFinished, {
  anim_type = "masochism",
  is_delay_effect = true,
  can_trigger = function(self, event, target, player, data)
    if target ~= player then return false end
    if player.dead then return false end
    if not (data.extra_data and data.extra_data.hulie == player) then return false end

    return table.find(data.tos, function(p)
      return not p.dead and p ~= player and p.hp < player.hp and
        p:canUseTo(Fk:cloneCard("slash"), player, { bypass_distances = true, bypass_times = true })
    end)
  end,

  on_trigger = function(self, event, target, player, data)
    local targets = table.filter(data.tos, function(p)
      return not p.dead and p ~= player and p.hp < player.hp and
        p:canUseTo(Fk:cloneCard("slash"), player, { bypass_distances = true, bypass_times = true })
    end)

    if #targets == 0 then return end
    player.room:sortByAction(targets)

    for _, p in ipairs(targets) do
      if player.dead then break end
      if not p.dead and p.hp < player.hp and
        p:canUseTo(Fk:cloneCard("slash"), player, { bypass_distances = true, bypass_times = true }) then
        event:setCostData(self, { extra_data = p })
        self:doCost(event, player, player, data)
      end
    end
  end,

  on_cost = function(self, event, target, player, data)
    return true
  end,

  on_use = function(self, event, target, player, data)
    local from = event:getCostData(self).extra_data
    if not from or from.dead or player.dead then return end
    if from.hp >= player.hp then return end
    player.room:useVirtualCard("slash", nil, from, player, hulie.name, true)
  end,
})

return hulie