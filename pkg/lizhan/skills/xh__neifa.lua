local neifa = fk.CreateSkill{
  name = "xh__neifa",
}

Fk:loadTranslationTable{
  ["xh__neifa"] = "内伐",
  [":xh__neifa"] = "出牌阶段开始时，你可以摸一张牌，然后弃置一张牌并选择一项：1.此阶段你不能使用锦囊牌且【杀】的使用次数+1；2.此阶段你不能使用基本牌，使用普通锦囊牌指定目标后你可以摸一张牌；3.此阶段你使用装备牌后，可以弃置对手一张牌。",

  ["#xh__neifa-invoke"] = "内伐：你可以摸一张牌并弃置一张牌，然后选择一项",
  ["#xh__neifa-discard"] = "内伐：请弃置一张牌",
  ["#xh__neifa-choose"] = "内伐：请选择一项",
  ["#xh__neifa-draw"] = "内伐：你可以摸一张牌",
  ["#xh__neifa-discardop"] = "内伐：你可以弃置一名其他角色的一张牌",

  ["xh__neifa_choice1"] = "此阶段不能使用锦囊牌，且【杀】的使用次数+1",
  ["xh__neifa_choice2"] = "此阶段不能使用基本牌，使用普通锦囊牌指定目标后可以摸一张牌",
  ["xh__neifa_choice3"] = "此阶段使用装备牌后，可以弃置对手一张牌",

  ["$xh__neifa1"] = "自相恩残，相煎何急。",
  ["$xh__neifa2"] = "同室内伐，贻笑外人。",
}

local CHOICE_MARK = "xh__neifa_choice-phase"

neifa:addEffect(fk.EventPhaseStart, {
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(neifa.name) and player.phase == Player.Play
  end,

  on_cost = function(self, event, target, player, data)
    return player.room:askToSkillInvoke(player, {
      skill_name = neifa.name,
      prompt = "#xh__neifa-invoke",
    })
  end,

  on_use = function(self, event, target, player, data)
    local room = player.room
    local skillName = neifa.name
    player:broadcastSkillInvoke(skillName)

    player:drawCards(1, skillName)
    if player.dead then return end

    local discards = room:askToDiscard(player, {
      min_num = 1,
      max_num = 1,
      include_equip = true,
      skill_name = skillName,
      prompt = "#xh__neifa-discard",
      cancelable = false,
      skip = true,
    })
    if discards and #discards > 0 then
      room:throwCard(discards, skillName, player, player)
    end
    if player.dead then return end

    local choice = room:askToChoice(player, {
      choices = { "xh__neifa_choice1", "xh__neifa_choice2", "xh__neifa_choice3" },
      skill_name = skillName,
      prompt = "#xh__neifa-choose",
    })

    local idx = 0
    if choice == "xh__neifa_choice1" then
      idx = 1
      room:addPlayerMark(player, MarkEnum.SlashResidue .. "-phase", 1)
    elseif choice == "xh__neifa_choice2" then
      idx = 2
    else
      idx = 3
    end

    room:setPlayerMark(player, CHOICE_MARK, idx)
  end,
})

neifa:addEffect("prohibit", {
  prohibit_use = function(self, player, card)
    if player.phase ~= Player.Play then return false end
    local c = player:getMark(CHOICE_MARK)
    if c == 1 then
      return card and card.type == Card.TypeTrick
    end
    if c == 2 then
      return card and card.type == Card.TypeBasic
    end
    return false
  end,
})

neifa:addEffect(fk.TargetSpecified, {
  anim_type = "drawcard",
  can_trigger = function(self, event, target, player, data)
    if target ~= player then return false end
    if player.phase ~= Player.Play then return false end
    if player:getMark(CHOICE_MARK) ~= 2 then return false end
    if not data or not data.card or not data.firstTarget then return false end
    if not data.card:isCommonTrick() then return false end
    return true
  end,

  on_cost = function(self, event, target, player, data)
    return player.room:askToSkillInvoke(player, {
      skill_name = neifa.name,
      prompt = "#xh__neifa-draw",
    })
  end,

  on_use = function(self, event, target, player, data)
    if not player.dead then
      player:drawCards(1, neifa.name)
    end
  end,
})

neifa:addEffect(fk.CardUseFinished, {
  anim_type = "control",
  can_trigger = function(self, event, target, player, data)
    if target ~= player then return false end
    if player.phase ~= Player.Play then return false end
    if player:getMark(CHOICE_MARK) ~= 3 then return false end
    if not data or not data.card then return false end
    if data.card.type ~= Card.TypeEquip then return false end

    local room = player.room
    for _, p in ipairs(room:getOtherPlayers(player, false)) do
      if not p:isNude() then
        return true
      end
    end
    return false
  end,

  on_cost = function(self, event, target, player, data)
    local room = player.room
    local targets = table.filter(room:getOtherPlayers(player, false), function(p)
      return not p:isNude()
    end)

    local tos = room:askToChoosePlayers(player, {
      targets = targets,
      min_num = 1,
      max_num = 1,
      prompt = "#xh__neifa-discardop",
      skill_name = neifa.name,
      cancelable = true,
    })

    if #tos > 0 then
      event:setCostData(self, tos[1])
      return true
    end
    return false
  end,

  on_use = function(self, event, target, player, data)
    local room = player.room
    local to = event:getCostData(self)
    if not to or to.dead or to:isNude() then return end

    local cid = room:askToChooseCard(player, {
      target = to,
      flag = "hej",
      skill_name = neifa.name,
    })
    if cid then
      room:throwCard(cid, neifa.name, to, player)
    end
  end,
})

neifa:addLoseEffect(function(self, player, is_death)
  player.room:setPlayerMark(player, CHOICE_MARK, 0)
end)

return neifa
