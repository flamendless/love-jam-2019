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
local Controls = require("src.controls")

local Player = require("objects.player")
local Slime = require("objects.slime")

local images = {}
local audio = {}
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

local showSlime, showScene, speakCortaxa, getHurt, mainGame
local name_commander = "Commander Seven"
local name_cortaxa = "..."
local name_slime = "Slime"
local main_game = false

function Game:new(control)
	Game.super.new(self, "game")
	Controls:set(control)
	local base = "Left : %s\nRight : %s\nUp : %s\nDown : %s"
	local left, right, up, down = Controls:getMovement()
	text_control = base:format(left, right, up, down)
end

function Game:preload()
	AssetsManager:addImage(self:getID(), {
			{ id = "bg_game", path = "assets/images/bg_game.png" },
			{ id = "player", path = "assets/images/player.png" },
			{ id = "sheet_slime", path = "assets/images/sheet_slime.png" },
			{ id = "avatar_cortaxa", path = "assets/images/avatar_cortaxa.png" },
			{ id = "avatar_slime", path = "assets/images/avatar_slime.png" },
			{ id = "avatar_commander_serious", path = "assets/images/avatar_commander_serious.png" },
			{ id = "avatar_commander_speak", path = "assets/images/avatar_commander_speak.png" },
			{ id = "avatar_commander_shocked", path = "assets/images/avatar_commander_shocked.png" },
			{ id = "avatar_commander_silly", path = "assets/images/avatar_commander_silly.png" },
			{ id = "sheet_slime_laser", path = "assets/images/sheet_slime_laser.png" },
		})
	AssetsManager:addSource(self:getID(), {
			{ id = "speak_commander", path = "assets/audio/speak_commander.ogg", kind = "static" },
			{ id = "speak_cortaxa", path = "assets/audio/speak_cortaxa.ogg", kind = "static" },
			{ id = "speak_slime", path = "assets/audio/speak_slime.ogg", kind = "static" },
			{ id = "jet_intro", path = "assets/audio/jet_intro.ogg", kind = "stream" },
			{ id = "jet_move", path = "assets/audio/jet_move.ogg", kind = "stream" },
			{ id = "slime", path = "assets/audio/slime.ogg", kind = "stream" },
			{ id = "explosion", path = "assets/audio/explosion.ogg", kind = "stream" },
			{ id = "bgm_light", path = "assets/audio/bgm_light.ogg", kind = "stream" },
			{ id = "bgm_dark", path = "assets/audio/bgm_dark.ogg", kind = "stream" },
		})
	AssetsManager:addFont({
			{ id = "dialogue", path = "assets/fonts/dimbo_italic.ttf", size = 24 }
		})
	AssetsManager:start( function() self:onLoad() end )
end

function Game:onLoad(previous, ...)
	Shack:setDimensions(love.graphics.getDimensions())
	images = AssetsManager:getAllImages(self:getID())
	audio = AssetsManager:getAllSources(self:getID())
	fonts.dialogue = AssetsManager:getFont("dialogue")
	for k, v in pairs(images) do v:setFilter("nearest", "nearest") end
	for k, v in pairs(fonts) do v:setFilter("nearest", "nearest") end
	images.bg_game:setWrap("repeat", "repeat")
	quad = love.graphics.newQuad(0, 0, images.bg_game:getWidth() * 2, images.bg_game:getHeight() * 2, images.bg_game:getWidth(), images.bg_game:getHeight())

	obj_player = Player(images.player,
		Vec2(love.graphics.getWidth()/2, love.graphics.getHeight() * 1.5),
		0, 1, 1, images.player:getWidth()/2, images.player:getHeight()/2)
	obj_player:setMoveSound(audio.jet_move)
	obj_player:setDimensions(images.player:getWidth(), images.player:getHeight())
	Flux.to(overlay_color, 3, { [4] = 0 }):delay(2)
		:onstart(function()
			audio.jet_intro:play()
		end)
	obj_player:gotoIntroPosition(3, function()
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
	local left, right, up, down = Controls:getMovement()
	local shoot = Controls:getShoot()
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
		Shack:setShake(200)
		audio.explosion:play()
		getHurt()
		showScene()
	end

	if key == "t" then
		showSlime()
	elseif key == "l" then
		if obj_slime then
			obj_slime:attack("laser")
		end
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
				talkSound = audio.speak_commander,
				image = images.avatar_commander_speak,
				onstart = function()
					audio.bgm_light:setLooping(true)
					audio.bgm_light:play()
				end
			})
		Talkies.say(name_cortaxa, {
				"Beep! Beep! Beep!",
				text_control,
			}, {
				image = images.avatar_cortaxa,
				talkSound = audio.speak_commander,
				oncomplete = function() count = count + 1 end
			})

	elseif count == 1 then
		Talkies.say(name_commander, {
				"Are you feeling okay now?",
				"Our ship barely survived the attack",
				"You must find intel about the attack",
				"Try shooting."
			}, {
				image = images.avatar_commander_speak,
				talkSound = audio.speak_commander,
			})
		Talkies.say(name_cortaxa, {
				"Beep! Beep! Beep!",
				("Press %s to shoot"):format(Controls:getShoot()),
			}, {
				image = images.avatar_cortaxa,
				talkSound = audio.speak_cortaxa,
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
				talkSound = audio.speak_commander,
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
				image = images.avatar_commander_shocked,
				talkSound = audio.speak_commander,
				onstart = function()
					audio.bgm_light:stop()
					audio.bgm_dark:setLooping(true)
					audio.bgm_dark:play()
				end
			})
		Talkies.say(name_slime, {
				"dasdsa", "dsabnwb", "dadwdhasdhsa",
			}, {
				image = images.avatar_slime,
				talkSound = audio.speak_slime,
			})
		Talkies.say(name_commander, {
				"E-", "Eh?",
				"That's gibberish",
				"I think that thing is harmless"
			}, {
				image = images.avatar_commander_silly,
				talkSound = audio.speak_commander,
				oncomplete = function()
					obj_slime:attack("laser")
					obj_player:dodgeToLeft()
				end
			})
		Talkies.say(name_commander, {
				"What is that!?",
				"Be careful!"
			}, {
				image = images.avatar_commander_shocked,
				talkSound = audio.speak_commander,
				oncomplete = function()
					main_game = true
					mainGame()
				end
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
								talkSound = audio.speak_cortaxa,
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
								talkSound = audio.speak_cortaxa,
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
								talkSound = audio.speak_cortaxa,
								oncomplete = function()
									--show slime
									showSlime()
								end
							})
					end},
			},
			image = images.avatar_cortaxa,
			talkSound = audio.speak_cortaxa,
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
	obj_slime:setPlayer(obj_player)
	obj_slime:setDimensions(150, 116)
	audio.slime:play()

	obj_slime:gotoIntroPosition(0, function() showScene() end)
end

function getHurt()
	overlay_color = {1, 0, 0, 1}
	Flux.to(overlay_color, 2, { [4] = 0 })
end

function mainGame()

end

return Game
