local BaseState = require("states.base_state")
local Game = BaseState:extend()

local Lume = require("modules.lume.lume")
local Moonshine = require("modules.moonshine")
local Shack = require("modules.shack.shack")
local Talkies = require("modules.talkies.talkies")
local Anim8 = require("modules.anim8.anim8")
local Flux = require("modules.flux.flux")
local Timer = require("modules.hump.timer")
local Vec2 = require("modules.hump.vector")
local GSM = require("src.gamestate_manager")
local AssetsManager = require("src.assets_manager")
local Controls = require("src.controls")
local GUI = require("src.gui")

local Player = require("objects.player")
local Slime = require("objects.slime")
local Survivor = require("objects.survivor")
local GAMEOVER

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

local showSlime, showScene, speakCortaxa, getHurt, mainGame, showFirstRescue, slimeAttack, slimeMove
local name_commander = "Commander Seven"
local name_cortaxa = "..."
local name_slime = "Slime"
local names = {"Billy", "Steve", "John", "sam", "Eliot", "Tyrell"}
local name_rescued = "...."

local main_game = false
local can_skip = false
local paused = false
local skipped = true
local gameover = false

local effect_fog
local image_fog
local time = 0

local objects = {}
local first_rescue = true
local start_delay = 3

local function reset()
	bg_x = 0
	bg_y = 0
	quad = nil
	overlay_color = {0, 0, 0, 1}
	obj_player = nil
	obj_slime = nil
	count = 0
	pressed_count = 0
	text_control = nil

	main_game = false
	can_skip = false
	paused = false
	skipped = true
	gameover = false

	effect_fog = nil
	image_fog = nil
	time = 0

	objects = {}
	first_rescue = true
	print("reset")
end

function Game:new(control)
	reset()
	Game.super.new(self, "game")
	Controls:set(control)
	local base = "Left : %s\nRight : %s\nUp : %s\nDown : %s"
	local left, right, up, down = Controls:getMovement()
	text_control = base:format(left, right, up, down)

	local image_data = love.image.newImageData(love.graphics.getDimensions())
	image_fog = love.graphics.newImage(image_data)
	effect_fog = Moonshine(Moonshine.effects.fog)
	effect_fog.fog.fog_color = { 0.0, 0.0, 0.2, 1 }
	effect_fog.fog.speed = {0.0, -2}
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
			{ id = "sheet_slime_scatter", path = "assets/images/sheet_slime_scatter.png" },
			{ id = "sheet_slime_bomb", path = "assets/images/sheet_slime_bomb.png" },
			{ id = "island", path = "assets/images/island.png" },
			{ id = "wreck", path = "assets/images/wreck.png" },
			{ id = "drown", path = "assets/images/drown.png" },
			{ id = "survivor1", path = "assets/images/survivor1.png" },
			{ id = "survivor2", path = "assets/images/survivor2.png" },
			{ id = "survivor3", path = "assets/images/survivor3.png" },
			{ id = "survivor4", path = "assets/images/survivor4.png" },
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
			{ id = "yeah1", path = "assets/audio/yeah1.ogg", kind = "stream" },
			{ id = "yeah2", path = "assets/audio/yeah2.ogg", kind = "stream" },
			{ id = "yeah3", path = "assets/audio/yeah3.ogg", kind = "stream" },
			{ id = "yeah4", path = "assets/audio/yeah4.ogg", kind = "stream" },
			{ id = "yeah5", path = "assets/audio/yeah5.ogg", kind = "stream" },
			{ id = "help1", path = "assets/audio/help1.ogg", kind = "stream" },
			{ id = "help2", path = "assets/audio/help2.ogg", kind = "stream" },
			{ id = "help3", path = "assets/audio/help3.ogg", kind = "stream" },
			{ id = "hit1", path = "assets/audio/hit1.ogg", kind = "stream" },
			{ id = "hit2", path = "assets/audio/hit2.ogg", kind = "stream" },
			{ id = "hit3", path = "assets/audio/hit3.ogg", kind = "stream" },
			{ id = "slime_hit1", path = "assets/audio/slime_hit1.ogg", kind = "static" },
			{ id = "slime_hit2", path = "assets/audio/slime_hit2.ogg", kind = "static" },
			{ id = "slime_hit3", path = "assets/audio/slime_hit3.ogg", kind = "static" },
			{ id = "attack1", path = "assets/audio/attack1.ogg", kind = "static" },
			{ id = "attack2", path = "assets/audio/attack2.ogg", kind = "static" },
			{ id = "attack3", path = "assets/audio/attack3.ogg", kind = "static" },
			{ id = "repair1", path = "assets/audio/repair1.ogg", kind = "static" },
			{ id = "repair2", path = "assets/audio/repair2.ogg", kind = "static" },
		})

	AssetsManager:addFont({
			{ id = "dialogue", path = "assets/fonts/dimbo_italic.ttf", size = 24 },
			{ id = "gameover", path = "assets/fonts/whiterabbit.ttf", size = 64 },
			{ id = "gameover_small", path = "assets/fonts/whiterabbit.ttf", size = 32 }
		})
	AssetsManager:start( function() self:onLoad() end )
end

function Game:onLoad(previous, ...)
	Shack:setDimensions(love.graphics.getDimensions())
	images = AssetsManager:getAllImages(self:getID())
	audio = AssetsManager:getAllSources(self:getID())
	fonts.dialogue = AssetsManager:getFont("dialogue")
	fonts.gameover = AssetsManager:getFont("gameover")
	fonts.gameover_small = AssetsManager:getFont("gameover_small")
	for k, v in pairs(images) do v:setFilter("nearest", "nearest") end
	for k, v in pairs(fonts) do v:setFilter("nearest", "nearest") end
	images.bg_game:setWrap("repeat", "repeat")
	quad = love.graphics.newQuad(0, 0, images.bg_game:getWidth() * 2, images.bg_game:getHeight() * 2, images.bg_game:getWidth(), images.bg_game:getHeight())

	obj_player = Player(images.player,
		Vec2(love.graphics.getWidth()/2, love.graphics.getHeight() * 1.5),
		0, 1, 1, images.player:getWidth()/2, images.player:getHeight()/2)
	obj_player:setMoveSound(audio.jet_move)
	obj_player:setDamageSound({audio.hit1, audio.hit2, audio.hit3})
	obj_player:setDimensions(images.player:getWidth(), images.player:getHeight())

	if __DEBUG then start_delay = 0 end
	Flux.to(overlay_color, 3, { [4] = 0 }):delay(start_delay)
		:onstart(function()
			audio.jet_intro:play()
		end)
	obj_player:gotoIntroPosition(start_delay, function()
		showScene()
		can_skip = true
	end)

	local grid = Anim8.newGrid(150, 116, images.sheet_slime:getWidth(), images.sheet_slime:getHeight())
	local obj_anim = Anim8.newAnimation(grid('1-6', 1), 0.25)
	obj_slime = Slime(obj_anim, images.sheet_slime,
		Vec2(love.graphics.getWidth()/2, -love.graphics.getHeight()/2),
		0, 2, 2, 150/2, 0)
	obj_slime:setPlayer(obj_player)
	obj_slime:setDimensions(150, 116)
	obj_slime:setHitSound({audio.slime_hit1, audio.slime_hit2, audio.slime_hit3})
	obj_player:setSlime(obj_slime)
	obj_player:setAttackSound({audio.attack1, audio.attack2, audio.attack3})
	obj_player:setRepair({audio.repair1, audio.repair2})

	GUI:new(fonts.dialogue)
	GUI:setObjects(obj_player, obj_slime)

	GAMEOVER = require("states").gameover()
	GAMEOVER:setFont(fonts.gameover, fonts.gameover_small)
end

function Game:update(dt)
	local dx = 0
	local dy = -1
	bg_x = bg_x - speed * obj_player:getXDirection() * dt
	bg_y = bg_y - speed * dt
	if bg_x > love.graphics.getWidth() * 2 then bg_x = 0 end
	if bg_x < -love.graphics.getWidth() * 2 then bg_x = 0 end
	if bg_y < -love.graphics.getHeight() * 2 then bg_y = 0 end
	if obj_player:getYDirection() == -1 then
		speed = speed + 128 * dt
		if speed > max_speed then speed = max_speed end
	elseif obj_player:getYDirection() == 1 then
		speed = speed - 128 * dt
		if speed < min_speed then speed = min_speed end
	end
	time = time + dt
	effect_fog.fog.time = time
	if obj_player.xdir ~= 0 then
		dx = obj_player.xdir * 8
	end
	if obj_player.ydir ~= 0 then
		dy = obj_player.ydir * 8
	end
	effect_fog.fog.speed = {dx, dy}

	GAMEOVER:updateText(obj_player.score, GUI.time)

	quad:setViewport(bg_x, bg_y, images.bg_game:getWidth() * 2, images.bg_game:getHeight() * 2)

	if obj_slime then
		if not paused then
			obj_slime:update(dt)
		end
	end
	if not paused then
		obj_player:update(dt)
	end
	if obj_player.isDead and not gameover then
		gameover = true
		paused = true
		Flux.to(overlay_color, 5, { [1] = 1, [4] = 1 })
			:oncomplete(function()
				GSM:switch( GAMEOVER )
			end)
	end

	for i, v in ipairs(objects) do
		v:update(dt)
		if v:checkHit(obj_player) then
			v.timer = v.timer - dt
			v.being_rescued = true
		else
			v.being_rescued = false
		end
	end

	for i = #objects, 1, -1 do
		local obj = objects[i]
		if obj.rescued then
			obj_player:giveRescued(obj)
			table.remove(objects, i)
			if first_rescue and not skipped then
				first_rescue = false
				showFirstRescue()
			end
		end
		if obj.gone then table.remove(objects, i) end
	end

	if	not paused then
		GUI:update(dt)
	end
	Shack:update(dt)
	Talkies.update(dt)
end

function Game:draw()
	Shack:apply()
	love.graphics.setColor(1, 1, 1, 1)
	love.graphics.draw(images.bg_game, quad)
	for i, v in ipairs(objects) do v:draw() end
	effect_fog(function()
		love.graphics.draw(image_fog)
	end)

	if obj_slime then obj_slime:draw() end
	obj_player:draw()

	GUI:draw()
	Talkies.draw()

	--overlay
	love.graphics.setColor(overlay_color)
	love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
end

function Game:keypressed(key)
	local left, right, up, down = Controls:getMovement()
	local shoot = Controls:getShoot()
	if key == "escape" and can_skip then
		GUI.skippable = false
		main_game = true
		can_skip = false
		skipped = true
		showSlime()
		mainGame()
		Talkies.clearMessages()
	end
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
		obj_player.life = obj_player.life - 25
		getHurt()
		showScene()
	end
	if __DEBUG then
		if key == "t" then
			showSlime()
		elseif key == "l" then
			if obj_slime then
				-- obj_player:dodgeToLeft()
				-- obj_slime:attack("laser")
				-- obj_slime:attack("scatter")
				-- obj_slime:attack("homing")
				mainGame()
			end
		elseif key == "o" then
			if obj_slime then
				slimeMove()
			end
		elseif key == "p" then
			spawn()
		elseif key == "c" then
			Talkies.clearMessages()
			obj_player.can_move = true
			paused = false
		elseif key == "g" then
			-- obj_player:damage(300)
				GSM:switch( GAMEOVER )
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
					obj_player:dodgeToLeft()
					obj_slime:attack("laser")
				end
			})
		Talkies.say(name_commander, {
				"What is that!?",
				"Be careful!"
			}, {
				image = images.avatar_commander_shocked,
				talkSound = audio.speak_commander,
				oncomplete = function()
					obj_player.can_move = true
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
				{"Who is Commander Seven?", function()
						Talkies.say(name_cortaxa, {
								".", "..", "...",
								"I am not supposed to give my opinion...",
								"BUT, I think he is the man behind this problem...",
								"I know he is up to something not good..."
							}, {
								image = images.avatar_cortaxa,
								talkSound = audio.speak_cortaxa,
								oncomplete = function()
									speakCortaxa()
								end
							})
					end},
				{"Who am I?", function()
						Talkies.say(name_cortaxa, {
								".", "..", "...",
								"You don't know your name?!",
								"Silly!"
							}, {
								image = images.avatar_cortaxa,
								talkSound = audio.speak_cortaxa,
								oncomplete = function()
									speakCortaxa()
								end
							})
					end},
				{"Tell me about this fighter", function()
						Talkies.say(name_cortaxa, {
								".", "..", "...",
								"Model - MJDJ",
								"This fighter is aptly named after the creator's love one...",
								"Mr. Brandon Blanker Lim-it.",
								".", "..", "...",
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
	audio.slime:play()
	obj_slime:gotoIntroPosition(0, function()
		if not skipped then
			showScene()
		end
	end)
end

function getHurt()
	overlay_color = {1, 0, 0, 1}
	Flux.to(overlay_color, 2, { [4] = 0 })
end

function mainGame()
	GUI.timer_start = true
	spawn()
	slimeAttack()
	slimeMove()
end

function spawn()
	local r1 = math.random(3, 6)
	local r2 = math.random(3, 5)
	local random = math.random(r1, r1 + r2)
	print("spawn: " .. random)
	Timer.after(random, function()
		local chance = Lume.randomchoice({"island", "wreck", "drown"})
		local sprite = images[chance]
		local pos = Vec2(
			math.random(0, love.graphics.getWidth() - sprite:getWidth()),
			math.random(-love.graphics.getHeight()/2, 0))
		local scale = math.random(1, 2)
		local obj = Survivor(sprite, pos, 0, scale, scale, sprite:getWidth()/2, sprite:getHeight()/2)
		local n = math.random(1, 4)
		local image_survivor = images["survivor" .. n]
		local grid = Anim8.newGrid(32, 32, image_survivor:getWidth(), image_survivor:getHeight())
		local survivor = Anim8.newAnimation(grid('1-2', 1), 0.5)
		local snd_rescued = audio["yeah" .. math.random(1, 5)]
		local snd_help = audio["help" .. math.random(1, 3)]
		obj:setSuvivor(image_survivor, survivor)
		obj:setSoundOnRescue(snd_rescued)
		obj:setSoundHelp(snd_help)
		table.insert(objects, obj)
		spawn()
	end)
end

function slimeAttack()
	local random = math.random(1, 5)
	local choice = Lume.randomchoice({"laser", "scatter", "bomb", "homing"})
	print("slime attack: " .. choice)
	Timer.after(random, function()
		obj_slime:attack(choice)
	end)
end

function slimeMove()
	local random = math.random(1, 3)
	local choice = Lume.randomchoice({true, false})
	print("slime move: " .. random .. ", " .. tostring(choice))
	Timer.after(random, function()
		if choice then
			obj_slime:move()
		end
		slimeMove()
	end)
end

function showFirstRescue()
	paused = true
	name_rescued = names[math.random(1, #names)]
	Talkies.say(name_rescued, {
			"Thanks for helping me!",
			".", "..", "...",
			"Just curious, why are you not shooting that thing?",
			"W-", "What!?", "The engine is damaged?!",
			".", "..", "...",
			"Good thing I am here!",
			"I can help you...",
			"You can task me to help repair the jet if it's damaged",
			"Or you can send me to that enemy and attack it from the inside!",
			"Pretty exciting huh?",
		})
	Talkies.say(name_cortaxa, {
			"Beep! Beep! Beep!",
			("New information!\n%s : shoot\n%s : repair"):format(Controls:getShoot(), Controls:getRepair()),
			"You can see the rescued count on the bottom left part of the screen",
			"Remember! For every rescued survivor, your fighter's acceleration will decreaase!",
			"In physics, that is called FRICTION!",
			"You will regain the lost speed if you shoot them or use them for repair!",
		}, {
			image = images.avatar_cortaxa,
			talkSound = audio.speak_cortaxa,
			oncomplete = function()
				paused = false
			end
		})
end

function Game:onExit()
	for k, v in pairs(audio) do
		v:stop()
	end
	Talkies.clearMessages()
	obj_player.to_intro:stop()
	obj_slime.to_intro:stop()
end

return Game
