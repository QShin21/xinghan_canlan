local yiji = fk.CreateSkill{
  name = "xh__yiji",
}

local function giveHandCards(player, n)
  local room = player.room
  local targets = room:getOtherPlayers(player, false)
  if player.dead or player:isKongcheng() or #targets == 0 then return end

  room:askToYiji(player, {
    cards = player:getCardIds("h"),
    targets = targets,
    skill_name = yiji.name,
    min_num = 0,
    max_num = math.min(n, player:getHandcardNum()),
    prompt = "#xh__yiji-give:::" .. n,
  })
end

Fk:loadTranslationTable{
  ["xh__yiji"] = "遗计",
  [":xh__yiji"] = "当你受到伤害后，你可以摸两张牌，然后可以将至多两张手牌交给其他角色。当你每轮首次进入濒死状态时，你可以摸一张牌，然后可以将一张手牌交给其他角色。",

  ["#xh__yiji-damaged"] = "遗计：你可以摸两张牌，然后可以将至多两张手牌交给其他角色",
  ["#xh__yiji-dying"] = "遗计：你可以摸一张牌，然后可以将一张手牌交给其他角色",
  ["#xh__yiji-give"] = "遗计：你可以将至多 %arg 张手牌交给其他角色",

  ["$xh__yiji1"] = "身不能征伐，此计或可襄君太平！",
  ["$xh__yiji2"] = "此身赴黄泉，望明公见计如晤。",
}

yiji:addEffect(fk.Damaged, {
  anim_type = "masochism",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(yiji.name)
  end,
  on_cost = function(self, event, target, player, data)
    return player.room:askToSkillInvoke(player, {
      skill_name = yiji.name,
      prompt = "#xh__yiji-damaged",
    })
  end,
  on_use = function(self, event, target, player, data)
    player:drawCards(2, yiji.name)
    giveHandCards(player, 2)
  end,
})

yiji:addEffect(fk.EnterDying, {
  anim_type = "masochism",
  can_trigger = function(self, event, target, player, data)
    if target ~= player or not player:hasSkill(yiji.name) then return false end

    local room = player.room
    local dying_event = room.logic:getCurrentEvent():findParent(GameEvent.Dying, true)
    if dying_event == nil then return false end

    local mark = player:getMark("xh__yiji-round")
    if mark == 0 then
      room.logic:getEventsOfScope(GameEvent.Dying, 1, function(e)
        local dying = e.data
        if dying.who == player then
          mark = e.id
          room:setPlayerMark(player, "xh__yiji-round", mark)
          return true
        end
      end, Player.HistoryRound)
    end

    return mark == dying_event.id
  end,
  on_cost = function(self, event, target, player, data)
    return player.room:askToSkillInvoke(player, {
      skill_name = yiji.name,
      prompt = "#xh__yiji-dying",
    })
  end,
  on_use = function(self, event, target, player, data)
    player:drawCards(1, yiji.name)
    giveHandCards(player, 1)
  end,
})

return yiji
