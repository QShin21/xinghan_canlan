local xiaoxi = fk.CreateSkill {
  name = "xh__xiaoxi",
  tags = { Skill.Compulsory },
}

Fk:loadTranslationTable{
  ["xh__xiaoxi"] = "宵袭",
  [":xh__xiaoxi"] = "锁定技，出牌阶段开始时，你失去1点体力或减1点体力上限，然后选择一项：1.获得你攻击范围内的一名其他角色的一张牌；2.视为对你攻击范围内的一名其他角色使用一张【杀】。",

  ["#xh__xiaoxi-cost"] = "宵袭：选择代价",
  ["xh__xiaoxi_loseHp"] = "失去1点体力",
  ["xh__xiaoxi_loseMaxHp"] = "减1点体力上限",

  ["#xh__xiaoxi-choose"] = "宵袭：选择一项",
  ["xh__xiaoxi_prey"] = "获得一名角色的一张牌",
  ["xh__xiaoxi_slash"] = "视为对一名角色使用【杀】",

  ["#xh__xiaoxi-choose_prey"] = "宵袭：选择攻击范围内一名角色，获得其一张牌",
  ["#xh__xiaoxi-choose_slash"] = "宵袭：选择攻击范围内一名角色，视为对其使用【杀】",

  ["$xh__xiaoxi1"] = "夜深枭啼，亡命夺袭！",
  ["$xh__xiaoxi2"] = "以夜为幕，纵兵逞凶！",
}

xiaoxi:addEffect(fk.EventPhaseStart, {
  anim_type = "offensive",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(xiaoxi.name) and player.phase == Player.Play
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    local room = player.room

    local cost_choices = { "xh__xiaoxi_loseHp" }
    if player.maxHp > 1 then
      table.insert(cost_choices, "xh__xiaoxi_loseMaxHp")
    end
    local cost = room:askToChoice(player, {
      choices = cost_choices,
      skill_name = xiaoxi.name,
      prompt = "#xh__xiaoxi-cost",
    })

    if cost == "xh__xiaoxi_loseMaxHp" then
      room:changeMaxHp(player, -1)
    else
      room:loseHp(player, 1, xiaoxi.name)
    end
    if player.dead then return end

    local slash_card = Fk:cloneCard("slash")

    local prey_targets = table.filter(room:getOtherPlayers(player, false), function(p)
      return not p.dead and player:inMyAttackRange(p) and (not p:isAllNude())
    end)

    local slash_targets = table.filter(room:getOtherPlayers(player, false), function(p)
      return not p.dead and player:inMyAttackRange(p) and player:canUseTo(slash_card, p)
    end)

    if #prey_targets == 0 and #slash_targets == 0 then
      return
    end

    local choices = {}
    if #prey_targets > 0 then table.insert(choices, "xh__xiaoxi_prey") end
    if #slash_targets > 0 then table.insert(choices, "xh__xiaoxi_slash") end

    local act = choices[1]
    if #choices > 1 then
      act = room:askToChoice(player, {
        choices = choices,
        skill_name = xiaoxi.name,
        prompt = "#xh__xiaoxi-choose",
      })
    end

    if act == "xh__xiaoxi_prey" then
      local to = room:askToChoosePlayers(player, {
        targets = prey_targets,
        min_num = 1,
        max_num = 1,
        prompt = "#xh__xiaoxi-choose_prey",
        skill_name = xiaoxi.name,
        cancelable = false,
      })[1]
      if not to or to.dead then return end
      local id = room:askToChooseCard(player, {
        target = to,
        flag = "hej",
        skill_name = xiaoxi.name,
      })
      if id then
        room:obtainCard(player, id, false, fk.ReasonPrey, player, xiaoxi.name)
      end
    else
      local to = room:askToChoosePlayers(player, {
        targets = slash_targets,
        min_num = 1,
        max_num = 1,
        prompt = "#xh__xiaoxi-choose_slash",
        skill_name = xiaoxi.name,
        cancelable = false,
      })[1]
      if not to or to.dead or player.dead then return end
      room:useVirtualCard("slash", nil, player, to, xiaoxi.name, true)
    end
  end,
})

return xiaoxi