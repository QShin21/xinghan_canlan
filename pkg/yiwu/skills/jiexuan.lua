local jiexuan = fk.CreateSkill{
  name = "wzzz__jiexuan",
  tags = { Skill.Switch },
}

Fk:loadTranslationTable{
  ["wzzz__jiexuan"] = "解悬",
  [":wzzz__jiexuan"] = "转换技，出牌阶段限一次，阳：你可以将一张红色牌当【顺手牵羊】使用；阴：你可以将一张黑色牌当【过河拆桥】使用。",

  ["#wzzz__jiexuan-yang"] = "解悬：你可以将一张红色牌当【顺手牵羊】使用",
  ["#wzzz__jiexuan-yin"] = "解悬：你可以将一张黑色牌当【过河拆桥】使用",

  ["$wzzz__jiexuan1"] = "大汉百年国祚悬于一发之下，焉有坐视之理。",
  ["$wzzz__jiexuan2"] = "愿献一腔热血，沃在野草木，成栋梁之材。",
}

jiexuan:addEffect("viewas", {
  anim_type = "switch",
  pattern = "snatch,dismantlement",
  prompt = function(self, player)
    return "#wzzz__jiexuan-"..player:getSwitchSkillState(jiexuan.name, false, true)
  end,
  handly_pile = true,
  filter_pattern = function (self, player, card_name)
    return {
      max_num = 1,
      min_num = 1,
      pattern = (player:getSwitchSkillState(jiexuan.name, false) == fk.SwitchYang) and ".|.|red" or ".|.|black",
    }
  end,
  view_as = function(self, player, cards)
    if #cards ~= 1 then return end
    local card
    if player:getSwitchSkillState(jiexuan.name, false) == fk.SwitchYang then
      card = Fk:cloneCard("snatch")
    else
      card = Fk:cloneCard("dismantlement")
    end
    card.skillName = jiexuan.name
    card:addSubcard(cards[1])
    return card
  end,
  enabled_at_play = function(self, player)
    return player:usedSkillTimes(jiexuan.name, Player.HistoryPhase) == 0
  end,
})

return jiexuan
