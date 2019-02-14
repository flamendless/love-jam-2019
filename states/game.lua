local BaseState = require("states.base_state")
local Game = BaseState:extend()

local GSM = require("src.gamestate_manager")
local AssetsManager = require("src.assets_manager")

local images = {}

function Game:new()
	Game.super.new(self, "game")
end

function Game:preload()
	AssetsManager:addImage(self:getID(), {
			{ id = "bg_game", path = "assets/images/bg_game.png" },
		})
	AssetsManager:start( function() self:onLoad() end )
end

function Game:onLoad(previous, ...)
	images = AssetsManager:getAllImages(self:getID())
	for k, v in pairs(images) do v:setFilter("nearest", "nearest") end
end

function Game:update(dt)

end

function Game:draw()
	love.graphics.setColor(1, 1, 1, 1)
	love.graphics.draw(images.bg_game)
end

return Game
