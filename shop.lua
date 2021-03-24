
local composer = require( "composer" )

local scene = composer.newScene()

-- -----------------------------------------------------------------------------------
-- Code outside of the scene event functions below will only be executed ONCE unless
-- the scene is removed entirely (not recycled) via "composer.removeScene()"
-- -----------------------------------------------------------------------------------




local coins = composer.getVariable("coins")

local function addCoins()
	coins = coins + 10
end

local function subCoins()
	coins = coins - 10
end

local function updateText()
	coinsText.text = "Coins:"..coins
end

local function gameLoop()
	updateText()
end

local function gotoMenu()
	composer.setVariable("coins", coins)
	composer.gotoScene("menu", { time=100, effect="crossFade" })
end

local gameLoopTimer

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

	local backButton = display.newText(sceneGroup, "Back", 100,  75 , verdana, 50)
	backButton:setFillColor(1, 1, 1)
	backButton:addEventListener("tap", gotoMenu)

	local sub = display.newRect( 300, 250, 100, 100 )
	sub:setFillColor( 1, 0, 0.3 )
	
	local add = display.newRect(700, 250, 100, 100 )
	add:setFillColor( 0, 1, 0.3 )

    coinsText = display.newText( sceneGroup, "Coins:".. coins, display.contentCenterX, 100, Verdana, 44 )
	coinsText:setFillColor(1, 1, 1)


	sub:addEventListener("tap", subCoins)
	add:addEventListener("tap", addCoins)

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
		composer.removeScene("shop")
		timer.cancelAll()
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
