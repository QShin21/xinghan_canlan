local ziqu = fk.CreateSkill{
  name = "xh__ziqu",
  tags = { Skill.Limited },
}

Fk:loadTranslationTable{
  ["xh__ziqu"] = "资取",
  [":xh__ziqu"] = "限定技，当你对对手造成伤害时，你可以防止此伤害，令其展示所有手牌并交给你一张点数最大的牌，然后你回复1点体力或摸两张牌。",

  ["#xh__ziqu-invoke"] = "资取：是否防止对 %dest 造成的伤害，改为令其展示所有手牌并交给你一张点数最大的牌？",
  ["#xh__ziqu-target"] = "资取：选择目标，防止你对其造成的伤害，改为令其展示所有手牌并交给你一张点数最大的牌",
  ["#xh__ziqu-give"] = "资取：你需交给 %src 一张点数最大的手牌",
  ["#xh__ziqu-choose"] = "资取：请选择回复1点体力或摸两张牌",
  ["xh__ziqu_recover"] = "回复1点体力",
  ["xh__ziqu_draw"] = "摸两张牌",

  ["$xh__ziqu1"] = "兵马已动，尔等速将粮草缴来。",
  ["$xh__ziqu2"] = "留财不留命，留命不留财。",
}

ziqu:addEffect(fk.DetermineDamageCaused, {
  anim_type = "control",

  can_trigger = function(self, event, target, player, data)
    if target ~= player then return false end
    if not player:hasSkill(ziqu.name) then return false end
    if player:usedSkillTimes(ziqu.name, Player.HistoryGame) > 0 then return false end
    if not data or not data.to or data.to == player then return false end
    if data.damage <= 0 then return false end
    return true
  end,

  on_cost = function(self, event, target, player, data)
    local room = player.room
    local tos = room:askToChoosePlayers(player, {
      targets = { data.to },
      min_num = 1,
      max_num = 1,
      prompt = "#xh__ziqu-target",
      skill_name = ziqu.name,
      cancelable = true,
    })
    if #tos > 0 then
      event:setCostData(self, { tos = tos })
      return true
    end
  end,

  on_use = function(self, event, target, player, data)
    local room = player.room
    local to = data.to
    local skillName = ziqu.name

    -- 防止伤害
    data:preventDamage()

    if to.dead then return end

    local handcards = to:getCardIds("h")
    if handcards and #handcards > 0 then
      room:showCards(handcards, to)

      local max_num = -1
      for _, id in ipairs(handcards) do
        local c = Fk:getCardById(id)
        if c.number > max_num then
          max_num = c.number
        end
      end

      local candidates = {}
      for _, id in ipairs(handcards) do
        local c = Fk:getCardById(id)
        if c.number == max_num then
          table.insert(candidates, id)
        end
      end

      local give_ids
      if #candidates == 1 then
        give_ids = { candidates[1] }
      else
        give_ids = room:askToCards(to, {
          min_num = 1,
          max_num = 1,
          include_equip = false,
          skill_name = skillName,
          pattern = tostring(Exppattern{ id = candidates }),
          prompt = "#xh__ziqu-give:" .. player.id,
          cancelable = false,
        })
      end

      if give_ids and #give_ids > 0 and not player.dead then
        room:obtainCard(player, give_ids, true, fk.ReasonGive, to, skillName)
      end
    else
      -- 没有手牌也视为展示为空即可，不强制调用 showCards
    end

    if player.dead then return end

    local choice = room:askToChoice(player, {
      choices = { "xh__ziqu_recover", "xh__ziqu_draw" },
      skill_name = skillName,
      prompt = "#xh__ziqu-choose",
    })

    if choice == "xh__ziqu_recover" then
      player:recover(1, skillName)
    else
      player:drawCards(2, skillName)
    end
  end,
})

return ziqu
