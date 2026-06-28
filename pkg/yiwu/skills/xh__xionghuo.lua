local xionghuo = fk.CreateSkill{
  name = "xh__xionghuo",
}

Fk:loadTranslationTable{
  ["xh__xionghuo"] = "凶镬",
  [":xh__xionghuo"] = "每局游戏限三次，出牌阶段限一次，你可以选择一名角色，令其本回合下次受到的伤害+1，且其下个出牌阶段开始时进行判定，若结果为：♢，你对其造成1点火焰伤害且其本回合不能对你使用【杀】；♡，其失去1点体力且其本回合手牌上限-1；♤或♧，你获得其装备区和手牌区里的各一张牌。",

  ["#xh__xionghuo"] = "凶镬：令一名角色本回合下次受伤害+1，并在其下个出牌阶段开始时判定执行效果",

  ["$xh__xionghuo1"] = "此镬加之于你，定有所伤！",
  ["$xh__xionghuo2"] = "凶镬沿袭，怎会轻易无伤？",
}

local function changeDamage(data, n)
  if data.changeDamage then
    data:changeDamage(n)
  else
    data.damage = (data.damage or 0) + n
  end
end

-- 每次进入出牌阶段时，清理“出牌阶段限一次”的标记
xionghuo:addEffect(fk.EventPhaseStart, {
  can_refresh = function(self, event, target, player, data)
    return target == player and player:hasSkill(xionghuo.name) and player.phase == Player.Play
  end,
  on_refresh = function(self, event, target, player, data)
    player.room:setPlayerMark(player, "xh__xionghuo_used_in_play", 0)
  end,
})

xionghuo:addEffect("active", {
  anim_type = "offensive",
  prompt = "#xh__xionghuo",
  card_num = 0,
  target_num = 1,
  max_phase_use_time = 1,
  card_filter = Util.FalseFunc,
  target_filter = function(self, player, to_select, selected)
    return #selected == 0
  end,

  can_use = function(self, player)
    return player.phase == Player.Play
      and player:getMark("xh__xionghuo_used_in_play") == 0
      and player:getMark("xh__xionghuo_used_game") < 3
  end,

  on_use = function(self, room, effect)
    local player = effect.from
    local target = effect.tos[1]
    if not target or target.dead or player.dead then return end

    -- 计入次数：本局 +1，本出牌阶段 +1
    room:addPlayerMark(player, "xh__xionghuo_used_game", 1)
    room:setPlayerMark(player, "xh__xionghuo_used_in_play", 1)

    room:setPlayerMark(target, "xh__xionghuo_src", player.id)
    room:addPlayerMark(target, "xh__xionghuo_pending", 1)
    room:addPlayerMark(target, "xh__xionghuo_nextdamage-turn", 1)
  end,
})

xionghuo:addEffect(fk.DetermineDamageInflicted, {
  anim_type = "offensive",
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(xionghuo.name) and not player.dead and
      target and not target.dead and
      target:getMark("xh__xionghuo_src") == player.id and
      target:getMark("xh__xionghuo_nextdamage-turn") > 0 and
      data and data.damage and data.damage > 0
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local n = target:getMark("xh__xionghuo_nextdamage-turn")
    room:setPlayerMark(target, "xh__xionghuo_nextdamage-turn", 0)
    changeDamage(data, n)
  end,
})

xionghuo:addEffect(fk.EventPhaseStart, {
  anim_type = "offensive",
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(xionghuo.name) and not player.dead and
      target and not target.dead and
      target.phase == Player.Play and
      target:getMark("xh__xionghuo_src") == player.id and
      target:getMark("xh__xionghuo_pending") > 0
  end,
  on_cost = function(self, event, target, player, data)
    event:setCostData(self, { tos = { target } })
    return true
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local pending = target:getMark("xh__xionghuo_pending")
    room:setPlayerMark(target, "xh__xionghuo_pending", 0)

    for _ = 1, pending do
      if player.dead or target.dead then break end

      local judge = {
        who = target,
        reason = xionghuo.name,
        pattern = ".",
      }
      room:judge(judge)

      if player.dead or target.dead or not judge.card then break end
      local suit = judge.card.suit

      if suit == Card.Diamond then
        room:addTableMark(target, "xh__xionghuo_prohibit-turn", player.id)
        room:damage{
          from = player,
          to = target,
          damage = 1,
          damageType = fk.FireDamage,
          skillName = xionghuo.name,
        }
      elseif suit == Card.Heart then
        room:addPlayerMark(target, "MinusMaxCards-turn", 1)
        room:loseHp(target, 1, xionghuo.name)
      else
        local ids = {}
        local es = target:getCardIds("e")
        local hs = target:getCardIds("h")
        if #es > 0 then
          table.insert(ids, room:askToChooseCard(player, {
            target = target,
            flag = "e",
            skill_name = xionghuo.name,
          }))
        end
        if #hs > 0 then
          table.insert(ids, room:askToChooseCard(player, {
            target = target,
            flag = "h",
            skill_name = xionghuo.name,
          }))
        end
        if #ids > 0 then
          room:moveCardTo(ids, Player.Hand, player, fk.ReasonPrey, xionghuo.name, nil, false, player)
        end
      end
    end
  end,
})

xionghuo:addEffect("prohibit", {
  is_prohibited = function(self, from, to, card)
    return card and card.trueName == "slash" and from and to and
      table.contains(from:getTableMark("xh__xionghuo_prohibit-turn"), to.id)
  end,
})

return xionghuo
