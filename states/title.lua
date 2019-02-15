local BaseState = require("states.base_state")
local Title = BaseState:extend()

local Timer = require("modules.hump.timer")
local Flux = require("modules.flux.flux")
local Moonshine = require("modules.moonshine")
local GSM = require("src.gamestate_manager")
local AssetsManager = require("src.assets_manager")

local images = {}
local audio = {}
local font, font_small
local obj_title, obj_text, obj_play, obj_quit, obj_info
local image_fog, effect
local time = 0
local out = 1
local fade, menuEnter, playMove, playEnter
local doFade = true
local dur = 0.5
local max_selected = 3
local selected = 1
local stillTitle = true
local controls = {
	"Default (W,A,S,D)",
	"Arrows Keys",
	"Vim (H,J,K,L)",
}
local control_count = 1
local control = controls[control_count]

function Title:new()
	Title.super.new(self, "Title")
end

function Title:preload()
	AssetsManager:addImage(self:getID(), {
			{ id = "title", path = "assets/images/title.png" },
			{ id = "bg_title", path = "assets/images/bg_title.png" },
		})
	AssetsManager:addSource(self:getID(), {
			{ id = "option_move", path = "assets/audio/option_move.ogg", kind = "static" },
			{ id = "option_select", path = "assets/audio/option_select.ogg", kind = "static" },
		})
	AssetsManager:addFont({
			{ id = "title_36", path = "assets/fonts/dimbo_regular.ttf", size = 36 },
			{ id = "title_24", path = "assets/fonts/dimbo_regular.ttf", size = 24 },
		})
	AssetsManager:start( function() self:onLoad() end )
end

function Title:onLoad(previous, ...)
	images = AssetsManager:getAllImages(self:getID())
	font = AssetsManager:getFont("title_36")
	audio = AssetsManager:getAllSources(self:getID())
	font_small = AssetsManager:getFont("title_24")
	for k, v in pairs(images) do v:setFilter("nearest", "nearest") end

	local image_data = love.image.newImageData(love.graphics.getWidth()/2, love.graphics.getHeight()/2)
	image_fog = love.graphics.newImage(image_data)
	image_fog:setFilter("nearest", "nearest")
	effect = Moonshine(Moonshine.effects.fog)
	effect.fog.fog_color = { 35/255, 33/255, 61/255 }
	effect.fog.speed = { 0.4, 0 }

	obj_title = {
		sprite = images.title,
		x = love.graphics.getWidth()/2,
		y = -love.graphics.getHeight()/2,
	}
	Flux.to(obj_title, 2, { y = love.graphics.getHeight()/2 }):ease("backout"):delay(1)

	obj_text = {
		color = {1, 1, 1, 1},
		text = "Press Any Key To Continue",
		x = love.graphics.getWidth()/2,
		y = love.graphics.getHeight() * 1.5
	}
	Flux.to(obj_text, 2, { y = love.graphics.getHeight() * 0.75 }):ease("backout"):delay(1)
	fade()
end

function Title:update(dt)
	time = time + dt
	effect.fog.time = time
	if obj_controls then obj_controls.text = "CONTROL: " .. controls[control_count] end
end

function Title:draw()
	love.graphics.setColor(1, 1, 1, 1)
	love.graphics.draw(images.bg_title, 0, 0, 0, love.graphics.getWidth()/images.bg_title:getWidth(), love.graphics.getHeight()/images.bg_title:getHeight())
	effect(function()
		love.graphics.draw(image_fog)
	end)
	love.graphics.draw(obj_title.sprite, obj_title.x, obj_title.y, 0, 1, 1, obj_title.sprite:getWidth()/2, obj_title.sprite:getHeight()/2)

	love.graphics.setColor(obj_text.color)
	love.graphics.setFont(font)
	love.graphics.print(obj_text.text, obj_text.x - font:getWidth(obj_text.text)/2, obj_text.y - font:getHeight(obj_text.text)/2)

	love.graphics.setColor(1, 1, 1, 1)
	if obj_play then
		if selected == 1 then
			love.graphics.setColor(1, 0, 0, 1)
		else
			love.graphics.setColor(1, 1, 1, 1)
		end
		love.graphics.print(obj_play.text, obj_play.x - font:getWidth(obj_play.text)/2, obj_play.y)
	end
	if obj_controls then
		if selected == 2 then
			love.graphics.setColor(1, 0, 0, 1)
		else
			love.graphics.setColor(1, 1, 1, 1)
		end
		love.graphics.print(obj_controls.text, obj_controls.x - font:getWidth(obj_controls.text)/2, obj_controls.y)
	end
	if obj_quit then
		if selected == 3 then
			love.graphics.setColor(1, 0, 0, 1)
		else
			love.graphics.setColor(1, 1, 1, 1)
		end
		love.graphics.print(obj_quit.text, obj_quit.x - font:getWidth(obj_quit.text)/2, obj_quit.y)
	end
	if obj_info then
		love.graphics.setFont(font_small)
		love.graphics.setColor(1, 1, 1, 1)
		love.graphics.print(obj_info.text, obj_info.x - font_small:getWidth(obj_info.text)/2, obj_info.y)
	end
end

function Title:keypressed(key)
	if stillTitle then
		playEnter()
		stillTitle = false
		dur = 0.1
		Flux.to(obj_title, 1, { y = love.graphics.getHeight() * 0.25 }):ease("backin")
		Flux.to(obj_text, 1, { y = love.graphics.getHeight() * 0.95 }):ease("backin")
		Timer.after(1, function()
			doFade = false
			Flux.to(obj_text.color, 1, { [4] = 0 })
			menuEnter()
		end)
	else
		if key == "up" or key == "w" then
			selected = selected - 1
			if selected <= 0 then
				selected = max_selected
			end
			playMove()
		elseif key == "left" or key == "a" then
			control_count = control_count - 1
			if control_count <= 0 then control_count = #controls end
			playMove()
		elseif key == "right" or key == "d" then
			control_count = control_count + 1
			if control_count > #controls then control_count = 1 end
			playMove()
		elseif key == "down" or key == "s" then
			selected = selected + 1
			if selected > max_selected then
				selected = 1
			end
			playMove()
		elseif key == "return" or key == "space" then
			if selected == 1 then
				GSM:switch( require("states").game(control_count) )
				playEnter()
			elseif selected == 3 then
				love.event.quit()
			end
		end
	end
end

function fade()
	if not doFade then return end
	if out == 1 then
		Flux.to(obj_text.color, dur, { [4] = 0 })
			:oncomplete(function()
				out = 0
				fade()
			end)
	elseif out == 0 then
		Flux.to(obj_text.color, dur, { [4] = 1 })
			:oncomplete(function()
				out = 1
				fade()
			end)
	end
end

function menuEnter()
	obj_play = {
		text = "PLAY",
		x = love.graphics.getWidth()/2,
		y = love.graphics.getHeight() * 1.5,
	}
	obj_controls = {
		text = "CONTROLS: ",
		x = love.graphics.getWidth()/2,
		y = love.graphics.getHeight() * 1.5,
	}
	obj_quit = {
		text = "QUIT",
		x = love.graphics.getWidth()/2,
		y = love.graphics.getHeight() * 1.5,
	}
	obj_info = {
		text = "A Game Made For the LOVE Jam 2019\nBrandon Blanker Lim-it @flamendless",
		x = love.graphics.getWidth()/2,
		y = love.graphics.getHeight() * 1.5
	}
	Flux.to(obj_play, 1, { y = love.graphics.getHeight()/2 }):ease("backout")
	Flux.to(obj_controls, 1, { y = love.graphics.getHeight()/2 + font:getHeight(obj_play.text) + 8 }):ease("backout")
	Flux.to(obj_quit, 1, { y = love.graphics.getHeight()/2 + font:getHeight(obj_play.text) * 2 + 8 }):ease("backout")
	Flux.to(obj_info, 1, { y = love.graphics.getHeight() * 0.85 }):ease("backout")
end

function playMove()
	if audio.option_move:isPlaying() then
		audio.option_move:stop()
	end
	audio.option_move:play()
end

function playEnter()
	if audio.option_select:isPlaying() then
		audio.option_select:stop()
	end
	audio.option_select:play()
end

return Title
