local xingluan = fk.CreateSkill{
  name = "xh__xingluan",
}

Fk:loadTranslationTable{
  ["xh__xingluan"] = "兴乱",
  [":xh__xingluan"] = "出牌阶段限一次，当你使用仅指定一个目标的牌结算完毕后，你可以将牌堆顶六张牌置入弃牌堆，然后从弃牌堆中选择一张点数为6且上个回合未选择的牌名的牌获得。",
  ["#xh__xingluan-invoke"] = "兴乱：你可以将牌堆顶六张牌置入弃牌堆，然后从弃牌堆获得一张点数为6且上回合未选牌名的牌",
  ["#xh__xingluan-pick"] = "兴乱：请选择要获得的牌",

  ["$xh__xingluan1"] = "大兴兵争，长安当乱。",
  ["$xh__xingluan2"] = "勇猛兴军，乱世当立。",
}

local LAST_MARK = "xh__xingluan_last"
local THIS_MARK = "xh__xingluan_this"
local PENDING_MARK = "xh__xingluan_pending"

local function getCardTrueName(id)
  local c = Fk:getCardById(id)
  if not c then return nil end
  return c.trueName or c.name
end

local function getRealCardIds(card)
  if not card then return {} end
  if card:isVirtual() then
    return card.subcards or {}
  end
  if card.id then
    return { card.id }
  end
  return {}
end

local function doXingluanEffect(player)
  local room = player.room
  local skillName = xingluan.name

  local top6 = room:getNCards(6, "top")
  if top6 and #top6 > 0 then
    room:moveCardTo(top6, Card.DiscardPile, nil, fk.ReasonPutIntoDiscardPile, skillName, nil, true, player)
  end

  local last_tbl = player:getTableMark(LAST_MARK)
  local last_name = nil
  if last_tbl and #last_tbl > 0 then
    last_name = last_tbl[1]
  end

  local candidates = {}
  for _, id in ipairs(room.discard_pile) do
    local c = Fk:getCardById(id)
    if c and c.number == 6 then
      local tn = c.trueName or c.name
      if not last_name or tn ~= last_name then
        table.insert(candidates, id)
      end
    end
  end

  if #candidates == 0 or player.dead then
    return
  end

  local chosen_id
  if #candidates == 1 then
    chosen_id = candidates[1]
  else
    room:fillAG(player, candidates)
    chosen_id = room:askToAG(player, {
      skill_name = skillName,
      prompt = "#xh__xingluan-pick",
      cancelable = false,
    })
    room:closeAG(player)
  end

  if not chosen_id or player.dead then return end
  room:obtainCard(player, chosen_id, true, fk.ReasonGetFromDiscard, player, skillName)

  local tn = getCardTrueName(chosen_id)
  room:setPlayerMark(player, THIS_MARK, 0)
  if tn then
    room:addTableMark(player, THIS_MARK, tn)
  end
end

-- 回合开始：静默搬运标记，不弹提示
xingluan:addEffect(fk.TurnStart, {
  can_refresh = function(self, event, target, player, data)
    return target == player and player:hasSkill(xingluan.name)
  end,
  on_refresh = function(self, event, target, player, data)
    local room = player.room

    local t = player:getTableMark(THIS_MARK)
    room:setPlayerMark(player, THIS_MARK, 0)

    if t and #t > 0 then
      room:setPlayerMark(player, LAST_MARK, 0)
      room:addTableMark(player, LAST_MARK, t[1])
    else
      room:setPlayerMark(player, LAST_MARK, 0)
    end

    room:setPlayerMark(player, PENDING_MARK, 0)
  end,
})

-- 第一段：牌结算完毕时，先记录“等待该牌真正进入弃牌堆”
-- 若没有实体牌需要等待，则直接正常询问
xingluan:addEffect(fk.CardUseFinished, {
  anim_type = "control",

  can_trigger = function(self, event, target, player, data)
    if target ~= player then return false end
    if not player:hasSkill(xingluan.name) then return false end
    if player.phase ~= Player.Play then return false end
    if player:usedSkillTimes(xingluan.name, Player.HistoryPhase) > 0 then return false end
    if not data or not data.tos then return false end
    if #data.tos ~= 1 then return false end

    local room = player.room
    local ids = getRealCardIds(data.card)
    local wait_ids = {}

    for _, id in ipairs(ids) do
      if room:getCardArea(id) == Card.Processing then
        table.insert(wait_ids, id)
      end
    end

    room:setPlayerMark(player, PENDING_MARK, 0)
    if #wait_ids > 0 then
      for _, id in ipairs(wait_ids) do
        room:addTableMark(player, PENDING_MARK, id)
      end
      return false
    end

    return true
  end,

  on_cost = function(self, event, target, player, data)
    return player.room:askToSkillInvoke(player, {
      skill_name = xingluan.name,
      prompt = "#xh__xingluan-invoke",
    })
  end,

  on_use = function(self, event, target, player, data)
    doXingluanEffect(player)
  end,
})

-- 第二段：等这张牌真正从处理区进入弃牌堆后，再询问发动
xingluan:addEffect(fk.AfterCardsMove, {
  anim_type = "control",

  can_trigger = function(self, event, target, player, data)
    if not player:hasSkill(xingluan.name) then return false end
    if player.phase ~= Player.Play then return false end
    if player:usedSkillTimes(xingluan.name, Player.HistoryPhase) > 0 then return false end

    local pending = player:getTableMark(PENDING_MARK)
    if not pending or #pending == 0 then return false end

    local pending_map = {}
    for _, id in ipairs(pending) do
      pending_map[id] = true
    end

    for _, move in ipairs(data) do
      for _, info in ipairs(move.moveInfo) do
        if pending_map[info.cardId] and info.fromArea == Card.Processing then
          return true
        end
      end
    end

    return false
  end,

  on_cost = function(self, event, target, player, data)
    local room = player.room
    room:setPlayerMark(player, PENDING_MARK, 0)
    return room:askToSkillInvoke(player, {
      skill_name = xingluan.name,
      prompt = "#xh__xingluan-invoke",
    })
  end,

  on_use = function(self, event, target, player, data)
    doXingluanEffect(player)
  end,
})

return xingluan
