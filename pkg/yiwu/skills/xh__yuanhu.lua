local yuanhu = fk.CreateSkill {
  name = "xh__yuanhu",
}

Fk:loadTranslationTable{
  ["xh__yuanhu"] = "援护",
  [":xh__yuanhu"] = "出牌阶段限一次，你可以将一张装备牌置入一名角色的装备区里，然后若此牌为：武器牌，你弃置其距离为1的另一名角色区域里的至多两张牌；防具牌，其摸两张牌；坐骑牌，其回复1点体力。",

  ["xh__yuanhu_active"] = "援护",
  ["#xh__yuanhu-put"] = "援护：将一张装备牌置入一名角色的装备区",
  ["#xh__yuanhu-throw"] = "援护：选择一名距离 %dest 为1的角色，弃置其区域里至多两张牌",

  ["$xh__yuanhu1"] = "若无趁手兵器，不妨试试我这把！",
  ["$xh__yuanhu2"] = "此乃良驹，愿助将军日行千里！",
  ["$xh__yuanhu3"] = "将军，这件防具可还合身？",
}

yuanhu:addEffect("active", {
  anim_type = "support",
  prompt = "#xh__yuanhu-put",
  mute = true,
  card_num = 1,
  target_num = 1,
  can_use = function(self, player)
    return player:usedSkillTimes(yuanhu.name, Player.HistoryPhase) == 0
  end,
  card_filter = function(self, player, to_select, selected)
    if #selected > 0 then return false end
    local card = Fk:getCardById(to_select)
    return card.type == Card.TypeEquip
  end,
  target_filter = function(self, player, to_select, selected, selected_cards)
    if #selected > 0 or #selected_cards == 0 then return false end
    local card = Fk:getCardById(selected_cards[1])
    return not to_select:getEquipment(card.sub_type)
  end,
  on_use = function(self, room, effect)
    local player = effect.from
    local target = effect.tos[1]
    local card = Fk:getCardById(effect.cards[1])

    room:notifySkillInvoked(player, yuanhu.name, "support", { target })
    room:moveCardTo(effect.cards, Card.PlayerEquip, target, fk.ReasonPut, yuanhu.name, nil, true, player)
    room:delay(600)

    if target.dead then return end

    if card.sub_type == Card.SubtypeWeapon then
      player:broadcastSkillInvoke(yuanhu.name, 1)
      local targets = table.filter(room.alive_players, function(p)
        return p ~= target and p:distanceTo(target) == 1 and not p:isAllNude()
      end)
      if #targets == 0 then return end

      local to = room:askToChoosePlayers(player, {
        targets = targets,
        min_num = 1,
        max_num = 1,
        prompt = "#xh__yuanhu-throw::" .. target.id,
        skill_name = yuanhu.name,
        cancelable = false,
      })[1]

      for _ = 1, 2 do
        if to:isAllNude() then break end
        local cid = room:askToChooseCard(player, {
          target = to,
          flag = "hej",
          skill_name = yuanhu.name,
          cancelable = true,
        })
        if not cid then break end
        room:throwCard(cid, yuanhu.name, to, player)
      end
    elseif card.sub_type == Card.SubtypeArmor then
      player:broadcastSkillInvoke(yuanhu.name, 3)
      target:drawCards(2, yuanhu.name)
    elseif card.sub_type == Card.SubtypeOffensiveRide or card.sub_type == Card.SubtypeDefensiveRide then
      player:broadcastSkillInvoke(yuanhu.name, 2)
      if target:isWounded() then
        room:recover {
          num = 1,
          skillName = yuanhu.name,
          who = target,
          recoverBy = player,
        }
      end
    end
  end,
})

return yuanhu
