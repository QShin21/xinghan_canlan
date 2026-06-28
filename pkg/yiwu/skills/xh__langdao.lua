local langdao = fk.CreateSkill{
  name = "xh__langdao",
  dynamic_desc = function(self, player)
    local removed = player:getTableMark("xh__langdao_removed")
    if #removed >= 2 then
      return "dummyskill"
    end
    local desc = {}
    for _, k in ipairs({"xh__langdao1", "xh__langdao2"}) do
      if not table.contains(removed, k) then
        table.insert(desc, Fk:translate(k))
      end
    end
    return "xh__langdao_inner:" .. table.concat(desc, "/")
  end,
}

Fk:loadTranslationTable{
  ["xh__langdao"] = "狼蹈",
  [":xh__langdao"] = "当你使用【杀】指定唯一目标时，你可以选择一项，令此【杀】：1.造成的伤害+1；2.不能被响应。每项限一次。",
  [":xh__langdao_inner"] = "当你使用【杀】指定唯一目标时，你可以选择一项，令此【杀】：{1}。每项限一次。",

  ["#xh__langdao-invoke"] = "狼蹈：你可以为此【杀】选择一项增益",
  ["#xh__langdao-choice"] = "狼蹈：选择一项",

  ["xh__langdao1"] = "造成的伤害+1",
  ["xh__langdao2"] = "不能被响应",

  ["$xh__langdao1"] = "虎踞黑山，望天下百城。",
  ["$xh__langdao2"] = "狼顾四野，视幽冀为饵。",
}

langdao:addEffect(fk.TargetSpecifying, {
  anim_type = "offensive",
  can_trigger = function(self, event, target, player, data)
    if target ~= player then return false end
    if not player:hasSkill(langdao.name) then return false end
    if data.cancelled then return false end
    if not data.card or data.card.trueName ~= "slash" then return false end
    if not data:isOnlyTarget(data.to) then return false end
    return #player:getTableMark("xh__langdao_removed") < 2
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local removed = player:getTableMark("xh__langdao_removed")
    local choices = table.filter({"xh__langdao1", "xh__langdao2"}, function(k)
      return not table.contains(removed, k)
    end)
    if #choices == 0 then return end
    table.insert(choices, "Cancel")
    local choice = room:askToChoice(player, {
      choices = choices,
      skill_name = langdao.name,
      prompt = "#xh__langdao-choice",
    })
    if choice ~= "Cancel" then
      event:setCostData(self, { choice = choice })
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local choice = (event:getCostData(self) or {}).choice
    if not choice then return end

    if choice == "xh__langdao1" then
      data.additionalDamage = (data.additionalDamage or 0) + 1
    elseif choice == "xh__langdao2" then
      data.disresponsive = true
    end

    room:addTableMarkIfNeed(player, "xh__langdao_removed", choice)
  end,
})

return langdao