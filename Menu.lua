
local composer = require( "composer" )

local scene = composer.newScene()

-- -----------------------------------------------------------------------------------
-- Code outside of the scene event functions below will only be executed ONCE unless
-- the scene is removed entirely (not recycled) via "composer.removeScene()"
-- -----------------------------------------------------------------------------------






local json = require("json")

local scoresTable = {}

local filePath = system.pathForFile("scores.json", system.DocumentsDirectory)


local backgroundSound
local selectSound

local function loadScores()
	local file = io.open(filePath, "r")

	if file then
		local contents = file:read("*a")
		io.close(file)
		scoresTable = json.decode(contents)
	end

	if (scoresTable == nil or #scoresTable == 0 or #scoresTable < 5) then
		scoresTable = {0, 0, 1, 1, 1}
	end

	print("scores loaded")
end

local function saveScores()


	local file = io.open(filePath, "w")

	if file then
		file:write(json.encode(scoresTable))
		io.close(file)
	end
	print("scores saved")
end

local function gotoShop()
	audio.play(selectSound)
	composer.setVariable("coins", scoresTable[2])
	composer.setVariable("healthLevel", scoresTable[3])
	composer.setVariable("energyLevel", scoresTable[4])
	composer.setVariable("chargeLevel", scoresTable[5])

	composer.gotoScene("shop", { time = 100, effect = "crossFade"})
end

local function gotoGame()
	audio.play(selectSound)
	composer.setVariable("healthLevel", scoresTable[3])
	composer.setVariable("energyLevel", scoresTable[4])
	composer.setVariable("chargeLevel", scoresTable[5])
	composer.gotoScene("game", { time=100, effect="crossFade" })
end

local function gotoHelp()
	audio.play(selectSound)
	composer.gotoScene("help", { time=100, effect="crossFade" })
end

local function gotoCredits()
	audio.play(selectSound)
	composer.gotoScene("credits", { time=100, effect="crossFade" })
end

local function gotolink()
	audio.play(selectSound)
	if (logo.x == 1160 and logo.y == 600) then
    	gotoCredits()
	else
		logo.x = 1160
		logo.y = 600
	end
end


local function goToRealLink()
	audio.play(selectSound)
	system.openURL( "https://www.technotitans.org/" )
end 

local function logoMove()
	logo.x = logo.x + math.random(-50, 50)
	logo.y = logo.y + math.random(-50, 50)
end

local function move()
	timer.performWithDelay(20, logoMove, 20)
	transition.to(logo, {x = math.random(-100, 1400), y=math.random(-50, 800), time = math.random(3000, 7000)})
end

-- -----------------------------------------------------------------------------------
-- Scene event functions
-- -----------------------------------------------------------------------------------

-- create()
function scene:create( event )

	local sceneGroup = self.view
	-- Code here runs when the scene is first created but has not yet appeared on screen

	local background = display.newImageRect( sceneGroup, "images/gameBackground.png", display.contentWidth, display.contentHeight )
    background.x = 0
	background.y = 0
	background.xScale = 2
	background.yScale = 2

	local title = display.newText(sceneGroup, "Space Defense", display.contentCenterX,  150, verdana, 120)
	title:setFillColor(math.random(50, 100) * .01, math.random(50, 100) * .01, math.random(50, 100) * .01)

	local playButton = display.newText(sceneGroup, "Play", display.contentCenterX,  320 , verdana, 70)
	playButton:setFillColor(1, 1, 1)
	playButton:addEventListener("tap", gotoGame)

	logo = display.newImageRect(sceneGroup, "images/logo.png", 150, 150)
	logo.x = 1160
	logo.y = 600
	logo:addEventListener("tap", gotolink)

	local moveDelay = timer.performWithDelay(6381, move, 0)

	local made = display.newText(sceneGroup, "Made by Team 1683", 1150,  700 , verdana, 22)
	made:setFillColor(1, 1, 1)
	made:addEventListener("tap", goToRealLink)

	local help = display.newText(sceneGroup, "Help", 80,  670 , verdana, 50)
	help:setFillColor(1, 1, 1)
	help:addEventListener("tap", gotoHelp)

	loadScores()

	if (composer.getVariable("finalScore") ~= nil) then 

		if (composer.getVariable("finalScore") >= scoresTable[1]) then
			scoresTable[1] = composer.getVariable("finalScore")
		end

		scoresTable[2] = scoresTable[2] + composer.getVariable("finalScore")

	end
	-- table.insert(scoresTable, composer.getVariable("finalScore")) 
	if (composer.getVariable("coins") ~= nil) then 
		scoresTable[2] = composer.getVariable("coins")
	end

	if (composer.getVariable("healthLevel") ~= nil) then 
		scoresTable[3] = composer.getVariable("healthLevel")
	end

	if (composer.getVariable("energyLevel") ~= nil) then 
		scoresTable[4] = composer.getVariable("energyLevel")
	end

	if (composer.getVariable("chargeLevel") ~= nil) then 
		scoresTable[5] = composer.getVariable("chargeLevel")
	end
	
	composer.setVariable("finalScore", 0)
	
	-- table.sort(scoresTable, compare)
	saveScores()

    local highScoresButton = display.newText( sceneGroup, "Highscore:".. scoresTable[1], display.contentCenterX, 475, Verdana, 44 )
	highScoresButton:setFillColor(1, 1, 1)


	local shopButton = display.newText(sceneGroup, "Upgrades", display.contentCenterX, 600, Verdana, 44)
	shopButton:addEventListener("tap", gotoShop)


    -- local coinsText = display.newText( sceneGroup, "Coins:".. scoresTable[2], display.contentCenterX, display.contentHeight - 100, Verdana, 44 )
	-- coinsText:setFillColor(1, 1, 1)
 
-- Set the string to query for (part of the font name to locate)
	backgroundSound = audio.loadStream("sounds/mainBack.wav")
	selectSound = audio.loadSound("sounds/select.wav")
end


-- show()
function scene:show( event )

	local sceneGroup = self.view
	local phase = event.phase

	if ( phase == "will" ) then
		-- Code here runs when the scene is still off screen (but is about to come on screen)

	elseif ( phase == "did" ) then
		-- Code here runs when the scene is entirely on screen

        audio.play(backgroundSound, {channel = 2, loops = -1})

	end
end


-- hide()
function scene:hide( event )

	local sceneGroup = self.view
	local phase = event.phase

	if ( phase == "will" ) then
		-- Code here runs when the scene is on screen (but is about to go off screen)

	elseif ( phase == "did" ) then
		-- Code here runs immediately after the scene goes entirely off screen
		audio.stop(2)
		timer.cancelAll()
		composer.removeScene("menu")
	end
end


-- destroy()
function scene:destroy( event )

	local sceneGroup = self.view
	-- Code here runs prior to the removal of scene's view
	audio.dispose(backgroundSound)
	audio.dispose(selectSound)


end


-- -----------------------------------------------------------------------------------
-- Scene event function listeners
-- -----------------------------------------------------------------------------------
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )
-- -----------------------------------------------------------------------------------

return scene
