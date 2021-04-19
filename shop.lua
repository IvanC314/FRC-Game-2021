
local composer = require( "composer" )

local scene = composer.newScene()

-- -----------------------------------------------------------------------------------
-- Code outside of the scene event functions below will only be executed ONCE unless
-- the scene is removed entirely (not recycled) via "composer.removeScene()"
-- -----------------------------------------------------------------------------------




local coins = composer.getVariable("coins")
local maxHP = composer.getVariable("healthLevel")
local maxEnergy = composer.getVariable("energyLevel")
local chargeSpeed = composer.getVariable("chargeLevel")

local backgroundSound
local upgradeSound
local selectSound

local function addCoins()
	coins = coins + 10
end

local function subCoins()
	coins = coins - 10
end

local function updateText()
	coinsText.text = "Coins:"..coins
	if (maxHP ~= 11) then
		hpText.text = "HP Lv ".. maxHP
	else
		hpText.text = "HP Max"
	end

	if (maxEnergy ~= 9) then
		energyText.text = "Energy Lv ".. maxEnergy
	else
		energyText.text = "Energy Max"
	end

	if (chargeSpeed ~= 5) then
		chargeText.text = "Charge Lv ".. chargeSpeed
	else
		chargeText.text = "Charge Max"
	end
end

local function updateColors()
	upgrade1.height = 375/11 * maxHP
	upgrade2.height = 375/9 * maxEnergy
	upgrade3.height = 375/5 * chargeSpeed
end

local function gameLoop()
	updateText()
	updateColors()
end

local function buyHP()
	if (coins >= 25 and maxHP < 11) then
		coins = coins - 25
		maxHP = maxHP + 1
		audio.play(upgradeSound)
	end
end

local function buyEnergy() 
	if (coins >= 25 and maxEnergy < 9) then
		coins = coins - 25
		maxEnergy = maxEnergy + 1
		audio.play(upgradeSound)

	end
end


local function buyCharge()
	if (coins >= 25 and chargeSpeed < 5) then
		coins = coins - 25
		chargeSpeed = chargeSpeed + 1
		audio.play(upgradeSound)

	end
end


local function gotoMenu()
	audio.play(selectSound)
	composer.setVariable("coins", coins)
	composer.setVariable("healthLevel", maxHP)
	composer.setVariable("energyLevel", maxEnergy)
	composer.setVariable("chargeLevel", chargeSpeed)
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

	local black = display.newImageRect(sceneGroup, "images/shop.png", 1225, 660)
	black.x = display.contentCenterX
	black.y = display.contentCenterY

	local backButton = display.newText(sceneGroup, "Back", 105,  75 , verdana, 50)
	backButton:setFillColor(1, 1, 1)
	backButton:addEventListener("tap", gotoMenu)

	-- local sub = display.newRect( 1000, 50, 50, 50 )
	-- sub:setFillColor( 1, 0, 0.3 )
	
	-- local add = display.newRect(1200, 50, 50, 50 )
	-- add:setFillColor( 0, 1, 0.3 )

    coinsText = display.newText( sceneGroup, "Coins:".. coins, display.contentCenterX, 75, Verdana, 44 )
	coinsText:setFillColor(1, 1, 1)

	local help = display.newText( sceneGroup, "(All upgrades cost 25 coins)", 1050, 75, Verdana, 25 )
	coinsText:setFillColor(1, 1, 1)
	-- colors for upgrades
	upgrade1 = display.newImageRect(sceneGroup, "images/shopHP.png", 150, 375/11 * maxHP)
	upgrade1.x = 200
	upgrade1.y = 375

	upgrade2 = display.newImageRect(sceneGroup, "images/shopE.png", 150, 375/9 * maxEnergy)
	upgrade2.x = display.contentCenterX
	upgrade2.y = 375

	upgrade3 = display.newImageRect(sceneGroup, "images/shopC.png", 150, 375/5 * chargeSpeed)
	upgrade3.x = display.contentWidth - 200
	upgrade3.y = 375
	-- frames for upgrades
	local frame1 = display.newImageRect(sceneGroup, "images/frame.png", 150, 375)
	frame1.x = 200
	frame1.y = 375

	local frame2 = display.newImageRect(sceneGroup, "images/frame.png", 150, 375)
	frame2.x = display.contentCenterX
	frame2.y = 375

	local frame3 = display.newImageRect(sceneGroup, "images/frame.png", 150, 375)
	frame3.x = display.contentWidth - 200
	frame3.y = 375


	HPbuy = display.newImageRect( sceneGroup, "images/buy.png", 90 , 58 )
	HPbuy.x = 200
	HPbuy.y = 600

	energyBuy = display.newImageRect( sceneGroup, "images/buy.png", 90 , 58 )
	energyBuy.x = display.contentCenterX
	energyBuy.y = 600

	chargeBuy = display.newImageRect( sceneGroup, "images/buy.png",  90 , 58 )
	chargeBuy.x = display.contentWidth - 200
	chargeBuy.y = 600



	if (maxHP ~= 11) then
		hpText = display.newText( sceneGroup, "HP Lv ".. maxHP, 200, 150, Verdana, 44 )
		hpText:setFillColor(1, 1, 1)	
	else
		hpText = display.newText( sceneGroup, "HP Max", 200, 150, Verdana, 44 )
		hpText:setFillColor(1, 1, 1)
	end

	if (maxEnergy ~= 9) then
		energyText = display.newText( sceneGroup, "Energy Lv ".. maxEnergy, display.contentCenterX, 150, Verdana, 44 )
		energyText:setFillColor(1, 1, 1)	
	else
		energyText = display.newText( sceneGroup, "Energy Max", display.contentCenterX, 150, Verdana, 44 )
		energyText:setFillColor(1, 1, 1)
	end
 
	if (chargeSpeed ~= 5) then
		chargeText = display.newText( sceneGroup, "Charge Lv ".. chargeSpeed, display.contentWidth - 200, 150, Verdana, 44 )
		chargeText:setFillColor(1, 1, 1)
	else
		chargeText = display.newText( sceneGroup, "Charge Max", display.contentWidth - 200, 150, Verdana, 44 )
		chargeText:setFillColor(1, 1, 1)
	end


	-- sub:addEventListener("tap", subCoins)
	-- add:addEventListener("tap", addCoins)

	HPbuy:addEventListener("tap", buyHP)
	energyBuy:addEventListener("tap", buyEnergy)
	chargeBuy:addEventListener("tap", buyCharge)

	backgroundSound = audio.loadStream("sounds/mainBack.wav")
	upgradeSound = audio.loadSound("sounds/upgrade.wav")
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
		composer.removeScene("shop")
		timer.cancelAll()
	end
end


-- destroy()
function scene:destroy( event )

	local sceneGroup = self.view
	-- Code here runs prior to the removal of scene's view
	audio.dispose(backgroundSound)
	audio.dispose(upgradeSound)
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
