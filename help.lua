
local composer = require( "composer" )

local scene = composer.newScene()

-- -----------------------------------------------------------------------------------
-- Code outside of the scene event functions below will only be executed ONCE unless
-- the scene is removed entirely (not recycled) via "composer.removeScene()"
-- -----------------------------------------------------------------------------------


local backgroundSound
local selectSound

local function gotoMenu()
	audio.play(selectSound)
	composer.gotoScene("menu", { time=100, effect="crossFade" })
end


-- -----------------------------------------------------------------------------------
-- Scene event functions
-- -----------------------------------------------------------------------------------

-- create()
function scene:create( event )

	local sceneGroup = self.view
	-- Code here runs when the scene is first created but has not yet appeared on screen

	local background = display.newImageRect( sceneGroup, "images/help.jpg", display.contentWidth, display.contentHeight )
    background.x = display.contentCenterX
	background.y = display.contentCenterY
	-- background.xScale = 2
	-- background.yScale = 2


	local backButton = display.newText(sceneGroup, "Back", 105,  650 , verdana, 50)
	backButton:setFillColor(1, 1, 1)
	backButton:addEventListener("tap", gotoMenu)

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
		gameLoopTimer = timer.performWithDelay(50, gameLoop, 0)
		audio.play(backgroundSound, {channel = 3, loops = -1})

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
		-- composer.removeScene("shop")
		audio.stop(3)
		composer.removeScene("help")
		timer.cancelAll()
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
