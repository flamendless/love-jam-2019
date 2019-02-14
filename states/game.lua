local BaseState = require("states.base_state")
local Game = BaseState:extend()

local Shack = require("modules.shack.shack")
local Talkies = require("modules.talkies.talkies")
local Anim8 = require("modules.anim8.anim8")
local Flux = require("modules.flux.flux")
local Timer = require("modules.hump.timer")
local Vec2 = require("modules.hump.vector")
local GSM = require("src.gamestate_manager")
local AssetsManager = require("src.assets_manager")

local Player = require("objects.player")
local Slime = require("objects.slime")

local images = {}
local fonts = {}
local bg_x = 0
local bg_y = 0
local quad
local min_speed = 256
local max_speed = 1024
local speed = min_speed
local overlay_color = {0, 0, 0, 1}
local obj_player, obj_slime
local count = 0
local pressed_count = 0
local text_control
local left, right, up, down, shoot

local showSlime, showScene, speakCortaxa
local name_commander = "Commander Seven"
local name_cortaxa = "..."

function Game:new(control)
	Game.super.new(self, "game")
	self.control = control or 1
	local base = "Left : %s\nRight : %s\nUp : %s\nDown : %s"
	if self.control == 1 then
		left = "a"
		right = "d"
		up = "w"
		down = "s"
		shoot = "n"
	elseif self.control == 2 then
		left = "left"
		right = "right"
		up = "up"
		down = "down"
		shoot = "z"
	elseif self.control == 3 then
		left = "h"
		right = "l"
		up = "k"
		down = "j"
		shoot = "f"
	end
	text_control = base:format(left, right, up, down)
end

function Game:preload()
	AssetsManager:addImage(self:getID(), {
			{ id = "bg_game", path = "assets/images/bg_game.png" },
			{ id = "player", path = "assets/images/player.png" },
			{ id = "sheet_slime", path = "assets/images/sheet_slime.png" },
			{ id = "avatar_cortaxa", path = "assets/images/avatar_cortaxa.png" },
			{ id = "avatar_commander_serious", path = "assets/images/avatar_commander_serious.png" },
			{ id = "avatar_commander_speak", path = "assets/images/avatar_commander_speak.png" },
			{ id = "avatar_commander_shocked", path = "assets/images/avatar_commander_shocked.png" },
		})
	AssetsManager:addFont({
			{ id = "dialogue", path = "assets/fonts/dimbo_italic.ttf", size = 24 }
		})
	AssetsManager:start( function() self:onLoad() end )
end

function Game:onLoad(previous, ...)
	Shack:setDimensions(love.graphics.getDimensions())
	images = AssetsManager:getAllImages(self:getID())
	fonts.dialogue = AssetsManager:getFont("dialogue")
	for k, v in pairs(images) do v:setFilter("nearest", "nearest") end
	for k, v in pairs(fonts) do v:setFilter("nearest", "nearest") end
	images.bg_game:setWrap("repeat", "repeat")
	quad = love.graphics.newQuad(0, 0, images.bg_game:getWidth() * 2, images.bg_game:getHeight() * 2, images.bg_game:getWidth(), images.bg_game:getHeight())

	obj_player = Player(images.player,
		Vec2(love.graphics.getWidth()/2, love.graphics.getHeight() * 1.5),
		0, 1, 1, images.player:getWidth()/2, images.player:getHeight()/2)
	obj_player:setControls(self.control)
	Flux.to(overlay_color, 3, { [4] = 0 }):delay(2)
	obj_player:gotoIntroPosition(3, function()
		-- showSlime()
		showScene()
	end)
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

	if obj_slime then obj_slime:update(dt) end
	obj_player:update(dt)

	Shack:update(dt)
	Talkies.update(dt)
end

function Game:draw()
	Shack:apply()
	love.graphics.setColor(1, 1, 1, 1)
	love.graphics.draw(images.bg_game, quad)

	obj_player:draw()
	if obj_slime then obj_slime:draw() end

	Talkies.draw()

	--overlay
	love.graphics.setColor(overlay_color)
	love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
end

function Game:keypressed(key)
	if key == "space" then Talkies.onAction()
	elseif key == up then Talkies.prevOption()
	elseif key == down then Talkies.nextOption()
	end
	if count == 1 and pressed_count < 4 then
		if key == left or key == right or key == up or key == down then
			pressed_count = pressed_count + 1
		end
		if pressed_count >= 4 then showScene() end
	end
	if key == shoot and count == 2 then
		Shack:setShake(100)
		--explosion
		showScene()
	end
end

function showScene()
	Talkies.font = fonts.dialogue
	if count == 0 then
		Talkies.say(name_commander, {".", "..", "...", "....", "....."}, { image = images.avatar_commander_serious, })
		Talkies.say(name_commander, {
				"Are you okay?",
				"Try moving your fighter",
			}, {
				image = images.avatar_commander_speak,
			})
		Talkies.say(name_cortaxa, {
				"Beep! Beep! Beep!",
				text_control,
			}, {
				image = images.avatar_cortaxa,
				oncomplete = function() count = count + 1 end
			})

	elseif count == 1 then
		Talkies.say(name_commander, {
				"Are you feeling okay now?",
				"Our ship barely survived the attack",
				"You must find intel about the attack"
			}, {
				image = images.avatar_commander_speak,
			})
		Talkies.say(name_cortaxa, {
				"Beep! Beep! Beep!",
				("Press %s to shoot"):format(shoot),
			}, {
				image = images.avatar_cortaxa,
				oncomplete = function() count = count + 1 end
			})

	elseif count == 2 then
		Talkies.say(name_commander, {
				"Oh, it seems that your fighter's engine is broken.",
				"...",
				"For now, rescue the survivors.",
				"They can fix the fighter."
			}, {
				image = images.avatar_commander_speak,
				oncomplete = function() count = count + 1 end
			})
		speakCortaxa()
	elseif count == 3 then
		--show slime scene
		Talkies.say(name_commander, {
				"W-", "What is that thing!?",
				".", "..", "...",
				"Is that the thing that attacked us?!"
			}, {
				image = images.avatar_commander_shocked
			})
	end
end

function speakCortaxa()
	Talkies.say(name_cortaxa, {
			"Beep! Beep! Beep!",
			"I am Hello Cortaxa, your fighter's AI!",
			"Do you need anything?",
		}, {
			options = {
				{"How to rescue a survivor?", function()
						Talkies.say(name_cortaxa, {
								"To rescue a survivor, you must stay within\ntheir proximity for a period of time"
							}, {
								image = images.avatar_cortaxa,
								oncomplete = function()
									speakCortaxa()
								end
							})
					end},
				{"What is happening!?", function()
						Talkies.say(name_cortaxa, {
								"Let me search on DuckDuckGo...",
								".", "..", "...",
								"No result found!"
							}, {
								image = images.avatar_cortaxa,
								oncomplete = function()
									speakCortaxa()
								end
							})
					end},
				{"Nothing!", function()
						Talkies.say(name_cortaxa, {
								"Bye!"
							}, {
								image = images.avatar_cortaxa,
								oncomplete = function()
									--show slime
									showSlime()
								end
							})
					end},
			},
			image = images.avatar_cortaxa,
			oncomplete = function()
				name_cortaxa = "Hello Cortaxa"
			end
		})
end

function showSlime()
	local grid = Anim8.newGrid(150, 116, images.sheet_slime:getWidth(), images.sheet_slime:getHeight())
	local obj_anim = Anim8.newAnimation(grid('1-6', 1), 0.25)
	obj_slime = Slime(obj_anim, images.sheet_slime,
		Vec2(love.graphics.getWidth()/2, -love.graphics.getHeight()/2),
		0, 2, 2, 150/2, 0)

	obj_slime:gotoIntroPosition(1, function() showScene() end)
end

return Game
