Profiteer_Events = {
    ["example"] = {
        title = "Example Event",
        description = "This event will happen every once in a while!",
        max = 1, -- maximum amount of concurrent events
        chance = 1, -- Every 'delay' seconds this is the likelihood of event triggering
        delay = {240, 300}, -- either a number or {min_number, max_number}
        duration = {120, 180}, -- ditto
        posType = "default", -- as defined in Profiteers_MapInfo
        onStart = function(data) print("example event has begun!") end,
        onFinish = function(data) print("example event has ended") end,
        think = function(data) end,
    }
}

--[[ -- Format for ActiveEvents:
    [event_name] = {
        [id] = {
            Number startTime,
            Vector pos,
            ...
        },
    }
]]
Profiteer_ActiveEvents = Profiteer_ActiveEvents or {}