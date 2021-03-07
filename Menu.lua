
local composer = require( "composer" )

local scene = composer.newScene()

-- -----------------------------------------------------------------------------------
-- Code outside of the scene event functions below will only be executed ONCE unless
-- the scene is removed entirely (not recycled) via "composer.removeScene()"
-- -----------------------------------------------------------------------------------


local function gotoGame()
	composer.gotoScene("game", { time=500, effect="crossFade" })
end

local json = require("json")

local scoresTable = {}

local filePath = system.pathForFile("scores.json", system.DocumentsDirectory)

local function loadScores()
	local file = io.open(filePath, "r")

	if file then
		local contents = file:read("*a")
		io.close(file)
		scoresTable = json.decode(contents)
	end

	if (scoresTable == nil or #scoresTable == 0) then
		scoresTable = {0}
	end
end

local function saveScores()
	table.remove(scoresTable, 2)


	local file = io.open(filePath, "w")

	if file then
		file:write(json.encode(scoresTable))
		io.close(file)
	end
end


-- -----------------------------------------------------------------------------------
-- Scene event functions
-- -----------------------------------------------------------------------------------

-- create()
function scene:create( event )

	local sceneGroup = self.view
	-- Code here runs when the scene is first created but has not yet appeared on screen

	local background = display.newImageRect( sceneGroup, "images/menuBackground.png", display.contentWidth, display.contentHeight )
    background.x = display.contentCenterX
	background.y = display.contentCenterY

	local playButton = display.newText(sceneGroup, "Play", display.contentCenterX,  (3*display.contentHeight)/8 , verdana, 60)
	playButton:setFillColor(0, 0, 0)

	loadScores()

	table.insert(scoresTable, composer.getVariable("finalScore")) 
	composer.setVariable("finalScore", 0)
	local function compare(a, b)
		return a > b
	end
	table.sort(scoresTable, compare)
	saveScores()

    local highScoresButton = display.newText( sceneGroup, "Highscore:".. scoresTable[1], display.contentCenterX, 3* display.contentHeight/4, Verdana, 44 )
	highScoresButton:setFillColor(0, 0, 0)
	playButton:addEventListener("tap", gotoGame)


	local systemFonts = native.getFontNames()
 
-- Set the string to query for (part of the font name to locate)

end


-- show()
function scene:show( event )

	local sceneGroup = self.view
	local phase = event.phase

	if ( phase == "will" ) then
		-- Code here runs when the scene is still off screen (but is about to come on screen)

	elseif ( phase == "did" ) then
		-- Code here runs when the scene is entirely on screen

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
		composer.removeScene("menu")
	end
end


-- destroy()
function scene:destroy( event )

	local sceneGroup = self.view
	-- Code here runs prior to the removal of scene's view

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
