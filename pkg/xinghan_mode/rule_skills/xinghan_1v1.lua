-- SPDX-License-Identifier: GPL-3.0-or-later
-- 星汉灿烂 1v1 规则技能
-- 包含：先手惩罚、胜负判定、武将锁定、鏖战规则

local rule = fk.CreateSkill {
  name = "#xinghan_1v1_rule&",
}

local U = require "packages.xinghan_canlan.pkg.xinghan_mode.xinghan_util"

local function newGameState()
  return {
    first_round_wins = 0,       -- 主公小局获胜场数
    second_round_wins = 0,      -- 内奸小局获胜场数
    shuffle_count = 0,
    peach_as_wine = false,
    hp_damage_active = false,
    first_draw_penalty = false, -- 当前小局一号位摸牌惩罚标记
    in_reorganize = false,      -- 是否处于重整阶段
  }
end

-- 按房间隔离状态，避免多个房间或连续开局时串场。
local game_states = setmetatable({}, { __mode = "k" })

local function getGameState(room)
  if not room then return newGameState() end
  if not game_states[room] then
    game_states[room] = newGameState()
  end
  return game_states[room]
end

local function resetGameState(room)
  local state = newGameState()
  if room then
    game_states[room] = state
  end
  return state
end

local function getGeneralTrueName(g)
  local general = g and Fk.generals[g]
  return general and (general.trueName or g) or g
end

local function containsGeneral(generals, general)
  if not generals or not general then return false end
  local true_name = getGeneralTrueName(general)
  for _, g in ipairs(generals) do
    if getGeneralTrueName(g) == true_name then
      return true
    end
  end
  return false
end

local function addGeneral(generals, general)
  if not generals or not general or not Fk.generals[general] then return end
  if not containsGeneral(generals, general) then
    table.insert(generals, general)
  end
end

local function getDialogGenerals(result, source, min_num, max_num)
  local chosen = {}
  max_num = math.min(max_num or #source, #source)
  min_num = math.min(min_num or max_num, max_num)

  if type(result) == "table" then
    if type(result.generals) == "table" then
      for _, general in ipairs(result.generals) do
        if #chosen >= max_num then break end
        addGeneral(chosen, general)
      end
    elseif type(result.ids) == "table" then
      for _, id in ipairs(result.ids) do
        if #chosen >= max_num then break end
        local index = tonumber(id)
        if index then
          addGeneral(chosen, source[index + 1])
        end
      end
    end
  end

  for _, general in ipairs(source) do
    if #chosen >= min_num then break end
    addGeneral(chosen, general)
  end

  return chosen
end

-- 从武将池中移除武将
local function removeGeneral(generals, g)
  if not generals or #generals == 0 or not g then return nil end
  local gt = getGeneralTrueName(g)
  for i, v in ipairs(generals) do
    if getGeneralTrueName(v) == gt then
      return table.remove(generals, i)
    end
  end
  return nil
end

-- 判断是否为主公（用于计分和武将池）
local function isLord(player)
  return player.role == "lord"
end

-- 判断是否为一号位（用于行动顺序）
local function isFirstSeat(player)
  return player and player.seat == 1
end

-- 获取玩家武将池（按身份）
local function getGeneralPool(player)
  local room = player.room
  if isLord(player) then
    return room:getBanner("@&xinghan_first_pool") or {}
  else
    return room:getBanner("@&xinghan_second_pool") or {}
  end
end

-- 获取已锁定武将（按身份）
local function getLockedGenerals(player)
  local room = player.room
  if isLord(player) then
    return room:getBanner("@&xinghan_first_locked") or {}
  else
    return room:getBanner("@&xinghan_second_locked") or {}
  end
end

-- 添加锁定武将（按身份）
local function addLockedGeneral(player, general)
  local room = player.room
  local locked = getLockedGenerals(player)
  addGeneral(locked, general)
  if isLord(player) then
    room:setBanner("@&xinghan_first_locked", locked)
  else
    room:setBanner("@&xinghan_second_locked", locked)
  end
end

-- 根据可选武将数量计算可选范围
-- 7、5：可选单将或双将 (1-2)
-- 6、4：仅可选双将 (2)
-- 3：仅可选单将 (1)
local function getDeployRange(available_count)
  if available_count == 7 or available_count == 5 then
    return 1, 2  -- 可选单将或双将
  elseif available_count == 6 or available_count == 4 then
    return 2, 2  -- 仅可选双将
  elseif available_count == 3 then
    return 1, 1  -- 仅可选单将
  else
    -- 其他情况（如2、1），根据实际情况
    return 1, math.min(2, available_count)
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

local function drawInitialHands(room, players, default_num)
  local draw_data_map = {}
  local max_num = 0

  for _, player in ipairs(players) do
    if player and not player.dead then
      local draw_data = DrawInitialData:new{ num = default_num }
      room.logic:trigger(fk.DrawInitialCards, player, draw_data)
      draw_data.cards = {}
      draw_data_map[player.id] = draw_data
      max_num = math.max(max_num, draw_data.num or 0)
    end
  end

  for i = 1, max_num do
    for _, player in ipairs(players) do
      local draw_data = player and draw_data_map[player.id]
      if draw_data and i <= (draw_data.num or 0) then
        local cards = drawInit(room, player, 1)
        for _, id in ipairs(cards) do
          table.insert(draw_data.cards, id)
        end
      end
    end
  end

  for _, player in ipairs(players) do
    local draw_data = player and draw_data_map[player.id]
    if draw_data then
      room.logic:trigger(fk.AfterDrawInitialCards, player, draw_data)
    end
  end
end

-- 选择武将函数
local function askForDeploy(room, player, available, min_num, max_num)
  if #available == 0 then return nil end
  
  min_num = math.min(min_num, #available)
  max_num = math.min(max_num, #available)
  if max_num < min_num then
    max_num = min_num
  end
  
  local prompt = "#xinghan-deploy:::"..(isLord(player) and "firstPlayer" or "secondPlayer")..":"..#available..":"..min_num..":"..max_num
  local result = room:askToCustomDialog(player, {
    skill_name = "xinghan_1v1_mode",
    qml_path = "packages/xinghan_canlan/qml/XinghanDeploy.qml",
    extra_data = {
      available, min_num, max_num, {}, prompt
    }
  })
  
  return getDialogGenerals(result, available, min_num, max_num)
end

local function triggerDebutGenerals(room, player)
  if not room or not player then return end
  if player.general and player.general ~= "" then
    room.logic:trigger(U.Debut, player, player.general, false)
  end
  if player.deputyGeneral and player.deputyGeneral ~= "" then
    room.logic:trigger(U.Debut, player, player.deputyGeneral, false)
  end
end

-- 登场效果
rule:addEffect(fk.GameStart, {
  can_refresh = function(self, event, target, player, data)
    return player.room.current == player
  end,
  on_refresh = function(self, event, target, player, data)
    local room = player.room
    resetGameState(room)
    triggerDebutGenerals(room, player)
    triggerDebutGenerals(room, player.next)
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

-- 先手第一回合少摸一张牌（按座位判断）
rule:addEffect(fk.DrawNCards, {
  can_refresh = function(self, event, target, player, data)
    local state = getGameState(player.room)
    return target == player and isFirstSeat(player) and not state.first_draw_penalty
  end,
  on_refresh = function(self, event, target, player, data)
    local state = getGameState(player.room)
    state.first_draw_penalty = true
    data.n = math.max(0, (data.n or 0) - 1)
  end,
})

-- 胜负判定
rule:addEffect(fk.GameOverJudge, {
  can_refresh = function(self, event, target, player, data)
    return target == player
  end,
  on_refresh = function(self, event, target, player, data)
    local room = player.room
    local state = getGameState(room)
    room:setTag("SkipGameRule", true)
    
    if player.rest > 0 then return end
    
    local winner = player.next  -- 小局获胜方（存活方/击杀方）
    local loser = player        -- 小局失败方（死亡方/被击杀方）
    
    -- 更新小局获胜场数（按身份计分）
    -- 主公死亡 → 内奸获得小局胜利
    -- 内奸死亡 → 主公获得小局胜利
    if isLord(loser) then
      -- 主公死亡，内奸获得小局胜利
      state.second_round_wins = state.second_round_wins + 1
    else
      -- 内奸死亡，主公获得小局胜利
      state.first_round_wins = state.first_round_wins + 1
    end
    
    -- 锁定小局获胜方的武将
    addLockedGeneral(winner, winner.general)
    if winner.deputyGeneral and winner.deputyGeneral ~= "" then
      addLockedGeneral(winner, winner.deputyGeneral)
    end
    
    -- 小局失败方的武将不锁定，加回到武将池中
    local loser_pool = getGeneralPool(loser)
    addGeneral(loser_pool, loser.general)
    if loser.deputyGeneral and loser.deputyGeneral ~= "" then
      addGeneral(loser_pool, loser.deputyGeneral)
    end
    if isLord(loser) then
      room:setBanner("@&xinghan_first_pool", loser_pool)
    else
      room:setBanner("@&xinghan_second_pool", loser_pool)
    end
    
    -- 更新显示
    room:setBanner("@xinghan_round_wins", string.format("小局获胜 %d : %d",
      state.first_round_wins, state.second_round_wins))
    
    room:sendLog{
      type = "#XinghanRoundWin",
      arg = isLord(winner) and "firstPlayer" or "secondPlayer",
      arg2 = string.format("%d : %d", state.first_round_wins, state.second_round_wins),
      toast = true,
    }
    
    -- 判断是否获得最终胜利
    -- 条件：小局获胜场数达到3
    if state.first_round_wins >= 3 then
      -- 主公小局获胜3场，主公获胜
      room:sendLog{
        type = "#XinghanFinalWin",
        arg = "firstPlayer",
        toast = true,
      }
      room:gameOver("lord")
      return
      
    elseif state.second_round_wins >= 3 then
      -- 内奸小局获胜3场，内奸获胜
      room:sendLog{
        type = "#XinghanFinalWin",
        arg = "secondPlayer",
        toast = true,
      }
      room:gameOver("renegade")
      return
    end
  end,
})

-- 死亡换将（重整阶段）
rule:addEffect(fk.BuryVictim, {
  can_refresh = function(self, event, target, player, data)
    return target == player
  end,
  on_refresh = function(self, event, target, player, data)
    local room = player.room
    local state = getGameState(room)
    room:setTag("SkipGameRule", true)
    
    if player.rest > 0 then return end
    
    local loser_pool = getGeneralPool(player)
    local loser_locked = getLockedGenerals(player)
    
    local loser_available = {}
    for _, g in ipairs(loser_pool) do
      if not containsGeneral(loser_locked, g) then
        table.insert(loser_available, g)
      end
    end
    
    player:bury()
    
    local winner = player.next
    local winner_pool = getGeneralPool(winner)
    local winner_locked = getLockedGenerals(winner)
    
    local winner_available = {}
    for _, g in ipairs(winner_pool) do
      if not containsGeneral(winner_locked, g) then
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
    
    -- 设置重整阶段标记
    state.in_reorganize = true
    
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
      
      -- 双方所有区域的牌全部进入弃牌堆
      -- 胜方弃牌
      winner:throwAllCards("h")
      winner:throwAllCards("e")
      winner:throwAllCards("j")
      -- 败方弃牌（虽然已经死亡，但可能有判定区的牌）
      player:throwAllCards("j")
      
      -- 根据可选武将数量计算选将范围
      local loser_min, loser_max = getDeployRange(#loser_available)
      local winner_min, winner_max = getDeployRange(#winner_available)
      
      local loser_chosen = askForDeploy(room, player, loser_available, loser_min, loser_max)
      if not loser_chosen or #loser_chosen == 0 then
        loser_chosen = { loser_available[1] }
      end
      
      for _, g in ipairs(loser_chosen) do
        removeGeneral(loser_pool, g)
      end
      
      if isLord(player) then
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
      
      if isLord(winner) then
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
      
      -- 计算败方新体力值（双将取平均值）
      local loser_hp = Fk.generals[loser_chosen[1]].hp
      if #loser_chosen > 1 then
        loser_hp = math.floor((loser_hp + Fk.generals[loser_chosen[2]].hp) / 2)
      end
      
      -- 判断败方是否更换了武将（主将或副将）
      local loser_general_changed = (player.general ~= loser_chosen[1])
      local loser_deputy_changed = (player.deputyGeneral ~= (loser_chosen[2] or ""))
      
      -- 只有在武将改变时才清理技能
      if loser_general_changed or loser_deputy_changed then
        local loser_old_skills = player:getSkillNameList()
        if #loser_old_skills > 0 then
          local skills_to_remove = {}
          for _, skill_name in ipairs(loser_old_skills) do
            table.insert(skills_to_remove, "-" .. skill_name)
          end
          room:handleAddLoseSkills(player, table.concat(skills_to_remove, "|"), nil, false, false)
        end
      end
      
      -- 使用 changeHero 设置败方武将（maxHpChange=false，不自动改变体力上限）
      room:changeHero(player, loser_chosen[1], false, false, false, false, false)
      if #loser_chosen > 1 then
        room:changeHero(player, loser_chosen[2], false, true, false, false, false)
      else
        player.deputyGeneral = ""
        room:broadcastProperty(player, "deputyGeneral")
      end
      
      room:revivePlayer(player, false)
      
      -- 设置败方体力和体力上限
      room:setPlayerProperty(player, "hp", loser_hp)
      room:setPlayerProperty(player, "maxHp", loser_hp)
      
      -- 计算胜方新体力值（双将取平均值）
      local winner_hp = Fk.generals[winner_chosen[1]].hp
      if #winner_chosen > 1 then
        winner_hp = math.floor((winner_hp + Fk.generals[winner_chosen[2]].hp) / 2)
      end
      
      -- 判断胜方是否更换了武将（主将或副将）
      local winner_general_changed = (winner.general ~= winner_chosen[1])
      local winner_deputy_changed = (winner.deputyGeneral ~= (winner_chosen[2] or ""))
      
      -- 只有在武将改变时才清理技能
      if winner_general_changed or winner_deputy_changed then
        local winner_old_skills = winner:getSkillNameList()
        if #winner_old_skills > 0 then
          local skills_to_remove = {}
          for _, skill_name in ipairs(winner_old_skills) do
            table.insert(skills_to_remove, "-" .. skill_name)
          end
          room:handleAddLoseSkills(winner, table.concat(skills_to_remove, "|"), nil, false, false)
        end
      end
      
      -- 使用 changeHero 设置胜方武将（maxHpChange=false，不自动改变体力上限）
      room:changeHero(winner, winner_chosen[1], false, false, false, false, false)
      if #winner_chosen > 1 then
        room:changeHero(winner, winner_chosen[2], false, true, false, false, false)
      else
        winner.deputyGeneral = ""
        room:broadcastProperty(winner, "deputyGeneral")
      end
      
      -- 设置胜方体力和体力上限
      room:setPlayerProperty(winner, "hp", winner_hp)
      room:setPlayerProperty(winner, "maxHp", winner_hp)
      
      -- 交换座位（不改变身份）
      local p1 = room.players[1]
      local p2 = room.players[2]
      if p1 and p2 then
        room:swapSeat(p1, p2, true)  -- arrange_turn=true，更新回合顺序
      end
      
      -- 重置第一次摸牌惩罚标记
      state.first_draw_penalty = false
      
      -- 触发登场效果
      triggerDebutGenerals(room, room.players[1])
      triggerDebutGenerals(room, room.players[2])
      
      -- 双方按座位顺序轮流各摸1张，直到达到起始手牌数。
      drawInitialHands(room, { room.players[1], room.players[2] }, 4)
      
      -- 获取当前回合玩家
      local current_player = room.current
      if current_player then
        -- 定义所有阶段
        local phases = { Player.Start, Player.Judge, Player.Draw, Player.Play, Player.Discard, Player.Finish }
        
        if isFirstSeat(current_player) then
          -- 当前是一号位的回合
          -- 判断并跳过所有能跳过的阶段
          for _, phase in ipairs(phases) do
            if current_player:canSkip(phase) then
              current_player:skip(phase)
            end
          end
          -- 获得一个额外回合
          current_player:gainAnExtraTurn(false, "xinghan_reorganize", nil, nil)
          -- 结束当前阶段
          current_player:endCurrentPhase()
        else
          -- 当前是二号位的回合
          -- 判断并跳过所有能跳过的阶段
          for _, phase in ipairs(phases) do
            if current_player:canSkip(phase) then
              current_player:skip(phase)
            end
          end
          -- 结束当前阶段
          current_player:endCurrentPhase()
        end
      end
      
      -- 重置重整阶段标记
      state.in_reorganize = false
    end)
  end,
})

-- 洗牌计数（鏖战规则）
rule:addEffect(fk.AfterDrawPileShuffle, {
  can_refresh = function(self, event, target, player, data)
    return true
  end,
  on_refresh = function(self, event, target, player, data)
    local room = player and player.room or target and target.room
    if not room then return end
    local state = getGameState(room)
    state.shuffle_count = state.shuffle_count + 1
    
    room:sendLog{
      type = "#XinghanShuffle",
      arg = state.shuffle_count,
      toast = true,
    }
    
    if state.shuffle_count == 2 then
      state.peach_as_wine = true
      room:sendLog{
        type = "#XinghanPeachAsWine",
        toast = true,
      }
    end
    
    if state.shuffle_count >= 3 then
      state.hp_damage_active = true
    end
  end,
})

local function isAnalepticPattern(pattern)
  if not pattern then return false end
  return string.find(pattern, "analeptic", 1, true) ~= nil
    or string.find(pattern, "wine", 1, true) ~= nil
end

-- 鏖战：桃可以作为酒使用
rule:addEffect(fk.AskForCardUse, {
  mute = true,
  can_trigger = function(self, event, target, player, data)
    local state = getGameState(player.room)
    return target == player and state.peach_as_wine and isAnalepticPattern(data.pattern)
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local pattern = data.pattern
    
    if isAnalepticPattern(pattern) then
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
    local state = getGameState(player.room)
    return target == player and state.hp_damage_active and not player.dead
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
  ["#XinghanRoundWin"] = "%arg 获得小局胜利！当前比分 %arg2",
  ["#XinghanFinalWin"] = "%arg 获得最终胜利！",
  
  ["#xinghan-deploy"] = "你是[%arg]，可选武将数：%arg2，请选择%arg3-%arg4名武将上场",
  ["xinghan reorganize"] = "重整阶段：双方选择新武将上场",
  
  ["xinghan_aozhan"] = "鏖战",
}

return rule
