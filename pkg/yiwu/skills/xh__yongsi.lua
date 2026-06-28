local yongsi = fk.CreateSkill{
  name = "xh__yongsi",
  tags = { Skill.Compulsory },
}

Fk:loadTranslationTable{
  ["xh__yongsi"] = "庸肆",
  [":xh__yongsi"] = "锁定技，摸牌阶段，你多摸X张牌；弃牌阶段开始时，你弃置一张牌（X为场上势力数）。",

  ["#xh__yongsi-discard"] = "庸肆：你需弃置一张牌",
  ["$xh__yongsi1"] = "大汉天下，已半入我手！",
  ["$xh__yongsi2"] = "玉玺在手，天下我有！",
}

local function kingdomCount(room)
  local ks = {}
  for _, p in ipairs(room.alive_players) do
    if p.kingdom then
      table.insertIfNeed(ks, p.kingdom)
    end
  end
  return #ks
end

-- 摸牌阶段多摸X
yongsi:addEffect(fk.DrawNCards, {
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(yongsi.name)
  end,
  on_use = function(self, event, target, player, data)
    data.n = data.n + kingdomCount(player.room)
  end,
})

-- 弃牌阶段开始时弃置1张牌
yongsi:addEffect(fk.EventPhaseStart, {
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(yongsi.name) and player.phase == Player.Discard and
      not player:isNude()
  end,
  on_use = function(self, event, target, player, data)
    player.room:askToDiscard(player, {
      skill_name = yongsi.name,
      include_equip = true,
      min_num = 1,
      max_num = 1,
      prompt = "#xh__yongsi-discard",
      cancelable = false,
    })
  end,
})

return yongsi