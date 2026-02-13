-- SPDX-License-Identifier: GPL-3.0-or-later
-- 星汉灿烂 1v1 规则技能
-- 包含：先手惩罚、胜负判定、武将锁定、鏖战规则

local rule = fk.CreateSkill {
  name = "#xinghan_1v1_rule&",
}

local U = require "packages.xinghan_canlan.pkg.xinghan_mode.xinghan_util"

-- 游戏状态存储
local game_state = {
  round_count = 1,           -- 当前局数
  first_wins = 0,            -- 先手胜局数
  second_wins = 0,           -- 后手胜局数
  first_won_count = 0,       -- 先手累计获胜武将数
  second_won_count = 0,      -- 后手累计获胜武将数
  first_round_wins = 0,      -- 先手累计小局胜利数
  second_round_wins = 0,     -- 后手累计小局胜利数
  shuffle_count = 0,
  peach_as_wine = false,
  hp_damage_active = false,
}

-- 从武将池中移除武将
local function removeGeneral(generals, g)
  if not generals or #generals == 0 then return nil end
  local gt = Fk.generals[g].trueName
  for i, v in ipairs(generals) do
    if Fk.generals[v].trueName == gt then
      return table.remove(generals, i)
    end
  end
  return table.remove(generals, 1)
end

-- 判断是否为先手玩家
local function isFirstPlayer(player)
  local room = player.room
  local first = room:getBanner("@xinghan_first_player")
  return first and first == player.id
end

-- 获取玩家武将池
local function getGeneralPool(player)
  local room = player.room
  if isFirstPlayer(player) then
    return room:getBanner("@&xinghan_first_pool") or {}
  else
    return room:getBanner("@&xinghan_second_pool") or {}
  end
end

-- 获取已锁定武将
local function getLockedGenerals(player)
  local room = player.room
  if isFirstPlayer(player) then
    return room:getBanner("@&xinghan_first_locked") or {}
  else
    return room:getBanner("@&xinghan_second_locked") or {}
  end
end

-- 添加锁定武将
local function addLockedGeneral(player, general)
  local room = player.room
  local locked = getLockedGenerals(player)
  table.insert(locked, general)
  if isFirstPlayer(player) then
    room:setBanner("@&xinghan_first_locked", locked)
  else
    room:setBanner("@&xinghan_second_locked", locked)
  end
end

-- 摸初始手牌函数
local function drawInit(room, player, n)
  if n <= 0 then return {} end
  local cardIds = {}
  for _ = 1, n do
    if #room.draw_pile > 0 then
      local id = room.draw_pile[1]
      table.insert(cardIds, id)
      table.remove(room.draw_pile, 1)
    end
  end
  
  if #cardIds == 0 then return {} end
  
  player:addCards(Player.Hand, cardIds)
  for _, id in ipairs(cardIds) do
    Fk:filterCard(id, player)
  end

  local move_to_notify = {
    moveInfo = {},
    to = player,
    toArea = Card.PlayerHand,
    moveReason = fk.ReasonDraw
  }
  for _, id in ipairs(cardIds) do
    table.insert(move_to_notify.moveInfo,
    { cardId = id, fromArea = room:getCardArea(id) })
  end
  room:notifyMoveCards(nil, {move_to_notify})

  for _, id in ipairs(cardIds) do
    room:setCardArea(id, Card.PlayerHand, player.id)
  end
  room:syncDrawPile()
  return cardIds
end

-- 登场效果
rule:addEffect(fk.GameStart, {
  can_refresh = function(self, event, target, player, data)
    return player.room.current == player
  end,
  on_refresh = function(self, event, target, player, data)
    local room = player.room
    room.logic:trigger(U.Debut, player, player.general, false)
    room.logic:trigger(U.Debut, player.next, player.next.general, false)
  end,
})

-- 初始手牌（4张）
rule:addEffect(fk.DrawInitialCards, {
  can_refresh = function(self, event, target, player, data)
    return target == player
  end,
  on_refresh = function(self, event, target, player, data)
    data.num = 4
  end,
})

-- 先手第一回合少摸一张牌
rule:addEffect(fk.DrawNCards, {
  can_refresh = function(self, event, target, player, data)
    return target == player and isFirstPlayer(player) and player.room:getBanner(self.name) == nil
  end,
  on_refresh = function(self, event, target, player, data)
    player.room:setBanner(self.name, 1)
    data.n = data.n - 1
  end,
})

-- 胜负判定
rule:addEffect(fk.GameOverJudge, {
  can_refresh = function(self, event, target, player, data)
    return target == player
  end,
  on_refresh = function(self, event, target, player, data)
    local room = player.room
    room:setTag("SkipGameRule", true)
    
    if player.rest > 0 then return end
    
    -- 判断胜负
    local winner = player.next  -- 存活的一方
    local loser = player        -- 死亡的一方
    
    -- 计算胜方派出的武将数量（主将 + 副将）
    local winner_general_count = 1
    if winner.deputyGeneral and winner.deputyGeneral ~= "" then
      winner_general_count = 2
    end
    
    -- 更新获胜武将数（根据胜方派出的武将数量）
    if isFirstPlayer(winner) then
      game_state.first_won_count = game_state.first_won_count + winner_general_count
      game_state.first_round_wins = game_state.first_round_wins + 1
    else
      game_state.second_won_count = game_state.second_won_count + winner_general_count
      game_state.second_round_wins = game_state.second_round_wins + 1
    end
    
    -- 锁定胜方武将
    addLockedGeneral(winner, winner.general)
    if winner.deputyGeneral and winner.deputyGeneral ~= "" then
      addLockedGeneral(winner, winner.deputyGeneral)
    end
    
    -- 更新显示
    room:setBanner("@xinghan_won", string.format("获胜武将 %d : %d", 
      game_state.first_won_count, game_state.second_won_count))
    room:setBanner("@xinghan_round_wins", string.format("小局胜利 %d : %d",
      game_state.first_round_wins, game_state.second_round_wins))
    
    room:sendLog{
      type = "#XinghanWonCount",
      arg = game_state.first_won_count,
      arg2 = game_state.second_won_count,
      toast = true,
    }
    
    room:sendLog{
      type = "#XinghanRoundWins",
      arg = game_state.first_round_wins,
      arg2 = game_state.second_round_wins,
      toast = true,
    }
    
    -- 判断是否赢得本局
    -- 条件：累计小局胜利数 = 3 且 累计获胜武将数 = 5
    local first_can_win = game_state.first_round_wins == 3 and game_state.first_won_count == 5
    local second_can_win = game_state.second_round_wins == 3 and game_state.second_won_count == 5
    
    if first_can_win then
      game_state.first_wins = game_state.first_wins + 1
      room:sendLog{
        type = "#XinghanRoundWin",
        arg = "firstPlayer",
        arg2 = string.format("%d : %d", game_state.first_wins, game_state.second_wins),
        toast = true,
      }
      
      -- 判断是否赢得比赛（五局三胜）
      if game_state.first_wins >= 3 then
        room:gameOver("lord")
        return
      end
      
      -- 重置本局状态，开始新一局
      game_state.round_count = game_state.round_count + 1
      game_state.first_won_count = 0
      game_state.second_won_count = 0
      game_state.first_round_wins = 0
      game_state.second_round_wins = 0
      game_state.shuffle_count = 0
      game_state.peach_as_wine = false
      game_state.hp_damage_active = false
      
    elseif second_can_win then
      game_state.second_wins = game_state.second_wins + 1
      room:sendLog{
        type = "#XinghanRoundWin",
        arg = "secondPlayer",
        arg2 = string.format("%d : %d", game_state.first_wins, game_state.second_wins),
        toast = true,
      }
      
      if game_state.second_wins >= 3 then
        room:gameOver("renegade")
        return
      end
      
      -- 重置本局状态
      game_state.round_count = game_state.round_count + 1
      game_state.first_won_count = 0
      game_state.second_won_count = 0
      game_state.first_round_wins = 0
      game_state.second_round_wins = 0
      game_state.shuffle_count = 0
      game_state.peach_as_wine = false
      game_state.hp_damage_active = false
    end
    
    room:setBanner("@xinghan_round", string.format("第 %d 局", game_state.round_count))
    room:setBanner("@xinghan_score", string.format("%d : %d", 
      game_state.first_wins, game_state.second_wins))
  end,
})

-- 死亡换将
rule:addEffect(fk.BuryVictim, {
  can_refresh = function(self, event, target, player, data)
    return target == player
  end,
  on_refresh = function(self, event, target, player, data)
    local room = player.room
    room:setTag("SkipGameRule", true)
    
    if player.rest > 0 then return end
    
    local pool = getGeneralPool(player)
    local locked = getLockedGenerals(player)
    
    -- 过滤掉已锁定的武将
    local available = {}
    for _, g in ipairs(pool) do
      if not table.contains(locked, g) then
        table.insert(available, g)
      end
    end
    
    player:bury()
    
    if #available == 0 then
      room:gameOver(player.next.role)
      return
    end
    
    local current = room.logic:getCurrentEvent()
    local last_event = nil
    if room.current.dead then
      last_event = current:findParent(GameEvent.Turn, true)
    end
    if last_event == nil then
      last_event = current
      if last_event.parent then
        repeat
          if table.contains({GameEvent.Round, GameEvent.Turn, GameEvent.Phase}, last_event.parent.event) then break end
          last_event = last_event.parent
        until (not last_event.parent)
      end
    end
    
    last_event:addCleaner(function()
      -- 选择新武将上场（可选1-2名）
      local max_choose = math.min(2, #available)
      local req = Request:new({player}, "AskForGeneral")
      req.timeout = room:getSettings('generalTimeout')
      req:setData(player, { available, max_choose })
      req:setDefaultReply(player, { available[1] })
      req:ask()
      
      local chosen = req:getResult(player)
      
      -- 移除已选武将
      for _, g in ipairs(chosen) do
        removeGeneral(pool, g)
      end
      
      -- 更新武将池
      if isFirstPlayer(player) then
        room:setBanner("@&xinghan_first_pool", pool)
      else
        room:setBanner("@&xinghan_second_pool", pool)
      end
      
      room:handleAddLoseSkills(player, "-"..table.concat(player:getSkillNameList(), "|-"), nil, false)
      room:resumePlayerArea(target, {
        Player.WeaponSlot,
        Player.ArmorSlot,
        Player.OffensiveRideSlot,
        Player.DefensiveRideSlot,
        Player.TreasureSlot,
        Player.JudgeSlot,
      })
      
      -- 设置新武将
      if #chosen == 1 then
        room:changeHero(player, chosen[1], false, false, true)
      else
        -- 双将
        room:changeHero(player, chosen[1], false, false, true, chosen[2])
      end
      
      -- 复活并设置体力
      room:setPlayerProperty(player, "shield", Fk.generals[chosen[1]].shield)
      room:revivePlayer(player, false)
      
      -- 双将体力计算
      local hp = Fk.generals[chosen[1]].hp
      if #chosen > 1 then
        hp = math.floor((hp + Fk.generals[chosen[2]].hp) / 2)
      end
      room:setPlayerProperty(player, "hp", hp)
      
      local draw_data = DrawInitialData:new{ num = 4 }
      room.logic:trigger(fk.DrawInitialCards, player, draw_data)
      draw_data.cards = drawInit(room, player, 4)
      room.logic:trigger(fk.AfterDrawInitialCards, player, draw_data)
      room.logic:trigger(U.Debut, player, player.general, false)
    end)
  end,
})

-- 洗牌计数（鏖战规则）
rule:addEffect(fk.AfterDrawPileShuffle, {
  can_refresh = function(self, event, target, player, data)
    return true
  end,
  on_refresh = function(self, event, target, player, data)
    local room = player.room
    game_state.shuffle_count = game_state.shuffle_count + 1
    
    room:sendLog{
      type = "#XinghanShuffle",
      arg = game_state.shuffle_count,
      toast = true,
    }
    
    if game_state.shuffle_count == 2 then
      game_state.peach_as_wine = true
      room:sendLog{
        type = "#XinghanPeachAsWine",
        toast = true,
      }
    end
    
    if game_state.shuffle_count >= 3 then
      game_state.hp_damage_active = true
    end
  end,
})

-- 鏖战：桃可以作为酒使用
rule:addEffect(fk.AskForCardUse, {
  mute = true,
  can_trigger = function(self, event, target, player, data)
    return target == player and game_state.peach_as_wine and data.pattern
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local pattern = data.pattern
    
    -- 如果在询问酒，让桃也可以使用
    if pattern and string.find(pattern, "wine") then
      -- 获取手牌中的桃
      local peaches = table.filter(player:getCardIds(Player.Hand), function(id)
        return Fk:getCardById(id).name == "peach"
      end)
      
      if #peaches > 0 then
        -- 允许使用桃作为酒
        data.result = { from = player.id, cards = { peaches[1] } }
        return true
      end
    end
  end,
})

-- 鏖战：回合结束扣体力
rule:addEffect(fk.TurnEnd, {
  can_refresh = function(self, event, target, player, data)
    return game_state.hp_damage_active and not player.dead
  end,
  on_refresh = function(self, event, target, player, data)
    local room = player.room
    room:loseHp(player, 1, "xinghan_aozhan")
    room:sendLog{
      type = "#XinghanAoZhanDamage",
      arg = player.name,
      toast = true,
    }
  end,
})

-- 翻译
Fk:loadTranslationTable{
  ["#xinghan_1v1_rule&"] = "星汉灿烂规则",
  
  ["#XinghanShuffle"] = "牌堆已洗牌 %arg 次",
  ["#XinghanPeachAsWine"] = "鏖战开始：【桃】视为【酒】",
  ["#XinghanAoZhanDamage"] = "鏖战：回合结束，%arg 失去1点体力",
  ["#XinghanRoundWins"] = "小局胜利 先手 %arg : %arg2 后手",
  
  ["xinghan_aozhan"] = "鏖战",
}

return rule
