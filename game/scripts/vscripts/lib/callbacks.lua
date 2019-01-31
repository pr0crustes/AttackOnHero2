
-- Base classes.
BaseCallback = class({})


function BaseCallback:RegisterCallback(fun)
    if self.events == nil then
        self.events = {}
    end
	table.insert(self.events, fun)
end


function BaseCallback:_CallCallbacks()
    if self.events then
        for i, fun in ipairs(self.events) do
            fun()
        end
    end
end



BaseRoundCallback = setmetatable({}, {__index = BaseCallback})


function BaseRoundCallback:_CallCallbacks(round)
    if self.events then
        for i, fun in ipairs(self.events) do
            fun(round)
        end
    end
end


-- The callbacks

RoundStartCallback = setmetatable({}, {__index = BaseRoundCallback})

GlyphStartCallback = setmetatable({}, {__index = BaseRoundCallback})

