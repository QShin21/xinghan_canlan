-- SPDX-License-Identifier: GPL-3.0-or-later
-- 孙权 - 制衡技能
-- 出牌阶段限一次，你可以弃置任意张牌，然后摸等量的牌，
-- 若你以此法弃置了所有手牌且对手上阵武将数大于你，则你多摸一张牌。

local zhiheng = fk.CreateSkill {
  name = "xh__zhiheng",
}

Fk:loadTranslationTable {
  ["xh__zhiheng"] = "制衡",
  [":xh__zhiheng"] = "出牌阶段限一次，你可以弃置任意张牌，然后摸等量的牌，" ..
    "若你以此法弃置了所有手牌且对手上阵武将数大于你，则你多摸一张牌。",

  ["#xh__zhiheng-use"] = "制衡：弃置任意张牌，然后摸等量的牌",

  ["$xh__zhiheng1"] = "制衡天下，运筹帷幄！",
  ["$xh__zhiheng2"] = "权衡利弊，决胜千里！",
}

zhiheng:addEffect("active", {
  anim_type = "drawcard",
  prompt = "#xh__zhiheng-use",

  max_phase_use_time = 1,
  target_num = 0,
  min_card_num = 1,

  card_filter = function(self, player, to_select)
    return not player:prohibitDiscard(to_select)
  end,
  target_filter = Util.FalseFunc,

  on_use = function(self, room, effect)
    local player = effect.from
    local discard_ids = effect.cards or {}

    if #discard_ids == 0 or player.dead then
      return
    end

    local hand_before = player:getCardIds("h")

    local discarded_all_hand = (#hand_before > 0)
    if discarded_all_hand then
      for _, id in ipairs(hand_before) do
        if not table.contains(discard_ids, id) then
          discarded_all_hand = false
          break
        end
      end
    end

    room:throwCard(discard_ids, zhiheng.name, player, player)

    if player.dead then
      return
    end

    local draw_num = #discard_ids

    if discarded_all_hand then
      local function countOnboardGenerals(ps)
        local n = 0
        for _, p in ipairs(ps) do
          if not p.dead and p.general and p.general ~= "" then
            n = n + 1
          end
          if not p.dead and p.deputyGeneral and p.deputyGeneral ~= "" then
            n = n + 1
          end
        end
        return n
      end

      local my_cnt = countOnboardGenerals(player:getFriends(true, false))
      local enemy_cnt = countOnboardGenerals(player:getEnemies(false))

      if enemy_cnt > my_cnt then
        draw_num = draw_num + 1
      end
    end

    player:drawCards(draw_num, zhiheng.name)
  end,
})

return zhiheng