-- SPDX-License-Identifier: GPL-3.0-or-later
-- 星汉灿烂 1v1 游戏模式核心逻辑
-- 规则：五局三胜制，每局构建武将池，胜方武将锁定，败方可收回

local desc_xinghan = [[
  # 星汉灿烂1v1模式简介

  星汉灿烂1v1模式选手需要在每轮比赛中构建自己的武将池，通过对武将进行调配、组合，在多局对战中取胜。

  ___

  ## 游戏流程

  1. **决定先后手**。通过比点决定先后手，点数大的一方获得先手权，相同则重比。此后每小局先手、后手交替。

  2. **禁将阶段**。从公共武将牌堆中展示18张武将牌，按照以下顺序禁将：
     - 后手方禁用1名
     - 先手方禁用2名
     - 后手方禁用1名

  3. **选将阶段**。按照以下顺序选将：
     - 后手方选择1名
     - 先手方选择2名
     - 后手方选择2名
     - 先手方选择2名
     - 后手方选择2名
     - 先手方选择2名
     - 后手方选择2名
     - 先手方获得剩余1名

  4. **上阵选择**。每小局选手从武将池中派出1-2名武将上场。

  5. **胜负判定**。胜方武将锁定不可再用，败方武将可收回。当一方累计赢得5名武将时，该方获得本局胜利。

  6. **五局三胜**。先赢得三局的选手获得最终胜利。

  ___

  ## 特殊规则

  - **双将规则**：选双将时，靠近体力牌的决定性别与势力，体力值为二者之和的一半（向下取整）。
  - **先手惩罚**：先手方首轮摸牌阶段摸牌数减1。
  - **鏖战规则**：牌堆第2次洗牌后，【桃】视为【酒】；第3次洗牌后，每回合结束扣减1点体力。

]]

-- 从武将池中移除指定武将
local function removeGeneral(generals, g)
  local gt = Fk.generals[g].trueName
  for i, v in ipairs(generals) do
    if Fk.generals[v].trueName == gt then
      return table.remove(generals, i)
    end
  end
  return table.remove(generals, 1)
end

-- 获取武将索引
local function getGeneralIndex(generals, g)
  for i, v in ipairs(generals) do
    if v == g then
      return i - 1  -- 返回从0开始的索引
    end
  end
  return 0
end

-- 星汉灿烂游戏逻辑
local xinghan_1v1_getLogic = function()
  local xinghan_1v1_logic = GameLogic:subclass("xinghan_1v1_logic")

  -- 存储游戏状态
  local game_state = {
    round_count = 0,           -- 当前局数
    first_player = nil,        -- 先手玩家
    second_player = nil,       -- 后手玩家
    first_wins = 0,            -- 先手胜局数
    second_wins = 0,           -- 后手胜局数
    first_generals_pool = {},  -- 先手武将池
    second_generals_pool = {}, -- 后手武将池
    first_locked = {},         -- 先手已锁定武将
    second_locked = {},        -- 后手已锁定武将
    first_won_count = 0,       -- 先手累计获胜武将数
    second_won_count = 0,      -- 后手累计获胜武将数
    current_first = true,      -- 当前小局先手
    shuffle_count = 0,         -- 洗牌次数
  }

  function xinghan_1v1_logic:assignRoles()
    local room = self.room
    local players = room.players
    
    -- 随机分配角色
    players[1].role = "lord"
    players[2].role = "renegade"
    
    for _, p in ipairs(players) do
      room:setPlayerProperty(p, "role_shown", true)
      room:broadcastProperty(p, "role")
    end
  end

  function xinghan_1v1_logic:chooseGenerals()
    local room = self.room
    local lord = room.players[1]
    local nonlord = room.players[2]
    
    room:setCurrent(lord)
    
    -- 比点决定先后手
    local first, second
    local lord_point = math.random(1, 6)
    local nonlord_point = math.random(1, 6)
    
    while lord_point == nonlord_point do
      lord_point = math.random(1, 6)
      nonlord_point = math.random(1, 6)
    end
    
    if lord_point > nonlord_point then
      first = lord
      second = nonlord
    else
      first = nonlord
      second = lord
    end
    
    game_state.first_player = first
    game_state.second_player = second
    
    -- 保存先手玩家ID到Banner
    room:setBanner("@xinghan_first_player", first.id)
    room:setBanner("@xinghan_second_player", second.id)
    
    room:sendLog{
      type = "#XinghanFirstPlayer",
      arg = first == lord and "firstPlayer" or "secondPlayer",
      toast = true,
    }
    
    -- 获取18张武将
    local all_generals = room:getNGenerals(18)
    local first_selected = {}
    local second_selected = {}
    
    -- 更新武将池显示
    local updateGeneralPile = function(p, generals)
      if p == first then
        room:setBanner("@&xinghan_first_pool", generals)
      else
        room:setBanner("@&xinghan_second_pool", generals)
      end
    end
    
    -- 禁将/选将通用函数
    local function askForGeneral(p, n, is_ban, prompt_key)
      local my_selected = (p == first) and first_selected or second_selected
      local ur_selected = (p == first) and second_selected or first_selected
      local prompt = "#xinghan-"..prompt_key..":::"..(p == first and "firstPlayer" or "secondPlayer")..":"..n
      
      local result = room:askToCustomDialog(p, {
        skill_name = "xinghan_1v1_mode",
        qml_path = "packages/xinghan_canlan/qml/XinghanSelect.qml",
        extra_data = {
          all_generals, n, my_selected, ur_selected, prompt, is_ban
        }
      })
      
      local selected = {}
      if result ~= "" then
        for i, id in ipairs(result.ids) do
          local g = result.generals[i]
          all_generals[id + 1] = g
          table.insert(my_selected, id)
          table.insert(selected, g)
        end
      else
        -- 超时默认选择最左侧
        local selected_list = table.connect(my_selected, ur_selected)
        for i, g in ipairs(all_generals) do
          if not table.contains(selected_list, i - 1) then
            table.insert(my_selected, i - 1)
            table.insert(selected, g)
            if #selected == n then break end
          end
        end
      end
      
      return selected
    end
    
    -- 禁将阶段
    -- 步骤1：后手方禁用1名
    local banned = askForGeneral(second, 1, true, "ban")
    for _, g in ipairs(banned) do
      removeGeneral(all_generals, g)
    end
    room:sendLog{ type = "#XinghanBanLog", arg = "secondPlayer", arg2 = banned[1], toast = true }
    
    -- 步骤2：先手方禁用2名
    banned = askForGeneral(first, 2, true, "ban")
    for _, g in ipairs(banned) do
      removeGeneral(all_generals, g)
    end
    room:sendLog{ type = "#XinghanBanLog", arg = "firstPlayer", arg2 = table.concat(banned, ", "), toast = true }
    
    -- 步骤3：后手方禁用1名
    banned = askForGeneral(second, 1, true, "ban")
    for _, g in ipairs(banned) do
      removeGeneral(all_generals, g)
    end
    room:sendLog{ type = "#XinghanBanLog", arg = "secondPlayer", arg2 = banned[1], toast = true }
    
    -- 重置选择状态
    first_selected = {}
    second_selected = {}
    
    -- 选将阶段
    local first_pool = {}
    local second_pool = {}
    
    -- 步骤1：后手方选择1名
    local chosen = askForGeneral(second, 1, false, "choose")
    for _, g in ipairs(chosen) do
      table.insert(second_pool, g)
      removeGeneral(all_generals, g)
    end
    room:sendLog{ type = "#XinghanChooseLog", arg = "secondPlayer", arg2 = chosen[1], toast = true }
    
    -- 步骤2：先手方选择2名
    chosen = askForGeneral(first, 2, false, "choose")
    for _, g in ipairs(chosen) do
      table.insert(first_pool, g)
      removeGeneral(all_generals, g)
    end
    room:sendLog{ type = "#XinghanChooseLog", arg = "firstPlayer", arg2 = table.concat(chosen, ", "), toast = true }
    
    -- 步骤3：后手方选择2名
    chosen = askForGeneral(second, 2, false, "choose")
    for _, g in ipairs(chosen) do
      table.insert(second_pool, g)
      removeGeneral(all_generals, g)
    end
    room:sendLog{ type = "#XinghanChooseLog", arg = "secondPlayer", arg2 = table.concat(chosen, ", "), toast = true }
    
    -- 步骤4：先手方选择2名
    chosen = askForGeneral(first, 2, false, "choose")
    for _, g in ipairs(chosen) do
      table.insert(first_pool, g)
      removeGeneral(all_generals, g)
    end
    room:sendLog{ type = "#XinghanChooseLog", arg = "firstPlayer", arg2 = table.concat(chosen, ", "), toast = true }
    
    -- 步骤5：后手方选择2名
    chosen = askForGeneral(second, 2, false, "choose")
    for _, g in ipairs(chosen) do
      table.insert(second_pool, g)
      removeGeneral(all_generals, g)
    end
    room:sendLog{ type = "#XinghanChooseLog", arg = "secondPlayer", arg2 = table.concat(chosen, ", "), toast = true }
    
    -- 步骤6：先手方选择2名
    chosen = askForGeneral(first, 2, false, "choose")
    for _, g in ipairs(chosen) do
      table.insert(first_pool, g)
      removeGeneral(all_generals, g)
    end
    room:sendLog{ type = "#XinghanChooseLog", arg = "firstPlayer", arg2 = table.concat(chosen, ", "), toast = true }
    
    -- 步骤7：后手方选择2名
    chosen = askForGeneral(second, 2, false, "choose")
    for _, g in ipairs(chosen) do
      table.insert(second_pool, g)
      removeGeneral(all_generals, g)
    end
    room:sendLog{ type = "#XinghanChooseLog", arg = "secondPlayer", arg2 = table.concat(chosen, ", "), toast = true }
    
    -- 步骤8：先手方获得剩余1名
    if #all_generals > 0 then
      table.insert(first_pool, all_generals[1])
      room:sendLog{ type = "#XinghanChooseLog", arg = "firstPlayer", arg2 = all_generals[1], toast = true }
    end
    
    -- 保存武将池
    game_state.first_generals_pool = first_pool
    game_state.second_generals_pool = second_pool
    
    -- 设置武将池显示
    updateGeneralPile(first, first_pool)
    updateGeneralPile(second, second_pool)
    
    -- 设置比分显示
    room:setBanner("@xinghan_score", "0 : 0")
    room:setBanner("@xinghan_round", "第 1 局")
    room:setBanner("@xinghan_won", "获胜武将 0 : 0")
    
    -- 选择首发武将
    room:doBroadcastNotify("ShowToast", Fk:translate("xinghan choose debut"))
    
    local req = Request:new(room.players, "AskForGeneral")
    req.timeout = room:getSettings('generalTimeout')
    req:setData(first, { first_pool, 2 })  -- 可选1-2名武将
    req:setData(second, { second_pool, 2 })
    req:setDefaultReply(first, { first_pool[1] })
    req:setDefaultReply(second, { second_pool[1] })
    req:ask()
    
    -- 设置玩家武将
    for _, p in ipairs(room.players) do
      local pool = (p == first) and first_pool or second_pool
      local chosen_generals = req:getResult(p)
      
      if #chosen_generals == 1 then
        -- 单将
        room:setPlayerGeneral(p, chosen_generals[1], true, true)
        removeGeneral(pool, chosen_generals[1])
      else
        -- 双将
        room:setPlayerGeneral(p, chosen_generals[1], true, true)
        -- 设置副将
        room:setPlayerProperty(p, "deputyGeneral", chosen_generals[2])
        removeGeneral(pool, chosen_generals[1])
        removeGeneral(pool, chosen_generals[2])
      end
      
      -- 更新武将池
      updateGeneralPile(p, pool)
    end
    
    room:broadcastProperty(first, "general")
    room:broadcastProperty(second, "general")
    room:broadcastProperty(first, "kingdom")
    room:broadcastProperty(second, "kingdom")
    
    room:askToChooseKingdom(room.players)
  end

  return xinghan_1v1_logic
end

-- 创建游戏模式
local xinghan_1v1_mode = fk.CreateGameMode{
  name = "xinghan_1v1_mode",
  minPlayer = 2,
  maxPlayer = 2,
  rule = "#xinghan_1v1_rule&",
  logic = xinghan_1v1_getLogic,
  surrender_func = function(self, playedTime)
    return { 
      { text = "time limitation: 2 min", passed = playedTime >= 120 } 
    }
  end,
}

-- 翻译
Fk:loadTranslationTable{
  ["xinghan_1v1_mode"] = "星汉灿烂",
  [":xinghan_1v1_mode"] = desc_xinghan,
  
  ["#XinghanFirstPlayer"] = "%arg 获得先手权",
  ["#XinghanBanLog"] = "%arg 禁用了 %arg2",
  ["#XinghanChooseLog"] = "%arg 选择了 %arg2",
  
  ["firstPlayer"] = "先手",
  ["secondPlayer"] = "后手",
  
  ["#xinghan-ban"] = "你是[%arg]，请禁用 %arg2 名武将",
  ["#xinghan-choose"] = "你是[%arg]，请选择 %arg2 名武将",
  
  ["xinghan choose debut"] = "请选择首发武将（可选1-2名）",
  
  ["@xinghan_score"] = "比分",
  ["@xinghan_round"] = "局数",
  ["@xinghan_won"] = "获胜武将数",
  ["@&xinghan_first_pool"] = "先手武将池",
  ["@&xinghan_second_pool"] = "后手武将池",
  ["@&xinghan_first_locked"] = "先手已锁定",
  ["@&xinghan_second_locked"] = "后手已锁定",
  
  ["#XinghanScore"] = "比分 先手 %arg : %arg2 后手",
  ["#XinghanWonCount"] = "获胜武将 先手 %arg : %arg2 后手",
  ["#XinghanRoundWin"] = "%arg 赢得本局胜利！当前比分 %arg2",
}

return xinghan_1v1_mode
