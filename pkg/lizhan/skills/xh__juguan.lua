local juguan = fk.CreateSkill{
  name = "xh__juguan",
}

Fk:loadTranslationTable{
  ["xh__juguan"] = "拒关",
  [":xh__juguan"] = "出牌阶段限一次，你可以将一张手牌当不计入使用次数的【杀】或【决斗】使用。若受到此牌伤害的角色未在你的下回合开始前对你造成过伤害，你的下个摸牌阶段摸牌数+2。",
  ["#xh__juguan"] = "拒关：将一张手牌当【杀】或【决斗】使用（不计入使用次数）",
  ["@@xh__juguan"] = "拒关",
  ["$xh__juguan1"] = "吾欲自立，举兵拒关。",
  ["$xh__juguan2"] = "自立门户，拒关不开。",
}

-- 主动技：选择一张手牌与一个目标，视为使用【杀】或【决斗】，并设置为不计入使用次数
juguan:addEffect("active", {
  anim_type = "offensive",
  prompt = "#xh__juguan",
  card_num = 1,
  target_num = 1,
  interaction = UI.CardNameBox { choices = {"slash", "duel"} },

  can_use = function(self, player)
    return player.phase == Player.Play and player:usedSkillTimes(juguan.name, Player.HistoryPhase) == 0
  end,

  -- 修复点：按区域判断，手牌区里的装备牌同样属于手牌
  card_filter = function(self, player, to_select, selected)
    if #selected > 0 then return false end
    return table.contains(player:getCardIds(Player.Hand), to_select)
  end,

  target_filter = function(self, player, to_select, selected, selected_cards)
    if #selected > 0 or #selected_cards ~= 1 or not self.interaction.data then
      return false
    end
    local card = Fk:cloneCard(self.interaction.data)
    card.skillName = juguan.name
    card:addSubcard(selected_cards[1])
    return player:canUseTo(card, to_select, { bypass_times = true })
  end,

  on_use = function(self, room, effect)
    local player = effect.from
    local to = effect.tos[1]
    local cid = effect.cards[1]

    local choice = self.interaction.data or "slash"

    -- 开始记录本次由【拒关】转化牌造成的伤害目标
    room:setPlayerMark(player, "xh__juguan_rec", 1)
    room:setPlayerMark(player, "xh__juguan_tmp", 0)
    room:setPlayerMark(player, "xh__juguan_retaliated", 0)

    -- extra=true：不计入使用次数限制
    local use = room:useVirtualCard(choice, {cid}, player, to, juguan.name, true)

    -- 结束记录
    room:setPlayerMark(player, "xh__juguan_rec", 0)

    -- 每次发动分别记录，额外出牌阶段中多次发动可以叠加摸牌数。
    local tmp = player:getTableMark("xh__juguan_tmp")
    local retaliated = player:getTableMark("xh__juguan_retaliated")
    if tmp and #tmp > 0 then
      local pending = table.simpleClone(player:getTableMark("xh__juguan_pending"))
      for _, id in ipairs(tmp) do
        if not table.contains(retaliated, id) then
          table.insert(pending, id)
          room:addTableMark(player, "@@xh__juguan", id)
        end
      end
      room:setPlayerMark(player, "xh__juguan_pending", pending)
    end

    -- 清理临时表
    room:setPlayerMark(player, "xh__juguan_tmp", 0)
    room:setPlayerMark(player, "xh__juguan_retaliated", 0)

    return use ~= nil
  end,
})

-- 记录“本次由拒关转化牌造成伤害”的目标
juguan:addEffect(fk.Damaged, {
  can_refresh = function(self, event, target, player, data)
    if player:getMark("xh__juguan_rec") == 0 then return false end
    return data and data.from == player and data.card and data.card.skillName == juguan.name
  end,
  on_refresh = function(self, event, target, player, data)
    player.room:addTableMark(player, "xh__juguan_tmp", target.id)
  end,
})

-- 若被@@xh__juguan标记的角色在你下回合开始前对你造成伤害，则移除其标记
juguan:addEffect(fk.Damaged, {
  can_refresh = function(self, event, target, player, data)
    if target ~= player then return false end
    if not data or not data.from then return false end
    return player:getMark("xh__juguan_rec") > 0 or
      table.contains(player:getTableMark("xh__juguan_pending"), data.from.id)
  end,
  on_refresh = function(self, event, target, player, data)
    local room = player.room
    if player:getMark("xh__juguan_rec") > 0 then
      room:addTableMark(player, "xh__juguan_retaliated", data.from.id)
    end
    local pending = table.filter(player:getTableMark("xh__juguan_pending"), function(id)
      return id ~= data.from.id
    end)
    room:setPlayerMark(player, "xh__juguan_pending", pending)
    room:removeTableMark(player, "@@xh__juguan", data.from.id)
  end,
})

-- 到你的下回合开始时，若仍有人在@@xh__juguan里，则准备让下个摸牌阶段摸牌数+2
juguan:addEffect(fk.TurnStart, {
  can_refresh = function(self, event, target, player, data)
    return target == player and #player:getTableMark("xh__juguan_pending") > 0
  end,
  on_refresh = function(self, event, target, player, data)
    local room = player.room
    local n = #player:getTableMark("xh__juguan_pending")
    room:setPlayerMark(player, "@@xh__juguan", 0)
    room:setPlayerMark(player, "xh__juguan_pending", 0)
    room:addPlayerMark(player, "xh__juguan_draw", n)
  end,
})

-- 增加摸牌数
juguan:addEffect(fk.DrawNCards, {
  can_refresh = function(self, event, target, player, data)
    return target == player and player:getMark("xh__juguan_draw") ~= 0
  end,
  on_refresh = function(self, event, target, player, data)
    data.n = data.n + 2 * player:getMark("xh__juguan_draw")
    player.room:setPlayerMark(player, "xh__juguan_draw", 0)
  end,
})

return juguan
