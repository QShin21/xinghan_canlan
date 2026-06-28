local qingzheng = fk.CreateSkill {
  name = "ofl__qingzheng",
}

Fk:loadTranslationTable{
  ["ofl__qingzheng"] = "清正",
  [":ofl__qingzheng"] = "出牌阶段开始时，你可以展示所有手牌，弃置其中一种花色的牌，然后展示一名其他角色的所有手牌并弃置其中一种花色的牌，" ..
  "若你以此法弃置的牌数大于其弃置的牌数，你对其造成1点伤害。",

  ["#ofl__qingzheng-choice"] = "清正：弃置一种花色的手牌",
  ["#ofl__qingzheng-choose"] = "清正：选择一名其他角色，展示其手牌并弃置其中一种花色",
  ["#ofl__qingzheng-discard"] = "清正：弃置 %dest 一种花色的手牌，若弃置张数小于%arg，对其造成伤害",
}

qingzheng:addEffect(fk.EventPhaseStart, {
  anim_type = "control",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(qingzheng.name) and player.phase == Player.Play and
      not player:isKongcheng()
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    player:showCards(player:getCardIds("h"))
    if player.dead then return end
    local all_choices = {"log_spade", "log_club", "log_heart", "log_diamond"}
    local choices = table.filter(all_choices, function (suit)
      return table.find(player:getCardIds("h"), function (id)
        return Fk:getCardById(id):getSuitString(true) == suit and not player:prohibitDiscard(id)
      end) ~= nil
    end)
    if #choices == 0 then return end
    local choice = room:askToChoice(player, {
      choices = choices,
      skill_name = qingzheng.name,
      prompt = "#ofl__qingzheng-choice",
      all_choices = all_choices,
    })
    local cards1 = table.filter(player:getCardIds("h"), function (id)
      return Fk:getCardById(id):getSuitString(true) == choice and not player:prohibitDiscard(id)
    end)
    room:throwCard(cards1, qingzheng.name, player, player)
    if player.dead then return end

    local targets = table.filter(room:getOtherPlayers(player, false), function (p)
      return not p:isKongcheng()
    end)
    if #targets == 0 then return end
    local to = room:askToChoosePlayers(player, {
      min_num = 1,
      max_num = 1,
      targets = targets,
      skill_name = qingzheng.name,
      prompt = "#ofl__qingzheng-choose",
      cancelable = false,
    })[1]
    to:showCards(to:getCardIds("h"))
    if to.dead or player.dead or to:isKongcheng() then return end
    choices = table.filter(all_choices, function (suit)
      return table.find(to:getCardIds("h"), function (id)
        return Fk:getCardById(id):getSuitString(true) == suit
      end) ~= nil
    end)
    if #choices == 0 then return end
    choice = room:askToChoice(player, {
      choices = choices,
      skill_name = qingzheng.name,
      prompt = "#ofl__qingzheng-discard::"..to.id..":"..#cards1,
      all_choices = all_choices,
    })
    local cards2 = table.filter(to:getCardIds("h"), function (id)
      return Fk:getCardById(id):getSuitString(true) == choice
    end)
    room:throwCard(cards2, qingzheng.name, to, player)

    if #cards1 > #cards2 and not to.dead then
      room:doIndicate(player, {to})
      room:damage{
        from = player,
        to = to,
        damage = 1,
        skillName = qingzheng.name,
      }
    end
  end,
})

return qingzheng
