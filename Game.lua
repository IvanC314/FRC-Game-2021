
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
local base

local healthBar
local energyBar
local healthFrame
local energyFrame

local fx
local joystickOffsetX
local joystickOffsetY

local asteroidsTable = {}
local died = false
local gameLoopTimer
local asteroidTimer
local mgTimer
local laserTimer
local spreadTimer

local lives = 100
local score = 0
local ammo = 50

local backGroup
local mainGroup
local uiGroup

local function updateText()
    livesText.text = lives
    scoreText.text = "Score: " .. score
	ammoText.text = ammo
end

local function updateBars()
	healthBar.height = 4.5 * lives
	energyBar.height = 9 * ammo
end

local function fire()
	if ammo -5 >= 0 then
		local newBullet = display.newImageRect(mainGroup, "images/bullet.png", 50, 70) 
		physics.addBody(newBullet, "dynamic", {isSensor = true})
		-- newBullet:applyTorque(math.random(40, 150))

		newBullet.isBullet = true
		newBullet.myName = "bullet"

		newBullet.x = turret.x
		newBullet.y = turret.y -50
		newBullet:toBack()

		transition.to(newBullet, {y=0, time = 1200,
			onComplete = function() display.remove(newBullet) end })
		ammo = ammo -5
	end
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
		fx = 12
		-- print("move right")
	elseif (joystick.x < display.contentWidth / 5) then
		fx = -12
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

local function addEnergy()
	ammo = ammo + 1
end

local function limitEnergy()
	if ammo >= 50 then
		ammo = 50
	end
end

local energyTimer = timer.performWithDelay(100, addEnergy, 0)

local function energyPress(event)
	local energy = event.target
	local phase = event.phase

	if("began" == phase) then
		display.currentStage:setFocus(energy)

		timer.resume(energyTimer)

	-- elseif ("moved" == phase) then

	-- 	ammo = ammo + 1
		
	elseif("ended" == phase or "cancelled" == phase) then
		display.currentStage:setFocus(nil)
		timer.pause(energyTimer)
	end
	return true
end

local function restore()
    -- turret.isBodyActive = false
    -- turret.x = display.contentCenterX
    -- turret.y = display.contentHeight - 100

    transition.to(turret, {alpha = 1, time = 1500, 
    onComplete = function() 
    -- turret.isBodyActive = true 
    died = false end})
end

local function endGame()
	composer.setVariable("finalScore", score)
	composer.gotoScene("menu", {time = 1000, effect = "crossFade"})
end

local function speedCalc(x)
	return 3500 - (1000*math.log(x + 1))
end

local function createAsteroid()
	-- local asteroidType = math.random(1, 2)
	-- if (asteroidType == 1) then
    	local newAsteroid = display.newImageRect(mainGroup, "images/asteroid.png", 30, 50)
    	table.insert(asteroidsTable, newAsteroid)
    	newAsteroid.myName = "asteroid"
		newAsteroid.x = math.random(100, display.contentWidth - 100)
		newAsteroid.y = math.random(-150, -100)
		local asteroidScale = math.random(3,6)
		physics.addBody(newAsteroid, "dynamic", {radius = (25 * asteroidScale / 2), bounce = 0.2})
		newAsteroid.xScale = asteroidScale
		newAsteroid.yScale = asteroidScale
		newAsteroid:setLinearVelocity(0, (6 * math.sqrt(score)) + 25)
		-- newAsteroid:applyTorque(math.random(-15, 15))
	-- else
	-- 	local newAsteroid = display.newImageRect(mainGroup, "images/asteroid1.png", 25, 30)
	-- 	table.insert(asteroidsTable, newAsteroid)
    -- 	physics.addBody(newAsteroid, "dynamic", {radius = 40, bounce = 0.2})
    -- 	newAsteroid.myName = "asteroid"
	-- 	newAsteroid.x = math.random(100, display.contentWidth - 100)
	-- 	newAsteroid.y = math.random(-200, -100)
	-- 	local asteroidScale = math.random(3,5)
	-- 	newAsteroid.xScale = asteroidScale
	-- 	newAsteroid.yScale = asteroidScale
	-- 	newAsteroid:setLinearVelocity(0, (6 * math.sqrt(score)) + 25)
	-- 	newAsteroid:applyTorque(math.random(-5, 5))
	-- end
end
local function spawnMG()
	local newMG = display.newImageRect(mainGroup, "images/mg.png", 60, 60)
	physics.addBody(newMG, "dynamic", {radius = 30, bounce = 0.2})
	newMG.myName = "MG"
	newMG.x = math.random(100, display.contentWidth - 100)
	newMG.y = math.random(-150, -100)
	-- newAsteroid:setLinearVelocity(0, 80)
	-- newMG:applyTorque(5)

	transition.to(newMG, {y=display.contentHeight + 100, time = 10000,
	onComplete = function() display.remove(newMG) end })
end

local function spawnLaser()
	local newLaser = display.newImageRect(mainGroup, "images/ls.png", 60, 60)
	physics.addBody(newLaser, "dynamic", {radius = 30, bounce = 0.2})
	newLaser.myName = "newLaser"
	newLaser.x = math.random(100, display.contentWidth - 100)
	newLaser.y = math.random(-150, -100)
	-- newLaser:applyTorque(-5)

	transition.to(newLaser, {y=display.contentHeight + 100, time = 10000,
	onComplete = function() display.remove(newMG) end })
end

local function spawnSpread()
	local newSpread = display.newImageRect(mainGroup, "images/sp.png", 60, 60)
	physics.addBody(newSpread, "dynamic", {radius = 30, bounce = 0.2})
	newSpread.myName = "newSpread"
	newSpread.x = math.random(100, display.contentWidth - 100)
	newSpread.y = -100
	-- newSpread:applyTorque(0,5)

	transition.to(newSpread, {y=display.contentHeight + 100, time = 11000,
	onComplete = function() display.remove(newMG) end })
end

local function fireNoCost()

	local newBullet = display.newImageRect(mainGroup, "images/bullet.png", 40, 60) 
	physics.addBody(newBullet, "dynamic", {radius = 25, isSensor = true})
	-- newBullet:applyTorque(math.random(40, 150))

	newBullet.isBullet = true
	newBullet.myName = "bullet"

	newBullet.x = turret.x
	newBullet.y = turret.y - 50
	newBullet:toBack()

	transition.to(newBullet, {y=0, time = 1100,
		onComplete = function() display.remove(newBullet) end })
end

local function fireLasers()
	-- local type = math.random(1, 3)
	-- if type == 1 then
		local newBullet = display.newImageRect(mainGroup, "images/laser1.png", 55, 700) 
		physics.addBody(newBullet, "dynamic", {isSensor = true})
		-- newBullet:applyTorque(math.random(40, 150))

		newBullet.isBullet = true
		newBullet.myName = "laser"

		newBullet.x = turret.x
		newBullet.y = turret.y - 380
		newBullet:toBack()

		transition.to(newBullet, {y=turret.y -375, time = 150,
			onComplete = function() display.remove(newBullet) end })
	-- elseif type == 2 then
	-- 	local newBullet = display.newImageRect(mainGroup, "images/laser2.png", 30, 700) 
	-- 	physics.addBody(newBullet, "dynamic", {isSensor = true})
	-- 	-- newBullet:applyTorque(math.random(40, 150))

	-- 	newBullet.isBullet = true
	-- 	newBullet.myName = "laser"

	-- 	newBullet.x = turret.x
	-- 	newBullet.y = turret.y - 400
	-- 	newBullet:toBack()

	-- 	transition.to(newBullet, {y=turret.y -400, time = 150,
	-- 		onComplete = function() display.remove(newBullet) end })
	-- elseif type == 3 then
	-- 	local newBullet = display.newImageRect(mainGroup, "images/laser3.png", 30, 700) 
	-- 	physics.addBody(newBullet, "dynamic", {isSensor = true})
	-- 	-- newBullet:applyTorque(math.random(40, 150))

	-- 	newBullet.isBullet = true
	-- 	newBullet.myName = "laser"

	-- 	newBullet.x = turret.x
	-- 	newBullet.y = turret.y - 400
	-- 	newBullet:toBack()

	-- 	transition.to(newBullet, {y=turret.y -400, time = 150,
	-- 		onComplete = function() display.remove(newBullet) end })
	-- end
end

local function fireSpread()

	local newBullet = display.newImageRect(mainGroup, "images/spread.png", 40, 40) 
	physics.addBody(newBullet, "dynamic", {isSensor = true})
	-- newBullet:applyTorque(math.random(40, 150))

	newBullet.isBullet = true
	newBullet.myName = "bullet"

	newBullet.x = turret.x
	newBullet.y = turret.y - 50
	newBullet:toBack()

	transition.to(newBullet, {x = turret.x + math.random(-650, 650), y=0, time = 1100,
		onComplete = function() display.remove(newBullet) end })
end

local function onCollision(event)
    if (event.phase == "began") then
        local obj1 = event.object1
        local obj2 = event.object2

        if ((obj1.myName == "bullet" and obj2.myName == "asteroid") 
        or (obj1.myName == "asteroid" and obj2.myName == "bullet"))
        then 
            display.remove(obj1)
            display.remove(obj2)

            for i = #asteroidsTable, 1, -1 do
                if(asteroidsTable[i] == obj1 or asteroidsTable[i] == obj2) then
                    table.remove(asteroidsTable, i)
                    break
                end
            end
            score = score + 1
            scoreText.text = "Score: ".. score
			-- mg power up--
		elseif ((obj1.myName == "MG" and obj2.myName == "bullet") 
		or (obj1.myName == "bullet" and obj2.myName == "MG"))
		then 
			timer.performWithDelay(150, fireNoCost, 65)
			display.remove(obj1)
			display.remove(obj2)
			-- laser power up--
		elseif ((obj1.myName == "newLaser" and obj2.myName == "bullet") 
		or (obj1.myName == "bullet" and obj2.myName == "newLaser"))
		then 
			timer.performWithDelay(1500, fireLasers, 10)
			display.remove(obj1)
			display.remove(obj2)

		elseif ((obj1.myName == "newSpread" and obj2.myName == "bullet") 
		or (obj1.myName == "bullet" and obj2.myName == "newSpread"))
		then 
			timer.performWithDelay(50, fireSpread, 65)
			display.remove(obj1)
			display.remove(obj2)
			--laser asteroid collision---
		elseif (obj1.myName == "asteroid" and obj2.myName == "laser") 
		then 
			display.remove(obj1)
			for i = #asteroidsTable, 1, -1 do
                if(asteroidsTable[i] == obj1 or asteroidsTable[i] == obj2) then
                    table.remove(asteroidsTable, i)
                    break
                end
            end
            score = score + 1
            scoreText.text = "Score: ".. score

		elseif (obj1.myName == "laser" and obj2.myName == "asteroid") 
		then 
			display.remove(obj2)
			for i = #asteroidsTable, 1, -1 do
                if(asteroidsTable[i] == obj1 or asteroidsTable[i] == obj2) then
                    table.remove(asteroidsTable, i)
                    break
                end
            end
            score = score + 1
            scoreText.text = "Score: ".. score

        elseif ( ( obj1.myName == "turret" and obj2.myName == "asteroid" ) or
        ( obj1.myName == "asteroid" and obj2.myName == "turret" ) or
		( obj1.myName == "base" and obj2.myName == "asteroid" ) or
        ( obj1.myName == "asteroid" and obj2.myName == "base" ) )
        then 

            if (died == false) then
                died = true

                lives = lives - 20
                livesText.text = "Lives: "..lives

                if (lives == 0) then
					timer.cancel(gameLoopTimer)
					timer.cancel(asteroidTimer)
					timer.cancel(energyTimer)
					turret.alpha = 0
					display.remove(base)
					endGame()
                else
                    turret.alpha = .1
					base.alpha = .01 * lives
					restore()
                end
            end
        end
    end
end

local function endTimers()
	if turret.alpha == 0 then
		timer.cancelAll()
	end
end

local function gameLoop()
	limitEnergy()
	updateBars()


	updateText()

	joystickForce()
	turret.x = turret.x + fx
	stopTurret()

	-- spawn and delete out of bounds asteroids
    -- createAsteroid()
	
    for i = #asteroidsTable, 1, -1 do
        local thisAsteroid = asteroidsTable[i]

        if(thisAsteroid.x < 0 or 
            thisAsteroid.x > display.contentWidth or 
		thisAsteroid.y > display.contentHeight + 100)
        then 
            display.remove(thisAsteroid)
            table.remove(asteroidsTable, i)
        end
    end
	endTimers()
end

-- -----------------------------------------------------------------------------------
-- Scene event functions
-- -----------------------------------------------------------------------------------

-- create()
function scene:create( event )

	local sceneGroup = self.view
	-- Code here runs when the scene is first created but has not yet appeared on screen
	physics.pause()
	timer.pause(energyTimer)
	backGroup = display.newGroup()  -- Display group for the background image
    sceneGroup:insert( backGroup )  -- Insert into the scene's view group
 
    mainGroup = display.newGroup()  -- Display group for the turret, asteroids, lasers, etc.
    sceneGroup:insert( mainGroup )  -- Insert into the scene's view group
 
    uiGroup = display.newGroup()    -- Display group for UI objects like the score
	sceneGroup:insert( uiGroup )
	
	local background = display.newImageRect(backGroup, "images/gameBackground.png", display.contentWidth, display.contentHeight)
	background.x = display.contentCenterX
	background.y = display.contentCenterY

	base = display.newImageRect(mainGroup, "images/base.png", display.contentWidth, 75)
	base.x = display.contentCenterX
	base.y = display.contentHeight - 10
	physics.addBody(base, "static", {isSensor = true})
	base.myName = "base"

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
	turret.y = display.contentHeight - 55
	physics.addBody(turret, "dynamic", {radius = 30, isSensor = true})
	turret.myName = "turret"

	healthBar = display.newImageRect(uiGroup, "images/health.png", display.contentWidth / 50, 450)
	healthBar.alpha = .7
	healthBar.anchorY = 1
	healthBar.x = 25
	healthBar.y = 600

	healthFrame = display.newImageRect(uiGroup, "images/frame.png", display.contentWidth / 50, 450)
	healthFrame.alpha = .2
	healthFrame.anchorY = 1
	healthFrame.x = 25
	healthFrame.y = 600

	energyBar = display.newImageRect(uiGroup, "images/energy.png", display.contentWidth / 50, 450)
	energyBar.alpha = .7
	energyBar.anchorY = 1
	energyBar.x = display.contentWidth - 25
	energyBar.y = 600

	energyFrame = display.newImageRect(uiGroup, "images/frame.png", display.contentWidth / 50, 450)
	energyFrame.alpha = .2
	energyFrame.anchorY = 1
	energyFrame.x = display.contentWidth - 25
	energyFrame.y = 600

	livesText = display.newText(uiGroup, lives, 27, 130, native.systemFont, 24)
	scoreText = display.newText(uiGroup, "Score:" .. score, 100, 40, native.systemFont, 36)
	ammoText = display.newText(uiGroup, ammo, display.contentWidth - 27, 130, native.systemFont, 24)
	livesText:setFillColor(1, 1, 1)
	scoreText:setFillColor(1, 1, 1)
	ammoText:setFillColor(1, 1, 1)

	display.currentStage:setFocus(joystick)

end


-- show()
function scene:show( event )

	local sceneGroup = self.view
	local phase = event.phase

	if ( phase == "will" ) then
		-- Code here runs when the scene is still off screen (but is about to come on screen)

	elseif ( phase == "did" ) then
		-- Code here runs when the scene is entirely on screen
		physics.start()
		Runtime:addEventListener( "collision", onCollision )
		attack:addEventListener( "tap", fire )
		joystick:addEventListener("touch", joystickDetect)
		energy:addEventListener("touch", energyPress)
		-- energy:addEventListener("tap", fireNoCost)


		gameLoopTimer = timer.performWithDelay(25, gameLoop, 0)
		mgTimer = timer.performWithDelay(math.random(40000, 50000), spawnMG, 0)
		laserTimer = timer.performWithDelay(math.random(50000, 60000), spawnLaser, 0)
		spreadTimer = timer.performWithDelay(math.random(60000, 70000), spawnSpread, 0)
		asteroidTimer = timer.performWithDelay(speedCalc(score), createAsteroid, 0)
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
		-- timer.cancel(gameLoopTimer)
		-- timer.cancel(asteroidTimer)
		-- timer.cancel(energyTimer)
		-- timer.cancel(spawnMG)
		timer.cancelAll()
		Runtime:removeEventListener("collision", onCollision)
		attack:removeEventListener("tap", fire)
		joystick:removeEventListener("touch", joystickDetect)
		energy:removeEventListener("touch", energyPress)
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
