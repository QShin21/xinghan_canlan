-- SPDX-License-Identifier: GPL-3.0-or-later
-- 星汉灿烂工具模块
-- 定义自定义事件

---@class Utility : Object
local Utility = {}

------------------------------------------------------------------------------------------------------
--- DebutData 数据
---@class DebutDataSpec
---@field public n integer @ 数量

---@class Utility.DebutData: DebutDataSpec, TriggerData
Utility.DebutData = TriggerData:subclass("DebutData")

--- TriggerEvent
---@class Utility.DebutTriggerEvent: TriggerEvent
---@field public data Utility.DebutData
Utility.DebutTriggerEvent = TriggerEvent:subclass("DebutEvent")

--- 登场时
---@class Utility.Debut: Utility.DebutTriggerEvent
Utility.Debut = Utility.DebutTriggerEvent:subclass("fk.Debut")

---@alias DebutTrigFunc fun(self: TriggerSkill, event: Utility.DebutTriggerEvent,
---  target: ServerPlayer, player: ServerPlayer, data: Utility.DebutData):any

---@class SkillSkeleton
---@field public addEffect fun(self: SkillSkeleton, key: Utility.DebutTriggerEvent,
---  data: TrigSkelSpec<DebutTrigFunc>, attr: TrigSkelAttribute?): SkillSkeleton

return Utility
