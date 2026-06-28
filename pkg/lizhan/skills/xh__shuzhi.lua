-- SPDX-License-Identifier: GPL-3.0-or-later
-- 曹操 - 述志技能
-- 游戏开始时，你选择获得"奸雄"或"清正"。

local shuzhi = fk.CreateSkill {
  name = "xh__shuzhi",
}

Fk:loadTranslationTable {
  ["xh__shuzhi"] = "述志",
  [":xh__shuzhi"] = "游戏开始时，你选择获得\"奸雄\"或\"清正\"。",

  ["#xh__shuzhi-choice"] = "述志：选择获得一个技能",

  -- 选项按钮显示短文本
  ["shuzhi_jianxiong"] = "奸雄",
  ["shuzhi_qingzheng"] = "清正",

  -- 选项详情区显示详细说明（配合 detailed = true）
  [":shuzhi_jianxiong"] = "受到伤害后，获得造成伤害的牌并摸一张牌",
  [":shuzhi_qingzheng"] = "出牌阶段开始时，弃置一种花色的牌，令其他角色弃置同花色牌",

  ["$xh__shuzhi1"] = "志在天下，何惧之有！",
  ["$xh__shuzhi2"] = "大业未成，不敢懈怠！",
}

shuzhi:addEffect(fk.GameStart, {
  mute = true,
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(shuzhi.name)
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    local room = player.room

    local choice = room:askToChoice(player, {
      choices = {"shuzhi_jianxiong", "shuzhi_qingzheng"},
      skill_name = shuzhi.name,
      prompt = "#xh__shuzhi-choice",
      detailed = true,
    })

    if choice == "shuzhi_jianxiong" then
      room:handleAddLoseSkills(player, "ex__jianxiong", nil, false, true)
    else
      room:handleAddLoseSkills(player, "ofl__qingzheng", nil, false, true)
    end

    -- 移除述志
    room:handleAddLoseSkills(player, "-" .. shuzhi.name, nil, false, true)
  end,
})

return shuzhi