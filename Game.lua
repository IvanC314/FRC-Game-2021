
local composer = require( "composer" )

local scene = composer.newScene()

-- -----------------------------------------------------------------------------------
-- Code outside of the scene event functions below will only be executed ONCE unless
-- the scene is removed entirely (not recycled) via "composer.removeScene()"
-- -----------------------------------------------------------------------------------

local physics = require("physics")
physics.start()
physics.setGravity(0, 0)
 
math.randomseed(os.time())

local turret

local lives = 0 
local score = 0

local backGroup
local mainGroup
local uiGroup

local function updateText()
    livesText.text = "Lives: " .. lives
    scoreText.text = "Score: " .. score
end

local function fire()
    local newBullet = display.newImageRect(mainGroup, "images/bullet.png", 40, 40) 
	physics.addBody(newBullet, "dynamic", {isSensor = true})

    newBullet.isBullet = true
    newBullet.myName = "bullet"

    newBullet.x = turret.x
    newBullet.y = turret.y
    newBullet:toBack()

    transition.to(newBullet, {y=-40, time = 5000,
        onComplete = function() display.remove(newBullet) end })
end

-- -----------------------------------------------------------------------------------
-- Scene event functions
-- -----------------------------------------------------------------------------------

-- create()
function scene:create( event )

	local sceneGroup = self.view
	-- Code here runs when the scene is first created but has not yet appeared on screen

	physics.pause()

	backGroup = display.newGroup()  -- Display group for the background image
    sceneGroup:insert( backGroup )  -- Insert into the scene's view group
 
    mainGroup = display.newGroup()  -- Display group for the ship, asteroids, lasers, etc.
    sceneGroup:insert( mainGroup )  -- Insert into the scene's view group
 
    uiGroup = display.newGroup()    -- Display group for UI objects like the score
	sceneGroup:insert( uiGroup )
	
	local background = display.newImageRect(backGroup, "images/gameBackground.png", display.contentWidth, display.contentHeight)
	background.x = display.contentCenterX
	background.y = display.contentCenterY

	turret = display.newImageRect(mainGroup, "images/turret.png", 100, 110)
	turret.x = display.contentCenterX
	turret.y = display.contentHeight - 100
	physics.addBody(turret, {radius = 30, isSensor = true})
	turret.myName = "turret"

	livesText = display.newText(uiGroup, "Lives: " .. lives, display.contentCenterX/6, display.contentCenterY/8, native.systemFont, 36)
	scoreText = display.newText(uiGroup, "Score: " .. score, display.contentCenterX/6, display.contentCenterY/8 + 50, native.systemFont, 36)

	turret:addEventListener( "tap", fire )
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
