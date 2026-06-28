local guidao = fk.CreateSkill({
  name = "xh__guidao",
})

Fk:loadTranslationTable{
  ["xh__guidao"] = "鬼道",
  [":xh__guidao"] = "当一名角色的判定牌生效前，你可以用一张黑色牌替换之。",

  ["#xh__guidao-ask"] = "鬼道：你可以用一张黑色牌替换 %dest 的“%arg”判定",

  ["$xh__guidao1"] = "天下大势，为我所控。",
  ["$xh__guidao2"] = "哼哼哼哼~",
}

guidao:addEffect(fk.AskForRetrial, {
  anim_type = "control",
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(guidao.name) and not player:isNude()
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    -- 获取所有黑色牌（包括手牌和装备区的牌）
    local allIds = table.connect(player:getHandlyIds(), player:getCardIds("e"))
    local ids = table.filter(allIds, function (id)
      return not player:prohibitResponse(Fk:getCardById(id)) and Fk:getCardById(id).color == Card.Black
    end)

    -- 询问玩家选择一张黑色牌来替换判定牌
    local cards = room:askToCards(player, {
      min_num = 1,
      max_num = 1,
      skill_name = guidao.name,
      pattern = tostring(Exppattern{ id = ids }),
      include_equip = true,
      prompt = "#xh__guidao-ask::"..target.id..":"..data.reason,
      cancelable = true,
      expand_pile = table.filter(ids, function (id)
        return not table.contains(player:getCardIds("he"), id)
      end)
    })

    -- 如果玩家选择了卡牌
    if #cards > 0 then
      event:setCostData(self, {cards = cards})
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    -- 替换判定牌
    room:changeJudge{
      card = Fk:getCardById(event:getCostData(self).cards[1]),
      player = player,
      data = data,
      skillName = guidao.name,
      response = true,
      exchange = true, -- 表明这是替换判定牌
    }
  end,
})

return guidao