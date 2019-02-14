local BaseState = require("states.base_state")
local Game = BaseState:extend()

local Flux = require("modules.flux.flux")
local Timer = require("modules.hump.timer")
local Vec2 = require("modules.hump.vector")
local GSM = require("src.gamestate_manager")
local AssetsManager = require("src.assets_manager")

local Player = require("objects.player")

local images = {}
local bg_x = 0
local bg_y = 0
local quad
local min_speed = 256
local max_speed = 1024
local speed = min_speed
local overlay_color = {0, 0, 0, 1}
local obj_player

function Game:new()
	Game.super.new(self, "game")
end

function Game:preload()
	AssetsManager:addImage(self:getID(), {
			{ id = "bg_game", path = "assets/images/bg_game.png" },
			{ id = "player", path = "assets/images/player.png" },
		})
	AssetsManager:start( function() self:onLoad() end )
end

function Game:onLoad(previous, ...)
	images = AssetsManager:getAllImages(self:getID())
	for k, v in pairs(images) do v:setFilter("nearest", "nearest") end
	images.bg_game:setWrap("repeat", "repeat")
	quad = love.graphics.newQuad(0, 0, images.bg_game:getWidth() * 2, images.bg_game:getHeight() * 2, images.bg_game:getWidth(), images.bg_game:getHeight())

	obj_player = Player(images.player,
		Vec2(love.graphics.getWidth()/2, love.graphics.getHeight() * 1.5),
		0, 1, 1, images.player:getWidth()/2, images.player:getHeight()/2)
	Flux.to(overlay_color, 3, { [4] = 0 }):delay(2)
	obj_player:gotoIntroPosition(3)
end

function Game:update(dt)
	bg_x = bg_x - speed * obj_player:getXDirection() * dt
	bg_y = bg_y - speed * dt
	if obj_player:getYDirection() == -1 then
		speed = speed + 128 * dt
		if speed > max_speed then speed = max_speed end
	elseif obj_player:getYDirection() == 1 then
		speed = speed - 128 * dt
		if speed < min_speed then speed = min_speed end
	end
	quad:setViewport(bg_x, bg_y, images.bg_game:getWidth() * 2, images.bg_game:getHeight() * 2)
	obj_player:update(dt)
end

function Game:draw()
	love.graphics.setColor(1, 1, 1, 1)
	love.graphics.draw(images.bg_game, quad)

	obj_player:draw()

	--overlay
	love.graphics.setColor(overlay_color)
	love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
end

return Game
