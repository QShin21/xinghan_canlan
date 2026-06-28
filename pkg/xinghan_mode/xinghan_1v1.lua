-- SPDX-License-Identifier: GPL-3.0-or-later
-- 星汉灿烂 1v1 游戏模式核心逻辑
-- 规则：五局三胜制，每局构建武将池，胜方武将锁定，败方可收回

local desc_xinghan = [[
  # 星汉灿烂1v1模式简介

  星汉灿烂1v1模式选手需要在每轮比赛中构建自己的武将池，通过对武将进行调配、组合，在多局对战中取胜。

  ___

  ## 游戏流程

  1. **决定先后手**。一号位为主公（先手），二号位为内奸（后手）；每个小局结束后交换座位，以交替行动顺序。

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

  4. **上阵选择**。每小局选手从武将池中派出武将上场。

  5. **胜负判定**。胜方武将锁定不可再用，败方武将可收回。率先赢得3个小局且锁定区恰为5名武将的一方获得最终胜利。

  6. **上阵数量限制**。剩余可上阵武将为7或5名时可选单将或双将，6或4名时必须双将，3名时必须单将。

  ___

  ## 特殊规则

  - **先手惩罚**：先手方首轮摸牌阶段摸牌数减1。
  - **鏖战规则**：牌堆第2次洗牌后，【桃】视为【酒】；第3次洗牌后，每回合结束扣减1点体力。

]]

-- 从武将池中移除指定武将
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

-- 星汉灿烂游戏逻辑
local xinghan_1v1_getLogic = function()
  local xinghan_1v1_logic = GameLogic:subclass("xinghan_1v1_logic")

  function xinghan_1v1_logic:assignRoles()
    local room = self.room
    local players = room.players
    
    players[1].role = "lord"
    players[2].role = "renegade"
    
    for _, p in ipairs(players) do
      room:setPlayerProperty(p, "role_shown", true)
      room:broadcastProperty(p, "role")
    end
  end

  function xinghan_1v1_logic:chooseGenerals()
    local room = self.room
    
    -- 固定身份：一号位为主公（先手），二号位为内奸（后手）
    local first = room.players[1]   -- 一号位 = 主公 = 先手
    local second = room.players[2]  -- 二号位 = 内奸 = 后手
    
    -- 设置身份
    room:setPlayerProperty(first, "role", "lord")
    room:setPlayerProperty(first, "role_shown", true)
    room:broadcastProperty(first, "role")
    
    room:setPlayerProperty(second, "role", "renegade")
    room:setPlayerProperty(second, "role_shown", true)
    room:broadcastProperty(second, "role")
    
    room:setCurrent(first)
    
    -- 保存先手玩家ID到Banner
    room:setBanner("@xinghan_first_player", first.id)
    room:setBanner("@xinghan_second_player", second.id)
    
    room:sendLog{
      type = "#XinghanFirstPlayer",
      arg = "firstPlayer",
      toast = true,
    }
    
    -- 获取18张武将
    local all_generals = room:getNGenerals(18)
    
    -- 禁将阶段
    local function doBan(p, n)
      local prompt = "#xinghan-ban:::"..(p == first and "firstPlayer" or "secondPlayer")..":"..n
      local result = room:askToCustomDialog(p, {
        skill_name = "xinghan_1v1_mode",
        component = {
          url = "packages/xinghan_canlan/qml/XinghanSelect.qml",
          prop = {
            generals = all_generals,
            num = n,
            my_selected = {},
            ur_selected = {},
            prompt = prompt,
            is_ban = true,
          },
        },
      })
      
      local banned = {}
      if result ~= "" then
        for i, id in ipairs(result.ids) do
          local g = result.generals[i]
          table.insert(banned, g)
        end
      else
        -- 超时默认选择最左侧
        for i = 1, n do
          if #all_generals > 0 then
            table.insert(banned, all_generals[1])
          end
        end
      end
      
      -- 从武将池移除禁用的武将
      for _, g in ipairs(banned) do
        removeGeneral(all_generals, g)
      end
      
      return banned
    end
    
    -- 选将函数
    local function doChoose(p, n)
      local prompt = "#xinghan-choose:::"..(p == first and "firstPlayer" or "secondPlayer")..":"..n
      local result = room:askToCustomDialog(p, {
        skill_name = "xinghan_1v1_mode",
        component = {
          url = "packages/xinghan_canlan/qml/XinghanSelect.qml",
          prop = {
            generals = all_generals,
            num = n,
            my_selected = {},
            ur_selected = {},
            prompt = prompt,
            is_ban = false,
          },
        },
      })
      
      local chosen = {}
      if result ~= "" then
        for i, id in ipairs(result.ids) do
          local g = result.generals[i]
          table.insert(chosen, g)
        end
      else
        -- 超时默认选择最左侧
        for i = 1, n do
          if #all_generals > 0 then
            table.insert(chosen, all_generals[1])
          end
        end
      end
      
      -- 从武将池移除已选武将
      for _, g in ipairs(chosen) do
        removeGeneral(all_generals, g)
      end
      
      return chosen
    end
    
    -- 禁将阶段
    local banned = doBan(second, 1)
    room:sendLog{ type = "#XinghanBanLog", arg = "secondPlayer", arg2 = banned[1] or "", toast = true }
    
    banned = doBan(first, 2)
    room:sendLog{ type = "#XinghanBanLog", arg = "firstPlayer", arg2 = table.concat(banned, ", "), toast = true }
    
    banned = doBan(second, 1)
    room:sendLog{ type = "#XinghanBanLog", arg = "secondPlayer", arg2 = banned[1] or "", toast = true }
    
    -- 选将阶段
    local first_pool = {}
    local second_pool = {}
    local chosen
    
    -- 步骤1：后手方选择1名
    chosen = doChoose(second, 1)
    for _, g in ipairs(chosen) do table.insert(second_pool, g) end
    room:sendLog{ type = "#XinghanChooseLog", arg = "secondPlayer", arg2 = chosen[1] or "", toast = true }
    
    -- 步骤2：先手方选择2名
    chosen = doChoose(first, 2)
    for _, g in ipairs(chosen) do table.insert(first_pool, g) end
    room:sendLog{ type = "#XinghanChooseLog", arg = "firstPlayer", arg2 = table.concat(chosen, ", "), toast = true }
    
    -- 步骤3：后手方选择2名
    chosen = doChoose(second, 2)
    for _, g in ipairs(chosen) do table.insert(second_pool, g) end
    room:sendLog{ type = "#XinghanChooseLog", arg = "secondPlayer", arg2 = table.concat(chosen, ", "), toast = true }
    
    -- 步骤4：先手方选择2名
    chosen = doChoose(first, 2)
    for _, g in ipairs(chosen) do table.insert(first_pool, g) end
    room:sendLog{ type = "#XinghanChooseLog", arg = "firstPlayer", arg2 = table.concat(chosen, ", "), toast = true }
    
    -- 步骤5：后手方选择2名
    chosen = doChoose(second, 2)
    for _, g in ipairs(chosen) do table.insert(second_pool, g) end
    room:sendLog{ type = "#XinghanChooseLog", arg = "secondPlayer", arg2 = table.concat(chosen, ", "), toast = true }
    
    -- 步骤6：先手方选择2名
    chosen = doChoose(first, 2)
    for _, g in ipairs(chosen) do table.insert(first_pool, g) end
    room:sendLog{ type = "#XinghanChooseLog", arg = "firstPlayer", arg2 = table.concat(chosen, ", "), toast = true }
    
    -- 步骤7：后手方选择2名
    chosen = doChoose(second, 2)
    for _, g in ipairs(chosen) do table.insert(second_pool, g) end
    room:sendLog{ type = "#XinghanChooseLog", arg = "secondPlayer", arg2 = table.concat(chosen, ", "), toast = true }
    
    -- 步骤8：先手方获得剩余1名
    if #all_generals > 0 then
      table.insert(first_pool, all_generals[1])
      room:sendLog{ type = "#XinghanChooseLog", arg = "firstPlayer", arg2 = all_generals[1], toast = true }
    end
    
    -- 设置武将池显示
    room:setBanner("@&xinghan_first_pool", first_pool)
    room:setBanner("@&xinghan_second_pool", second_pool)
    
    -- 设置比分显示
    room:setBanner("@xinghan_round_wins", "小局获胜 0 : 0")
    
    -- 选择首发武将（可选单将或双将）
    room:doBroadcastNotify("ShowToast", Fk:translate("xinghan choose debut"))
    
    -- 先手选择（min=1, max=2）
    local first_prompt = "#xinghan-deploy:::firstPlayer:"..#first_pool..":1:2"
    local first_result = room:askToCustomDialog(first, {
      skill_name = "xinghan_1v1_mode",
      component = {
        url = "packages/xinghan_canlan/qml/XinghanDeploy.qml",
        prop = {
          generals = first_pool,
          minNum = 1,
          maxNum = 2,
          lockedGenerals = {},
          prompt = first_prompt,
        },
      },
    })
    
    local first_chosen = {}
    if first_result ~= "" then
      for i, id in ipairs(first_result.ids) do
        local g = first_result.generals[i]
        table.insert(first_chosen, g)
      end
    else
      table.insert(first_chosen, first_pool[1])
    end
    
    -- 后手选择（min=1, max=2）
    local second_prompt = "#xinghan-deploy:::secondPlayer:"..#second_pool..":1:2"
    local second_result = room:askToCustomDialog(second, {
      skill_name = "xinghan_1v1_mode",
      component = {
        url = "packages/xinghan_canlan/qml/XinghanDeploy.qml",
        prop = {
          generals = second_pool,
          minNum = 1,
          maxNum = 2,
          lockedGenerals = {},
          prompt = second_prompt,
        },
      },
    })
    
    local second_chosen = {}
    if second_result ~= "" then
      for i, id in ipairs(second_result.ids) do
        local g = second_result.generals[i]
        table.insert(second_chosen, g)
      end
    else
      table.insert(second_chosen, second_pool[1])
    end
    
    -- 设置先手武将（使用 changeHero 确保技能正确添加）
    room:changeHero(first, first_chosen[1], false, false, false, true, false)
    -- 处理副将：如果有副将则设置，否则清除之前的副将
    if #first_chosen > 1 then
      room:changeHero(first, first_chosen[2], false, true, false, true, false)
    else
      first.deputyGeneral = ""
      room:broadcastProperty(first, "deputyGeneral")
    end
    
    for _, g in ipairs(first_chosen) do
      removeGeneral(first_pool, g)
    end
    room:setBanner("@&xinghan_first_pool", first_pool)
    
    -- 设置后手武将（使用 changeHero 确保技能正确添加）
    room:changeHero(second, second_chosen[1], false, false, false, true, false)
    -- 处理副将：如果有副将则设置，否则清除之前的副将
    if #second_chosen > 1 then
      room:changeHero(second, second_chosen[2], false, true, false, true, false)
    else
      second.deputyGeneral = ""
      room:broadcastProperty(second, "deputyGeneral")
    end
    
    for _, g in ipairs(second_chosen) do
      removeGeneral(second_pool, g)
    end
    room:setBanner("@&xinghan_second_pool", second_pool)
    
    room:broadcastProperty(first, "kingdom")
    room:broadcastProperty(second, "kingdom")
    
    room:askToChooseKingdom(room.players)
  end

  return xinghan_1v1_logic
end

-- 构建星汉灿烂牌堆
local function build_xinghan_draw_pile()
  local draw_pile = {}
  local void = {}
  
  -- 获取星汉灿烂牌堆包中的所有卡牌
  local xinghan_cards_pkg = Fk.packages["xinghan_cards"]
  if xinghan_cards_pkg then
    for _, card in ipairs(xinghan_cards_pkg.cards) do
      table.insert(draw_pile, card.id)
    end
  end
  
  -- 将其他所有卡牌放入void区域
  for _, card in ipairs(Fk.cards) do
    if card.package and card.package.name ~= "xinghan_cards" then
      table.insert(void, card.id)
    end
  end
  
  return draw_pile, void
end

-- 创建游戏模式
local xinghan_1v1_mode = fk.CreateGameMode{
  name = "xinghan_1v1_mode",
  minPlayer = 2,
  maxPlayer = 2,
  rule = "#xinghan_1v1_rule&",
  logic = xinghan_1v1_getLogic,
  build_draw_pile = build_xinghan_draw_pile,
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
  
  ["#XinghanFirstPlayer"] = "主公（先手）获得先手权",
  ["#XinghanBanLog"] = "%arg 禁用了 %arg2",
  ["#XinghanChooseLog"] = "%arg 选择了 %arg2",
  
  ["firstPlayer"] = "主公（先手）",
  ["secondPlayer"] = "内奸（后手）",
  
  ["#xinghan-ban"] = "你是[%arg]，请禁用 %arg2 名武将",
  ["#xinghan-choose"] = "你是[%arg]，请选择 %arg2 名武将",
  
  ["xinghan choose debut"] = "请选择首发武将（可选1-2名）",
  
  ["@xinghan_round_wins"] = "小局获胜",
  ["@&xinghan_first_pool"] = "主公武将池",
  ["@&xinghan_second_pool"] = "内奸武将池",
  ["@&xinghan_first_locked"] = "主公已锁定",
  ["@&xinghan_second_locked"] = "内奸已锁定",
  
  ["#XinghanRoundWin"] = "%arg 获得小局胜利！当前比分 %arg2",
  ["#XinghanFinalWin"] = "%arg 获得3个小局胜利且锁定5名武将，赢得最终胜利！",
}

return xinghan_1v1_mode
