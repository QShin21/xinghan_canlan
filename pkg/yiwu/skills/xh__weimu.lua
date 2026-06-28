-- SPDX-License-Identifier: GPL-3.0-or-later
-- 帷幕（自定义版本）
-- 锁定技，当你成为黑色锦囊牌的目标时，取消之；
-- 当你于回合内受到伤害时，你摸2X张牌，然后防止此伤害（X为此伤害值）。

local weimu = fk.CreateSkill{
  name = "xh__weimu",
  tags = { Skill.Compulsory },
}

Fk:loadTranslationTable{
  ["xh__weimu"] = "帷幕",
  [":xh__weimu"] = "锁定技，当你成为黑色锦囊牌的目标时，取消之；当你于回合内受到伤害时，你摸2X张牌，然后防止此伤害（X为此伤害值）。",

  ["$xh__weimu1"] = "此伤与我无关。",
  ["$xh__weimu2"] = "还是另寻他法吧。",
}

weimu:addEffect("prohibit", {
  is_prohibited = function(self, from, to, card)
    return to and to:hasSkill(weimu.name) and card and
      card.type == Card.TypeTrick and card.color == Card.Black
  end,
})

-- 回合内受到伤害：摸2X，然后防止此伤害
weimu:addEffect(fk.DetermineDamageInflicted, {
  anim_type = "defensive",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(weimu.name) and not player.dead and
      player.room.current == player and data and data.damage and data.damage > 0
  end,
  on_use = function(self, event, target, player, data)
    local n = data.damage
    player:drawCards(n * 2, weimu.name)
    data:preventDamage()
  end,
})

return weimu
