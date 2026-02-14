-- SPDX-License-Identifier: GPL-3.0-or-later
-- 星汉灿烂 1v1 规则技能
-- 包含：先手惩罚、胜负判定、武将锁定、鏖战规则

local rule = fk.CreateSkill {
  name = "#xinghan_1v1_rule&",
}

local U = require "packages.xinghan_canlan.pkg.xinghan_mode.xinghan_util"

-- 游戏状态存储
local game_state = {
  round_count = 1,
  first_wins = 0,
  second_wins = 0,
  first_won_count = 0,
  second_won_count = 0,
  first_round_wins = 0,
  second_round_wins = 0,
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

-- 获取玩家当前获胜武将数
local function getWonCount(player)
  if isFirstPlayer(player) then
    return game_state.first_won_count
  else
    return game_state.second_won_count
  end
end

-- 根据获胜武将数计算可选武将数量范围
local function getDeployRange(won_count)
  if won_count == 1 or won_count == 3 then
    return 2, 2
  elseif won_count == 4 then
    return 1, 1
  else
    return 1, 2
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

-- 选择武将函数
local function askForDeploy(room, player, available, min_num, max_num)
  if #available == 0 then return nil end
  
  min_num = math.min(min_num, #available)
  max_num = math.min(max_num, #available)
  if max_num < min_num then
    max_num = min_num
  end
  
  local prompt = "#xinghan-deploy:::"..(isFirstPlayer(player) and "firstPlayer" or "secondPlayer")..":"..#available..":"..min_num..":"..max_num
  local result = room:askToCustomDialog(player, {
    skill_name = "xinghan_1v1_mode",
    qml_path = "packages/xinghan_canlan/qml/XinghanDeploy.qml",
    extra_data = {
      available, min_num, max_num, {}, prompt
    }
  })
  
  local chosen = {}
  if result ~= "" then
    for i, id in ipairs(result.ids) do
      local g = result.generals[i]
      table.insert(chosen, g)
    end
  else
    for i = 1, min_num do
      if available[i] then
        table.insert(chosen, available[i])
      end
    end
  end
  
  return chosen
end

-- 设置武将并添加技能
local function setGeneralWithSkills(room, player, general, deputy)
  -- 设置主将
  room:setPlayerGeneral(player, general, true, true)
  -- 设置副将
  if deputy then
    room:setDeputyGeneral(player, deputy)
  else
    player.deputyGeneral = ""
  end
  
  -- 手动添加技能
  local general_obj = Fk.generals[general]
  if general_obj then
    for _, s in ipairs(general_obj:getSkillNameList(false)) do
      room:handleAddLoseSkills(player, s, nil, false)
    end
  end
  
  if deputy then
    local deputy_obj = Fk.generals[deputy]
    if deputy_obj then
      for _, s in ipairs(deputy_obj:getSkillNameList(false)) do
        room:handleAddLoseSkills(player, s, nil, false)
      end
    end
  end
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
    
    local winner = player.next
    local loser = player
    
    local winner_general_count = 1
    if winner.deputyGeneral and winner.deputyGeneral ~= "" then
      winner_general_count = 2
    end
    
    if isFirstPlayer(winner) then
      game_state.first_won_count = game_state.first_won_count + winner_general_count
      game_state.first_round_wins = game_state.first_round_wins + 1
    else
      game_state.second_won_count = game_state.second_won_count + winner_general_count
      game_state.second_round_wins = game_state.second_round_wins + 1
    end
    
    addLockedGeneral(winner, winner.general)
    if winner.deputyGeneral and winner.deputyGeneral ~= "" then
      addLockedGeneral(winner, winner.deputyGeneral)
    end
    
    local loser_pool = getGeneralPool(loser)
    table.insert(loser_pool, loser.general)
    if loser.deputyGeneral and loser.deputyGeneral ~= "" then
      table.insert(loser_pool, loser.deputyGeneral)
    end
    if isFirstPlayer(loser) then
      room:setBanner("@&xinghan_first_pool", loser_pool)
    else
      room:setBanner("@&xinghan_second_pool", loser_pool)
    end
    
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
      
      if game_state.first_wins >= 3 then
        room:gameOver("lord")
        return
      end
      
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

-- 死亡换将（重整阶段）
rule:addEffect(fk.BuryVictim, {
  can_refresh = function(self, event, target, player, data)
    return target == player
  end,
  on_refresh = function(self, event, target, player, data)
    local room = player.room
    room:setTag("SkipGameRule", true)
    
    if player.rest > 0 then return end
    
    local loser_pool = getGeneralPool(player)
    local loser_locked = getLockedGenerals(player)
    
    local loser_available = {}
    for _, g in ipairs(loser_pool) do
      if not table.contains(loser_locked, g) then
        table.insert(loser_available, g)
      end
    end
    
    player:bury()
    
    local winner = player.next
    local winner_pool = getGeneralPool(winner)
    local winner_locked = getLockedGenerals(winner)
    
    local winner_available = {}
    for _, g in ipairs(winner_pool) do
      if not table.contains(winner_locked, g) then
        table.insert(winner_available, g)
      end
    end
    
    if #loser_available == 0 then
      room:gameOver(winner.role)
      return
    end
    
    if #winner_available == 0 then
      room:gameOver(player.role)
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
      room:doBroadcastNotify("ShowToast", Fk:translate("xinghan reorganize"))
      
      local loser_won = getWonCount(player)
      local winner_won = getWonCount(winner)
      local loser_min, loser_max = getDeployRange(loser_won)
      local winner_min, winner_max = getDeployRange(winner_won)
      
      local loser_chosen = askForDeploy(room, player, loser_available, loser_min, loser_max)
      if not loser_chosen or #loser_chosen == 0 then
        loser_chosen = { loser_available[1] }
      end
      
      for _, g in ipairs(loser_chosen) do
        removeGeneral(loser_pool, g)
      end
      
      if isFirstPlayer(player) then
        room:setBanner("@&xinghan_first_pool", loser_pool)
      else
        room:setBanner("@&xinghan_second_pool", loser_pool)
      end
      
      local winner_chosen = askForDeploy(room, winner, winner_available, winner_min, winner_max)
      if not winner_chosen or #winner_chosen == 0 then
        winner_chosen = { winner_available[1] }
      end
      
      for _, g in ipairs(winner_chosen) do
        removeGeneral(winner_pool, g)
      end
      
      if isFirstPlayer(winner) then
        room:setBanner("@&xinghan_first_pool", winner_pool)
      else
        room:setBanner("@&xinghan_second_pool", winner_pool)
      end
      
      -- 处理败方复活
      room:resumePlayerArea(target, {
        Player.WeaponSlot,
        Player.ArmorSlot,
        Player.OffensiveRideSlot,
        Player.DefensiveRideSlot,
        Player.TreasureSlot,
        Player.JudgeSlot,
      })
      
      -- 设置败方武将（使用封装函数，会自动添加技能）
      local loser_deputy = #loser_chosen > 1 and loser_chosen[2] or nil
      setGeneralWithSkills(room, player, loser_chosen[1], loser_deputy)
      
      room:revivePlayer(player, false)
      
      local loser_hp = Fk.generals[loser_chosen[1]].hp
      if #loser_chosen > 1 then
        loser_hp = math.floor((loser_hp + Fk.generals[loser_chosen[2]].hp) / 2)
      end
      room:setPlayerProperty(player, "hp", loser_hp)
      room:setPlayerProperty(player, "maxHp", loser_hp)
      
      local draw_data = DrawInitialData:new{ num = 4 }
      room.logic:trigger(fk.DrawInitialCards, player, draw_data)
      draw_data.cards = drawInit(room, player, 4)
      room.logic:trigger(fk.AfterDrawInitialCards, player, draw_data)
      room.logic:trigger(U.Debut, player, player.general, false)
      
      -- 设置胜方武将（使用封装函数，会自动添加技能）
      local winner_deputy = #winner_chosen > 1 and winner_chosen[2] or nil
      setGeneralWithSkills(room, winner, winner_chosen[1], winner_deputy)
      
      local winner_hp = Fk.generals[winner_chosen[1]].hp
      if #winner_chosen > 1 then
        winner_hp = math.floor((winner_hp + Fk.generals[winner_chosen[2]].hp) / 2)
      end
      room:setPlayerProperty(winner, "hp", winner_hp)
      room:setPlayerProperty(winner, "maxHp", winner_hp)
      
      room.logic:trigger(U.Debut, winner, winner.general, false)
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
    
    if pattern and string.find(pattern, "wine") then
      local peaches = table.filter(player:getCardIds(Player.Hand), function(id)
        return Fk:getCardById(id).name == "peach"
      end)
      
      if #peaches > 0 then
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
  
  ["#xinghan-deploy"] = "你是[%arg]，可选武将数：%arg2，请选择%arg3-%arg4名武将上场",
  ["xinghan reorganize"] = "重整阶段：双方选择新武将上场",
  
  ["xinghan_aozhan"] = "鏖战",
}

return rule
