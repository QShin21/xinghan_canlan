Fk:loadTranslationTable{
  ["xh__jianyan"] = "荐言",
  [":xh__jianyan"] = "出牌阶段各限一次，你可以声明一种牌的类别或颜色，然后连续亮出牌堆顶的牌，直到亮出符合你声明的牌为止，你将此牌交给一名男性角色。",

  ["#xh__jianyan"] = "荐言：声明牌的类别或颜色，亮出牌堆顶牌直到出现符合声明的牌，并交给一名男性角色",
  ["#xh__jianyan-give"] = "荐言：将%arg交给一名角色",

  ["$xh__jianyan1"] = "开言纳谏，社稷之福。",
  ["$xh__jianyan2"] = "如此如此，敌军自破！",
}

local jianyan = fk.CreateSkill{
  name = "xh__jianyan",
}

local MARK_COLOR = "xh__jianyan_color-phase"
local MARK_TYPE  = "xh__jianyan_type-phase"

jianyan:addEffect("active", {
  anim_type = "support",
  prompt = "#xh__jianyan",
  card_num = 0,
  target_num = 0,
  card_filter = Util.FalseFunc,

  can_use = function(self, player)
    return player.phase == Player.Play and
      (player:getMark(MARK_COLOR) == 0 or player:getMark(MARK_TYPE) == 0)
  end,

  interaction = function(self, player)
    local choices = {}
    if player:getMark(MARK_TYPE) == 0 then
      table.insertTable(choices, {"basic", "trick", "equip"})
    end
    if player:getMark(MARK_COLOR) == 0 then
      table.insertTable(choices, {"black", "red"})
    end
    return UI.ComboBox { choices = choices }
  end,

  on_use = function(self, room, effect)
    local player = effect.from
    local choice = self.interaction.data
    if not choice then
      if player:getMark(MARK_TYPE) == 0 then
        choice = "basic"
      else
        choice = "red"
      end
    end

    local function hasMatchInDrawPile()
      for _, id in ipairs(room.draw_pile) do
        local c = Fk:getCardById(id)
        if choice == "red" or choice == "black" then
          if c:getColorString() == choice then
            return true
          end
        else
          if c:getTypeString() == choice then
            return true
          end
        end
      end
      return false
    end

    if not hasMatchInDrawPile() then
      return false
    end

    if choice == "red" or choice == "black" then
      room:setPlayerMark(player, MARK_COLOR, 1)
    else
      room:setPlayerMark(player, MARK_TYPE, 1)
    end

    local revealed = {}
    local hit_id

    while true do
      local id = room:getNCards(1)[1]
      room:turnOverCardsFromDrawPile(player, { id }, jianyan.name)
      room:delay(300)
      local c = Fk:getCardById(id)

      local ok = false
      if choice == "red" or choice == "black" then
        ok = (c:getColorString() == choice)
      else
        ok = (c:getTypeString() == choice)
      end

      if ok then
        hit_id = id
        break
      else
        table.insert(revealed, id)
      end
    end

    local targets = table.filter(room.alive_players, function(p)
      return p:isMale()
    end)

    if #targets == 0 then
      table.insert(revealed, hit_id)
      room:cleanProcessingArea(revealed, jianyan.name)
      return
    end

    local to = room:askToChoosePlayers(player, {
      targets = targets,
      min_num = 1,
      max_num = 1,
      prompt = "#xh__jianyan-give:::" .. Fk:getCardById(hit_id):toLogString(),
      skill_name = jianyan.name,
      cancelable = false,
    })[1]

    local card = Fk:getCardById(hit_id)
    room:moveCardTo(card, Player.Hand, to, fk.ReasonGive, jianyan.name, nil, true, player)

    room:cleanProcessingArea(revealed, jianyan.name)
    room:cleanProcessingArea({ hit_id }, jianyan.name)
  end,
})

jianyan:addLoseEffect(function(self, player, is_death)
  local room = player.room
  room:setPlayerMark(player, MARK_COLOR, 0)
  room:setPlayerMark(player, MARK_TYPE, 0)
end)

return jianyan