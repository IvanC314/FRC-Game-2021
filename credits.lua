
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

local function gotoTechno()
	audio.play(selectSound)
	system.openURL( "https://www.technotitans.org/" )
end

local function gotoDonate()
	audio.play(selectSound)
	system.openURL( "https://www.technotitans.org/donate.html" )
end

local function gotoFirst()
	audio.play(selectSound)
	system.openURL( "https://www.firstinspires.org/" )
end

local show = false

local realCred
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


	local backButton = display.newText(sceneGroup, "Back", 105,  80 , verdana, 50)
	backButton:setFillColor(1, 1, 1)
	backButton:addEventListener("tap", gotoMenu)

	backgroundSound = audio.loadStream("sounds/mainBack.wav")
	selectSound = audio.loadSound("sounds/select.wav")

	local about = display.newText(sceneGroup, "Brought to you by Team 1683, \n         the Techno Titans", display.contentCenterX,  display.contentCenterY - 170, verdana, 60)
	about:setFillColor(.7, .7, 1)
	about:addEventListener("tap", gotoTechno)

	local first = display.newText(sceneGroup, "Created as part of the FIRST Robotics Competition \n Learn more about FIRST at www.firstinspires.org", display.contentCenterX,  display.contentCenterY - 20, verdana, 50)
	first:setFillColor(1, 1, 1)
	first:addEventListener("tap", gotoFirst)

	local function showCredits()
		audio.play(selectSound)
		if (show == false) then
			realCred = display.newText(sceneGroup, "Ivan Cao - Programming \nSamantha Prabakaran - Graphics", 350,  550, verdana, 40)
			realCred:setFillColor(1, 1, 1)
			show = true
		else 
			display.remove(realCred)
			show = false
		end
	end	

	local learn = display.newText(sceneGroup, "Learn more about us →", 950,  500, verdana, 40)
	learn:setFillColor(1, 1, 1)
	learn:addEventListener("tap", gotoTechno)

	local donate = display.newImageRect(sceneGroup, "images/donate.png", 175,  80)
	donate.x = 950
	donate.y = 610
	donate:addEventListener("tap", gotoDonate)

	logo = display.newImageRect(sceneGroup, "images/logo.png", 150, 150)
	logo.x = 1200
	logo.y = 500
	logo:addEventListener("tap", gotoTechno)

	local credits = display.newText(sceneGroup, "Credits", 100,  660, verdana, 45)
	credits:setFillColor(1, 1, 1)

	credits:addEventListener("tap", showCredits)
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


		composer.removeScene("credits")
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
