-- SPDX-License-Identifier: GPL-3.0-or-later
-- 曹仁 - 砺锋技能
-- 你的回合外，你可以将一张本回合所有角色均未使用过的颜色的手牌当【无懈可击】使用。

local lifeng = fk.CreateSkill {
  name = "xh__lifeng",
}

Fk:loadTranslationTable{
  ["xh__lifeng"] = "砺锋",
  [":xh__lifeng"] = "你的回合外，你可以将一张本回合所有角色均未使用过的颜色的手牌当【无懈可击】使用。",

  ["#xh__lifeng"] = "砺锋：将一张牌当【无懈可击】使用",

  ["$xh__lifeng1"] = "锋芒毕露，锐不可当！",
  ["$xh__lifeng2"] = "砺剑待发，一击必中！",
}

lifeng:addEffect("viewas", {
  pattern = "nullification",
  prompt = "#xh__lifeng",
  handly_pile = true,
  filter_pattern = function (self, player, card_name)
    local colors = {"red", "black"}
    for _, c in ipairs(player:getTableMark("xh__lifeng-turn")) do
      table.removeOne(colors, c)
    end
    if #colors > 0 then
      return {
        max_num = 1,
        min_num = 1,
        pattern = ".|.|" .. table.concat(colors, ",") .. "|^equip",
      }
    end
  end,
  view_as = function(self, player, cards)
    if #cards ~= 1 then return end
    local card = Fk:cloneCard("nullification")
    card.skillName = lifeng.name
    card:addSubcard(cards[1])
    return card
  end,
  enabled_at_play = function(self, player)
    return false
  end,
  enabled_at_response = function(self, player, response)
    return player.phase == Player.NotActive
      and (not response)
      and #player:getTableMark("xh__lifeng-turn") < 2
  end,
  enabled_at_nullification = function (self, player, data)
    return player.phase == Player.NotActive
      and #player:getTableMark("xh__lifeng-turn") < 2
      and #player:getHandlyIds() > 0
  end,
})

lifeng:addEffect(fk.AfterCardUseDeclared, {
  can_refresh = function(self, event, target, player, data)
    return player:hasSkill(lifeng.name, true) and data.card.color ~= Card.NoColor
  end,
  on_refresh = function(self, event, target, player, data)
    player.room:addTableMarkIfNeed(player, "xh__lifeng-turn", data.card:getColorString())
  end,
})

lifeng:addAcquireEffect(function (self, player, is_start)
  if not is_start then
    local room = player.room
    local mark = {}
    room.logic:getEventsOfScope(GameEvent.UseCard, 1, function (e)
      local use = e.data
      if use.card.color ~= Card.NoColor then
        table.insertIfNeed(mark, use.card:getColorString())
      end
    end, Player.HistoryTurn)
    if #mark > 0 then
      room:setPlayerMark(player, "xh__lifeng-turn", mark)
    end
  end
end)

return lifeng
