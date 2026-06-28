local jutu = fk.CreateSkill {
  name = "xh__jutu",
  derived_piles = "liuzhang_sheng",
  tags = { Skill.Compulsory },
}

Fk:loadTranslationTable{
  ["xh__jutu"] = "据土",
  [":xh__jutu"] = "锁定技，准备阶段，你获得所有你武将牌上的“生”，然后摸一张牌，然后将X张牌置于你的武将牌上，称之为“生”（X为你“邀虎”选择势力的角色数量）。",

  ["liuzhang_sheng"] = "生",
  ["#xh__jutu-put"] = "据土：请将%arg张牌置为“生”",

  ["$xh__jutu1"] = "百姓安乐足矣，穷兵黩武实不可取啊。",
  ["$xh__jutu2"] = "内乱初定，更应休养生息。",
}

jutu:addEffect(fk.EventPhaseStart, {
  anim_type = "drawcard",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(jutu.name) and player.phase == Player.Start
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    if #player:getPile("liuzhang_sheng") > 0 then
      room:obtainCard(player, player:getPile("liuzhang_sheng"), false, fk.ReasonJustMove, player, jutu.name)
    end

    if player.dead then return end
    player:drawCards(1, jutu.name)

    local n = #table.filter(room.alive_players, function(p)
      return p.kingdom == player:getMark("@xh__yaohu")
    end)

    if n > 0 and not player.dead and not player:isNude() then
      local cards = player:getCardIds("he")
      if #cards > n then
        cards = room:askToCards(player, {
          min_num = n,
          max_num = n,
          include_equip = true,
          skill_name = jutu.name,
          prompt = "#xh__jutu-put:::" .. n,
          cancelable = false,
        })
      end
      player:addToPile("liuzhang_sheng", cards, true, jutu.name)
    end
  end,
})

return jutu
