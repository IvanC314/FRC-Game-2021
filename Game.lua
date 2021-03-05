
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
local joystick
local attack
local energy

local fx

local gameLoopTimer

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

    transition.to(newBullet, {y=-40, time = 1200,
        onComplete = function() display.remove(newBullet) end })
end



local function stopTurret()
	if turret.x >= display.contentWidth - 95 then
		turret.x = display.contentWidth - 95
		fx = 0
	end
	if turret.x <= 95 then
		turret.x = 95
		fx = 0
	end
end


local function stopPad()
	if joystick.x >= (2 * display.contentWidth / 5) then
		joystick.x = (2 * display.contentWidth / 5)
	end
	if joystick.x <= 0 then
		joystick.x = 0
	end
	if joystick.y <= display.contentHeight / 2 then 
		joystick.y = display.contentHeight / 2
	end
	if joystick.y >= display.contentHeight then
		joystick.y = display.contentHeight
	end
end

local function joystickForce()
	if (joystick.x > display.contentWidth / 5) then
		fx = 10
		-- print("move right")
	elseif (joystick.x < display.contentWidth / 5) then
		fx = -10
		-- print("move left")
	end
	if joystick.x == (display.contentWidth / 5) then
		fx = 0
		-- print("no move")
	end
end

local function joystickDetect(event)
	local joystick = event.target
	local phase = event.phase

	if("began" == phase) then
		display.currentStage:setFocus(joystick)
		joystickOffsetX = event.x - joystick.x
		joystickOffsetY = event.y - joystick.y

	elseif ("moved" == phase) then
		joystick.x = event.x - joystickOffsetX
		joystick.y = event.y - joystickOffsetY

		stopPad()
		
	elseif("ended" == phase or "cancelled" == phase) then
		display.currentStage:setFocus(nil)
		joystick.x = display.contentWidth / 5
		joystick.y = 3 * display.contentHeight / 4
		fx = 0 
	end
	return true
end

local function gameLoop()
	joystickForce()
	turret.x = turret.x + fx
	stopTurret()

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

	joystick = display.newImageRect(uiGroup, "images/joystick.png", display.contentWidth / 6, display.contentWidth / 6)
	physics.addBody( joystick, { bounce = 0, isSensor = true } )
	joystick.x = display.contentWidth / 5
	joystick.y = 3 * display.contentHeight / 4
	joystick.alpha = .2

	attack = display.newImageRect(uiGroup, "images/attack.png", display.contentWidth / 6.5, display.contentWidth / 6.5)
	physics.addBody( attack, { bounce = 0, isSensor = true } )
	attack.x = 7.5 * display.contentWidth / 10
	attack.y = 5 * display.contentHeight / 6
	attack.alpha = .3

	energy = display.newImageRect(uiGroup, "images/energize.png", display.contentWidth / 6.5, display.contentWidth / 6.5)
	physics.addBody( energy, { bounce = 0, isSensor = true } )
	energy.x = 9 * display.contentWidth / 10
	energy.y = 5 * display.contentHeight / 6
	energy.alpha = .3

	turret = display.newImageRect(mainGroup, "images/turret.png", 90, 110)
	turret.x = display.contentCenterX
	turret.y = display.contentHeight - 60
	physics.addBody(turret, "dynamic", {radius = 30, isSensor = true})
	turret.myName = "turret"

	livesText = display.newText(uiGroup, "Lives: " .. lives, display.contentCenterX/6, display.contentCenterY/8, native.systemFont, 36)
	scoreText = display.newText(uiGroup, "Score: " .. score, display.contentCenterX/6, display.contentCenterY/8 + 50, native.systemFont, 36)
	livesText:setFillColor(0, 0, 0)
	scoreText:setFillColor(0, 0, 0)


	attack:addEventListener( "tap", fire )
	joystick:addEventListener("touch", joystickDetect)

end


-- show()
function scene:show( event )

	local sceneGroup = self.view
	local phase = event.phase

	if ( phase == "will" ) then
		-- Code here runs when the scene is still off screen (but is about to come on screen)

	elseif ( phase == "did" ) then
		-- Code here runs when the scene is entirely on screen
		gameLoopTimer = timer.performWithDelay(25, gameLoop, 0)

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
		timer.cancel(gameLoopTimer)

		physics.pause()
		composer.removeScene("game")
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
