local physics = require("physics")

physics.start()
--physics.setDrawMode("hybrid") For debug view
physics.setGravity(0,0)


-- Top Left of the screen
local topLeft = {
	x = (display.contentWidth - display.viewableContentWidth) / 2,
	y = (display.contentHeight - display.viewableContentHeight) / 2
}

-- Some Variables
local winnerText = nil
local gameStarted = false
local walltickness = 10
local wallwidth
local paddlewidth = 80
local paddletickness = 10
local paddle1
local paddle2
local player1Score
local player2Score
local pong
local pongradius = 10
local windowwidth
local windowheight
local debugText = display.newText("Touch the Begin", display.contentWidth/2 - 80, 20, nil, 24)	
local player1Font
local player2Font

-- Physics Properties
local pongPhysicProp = {
	density= 1,
	friction= 0.2,
	bounce = 1,
	radius = pongradius
}

local defaultPhysicProp = {
	density= 1,
	friction= 0,
	bounce = 0.5
}

local paddlePhysicProp = {
	density= 1,
	friction= 0.5,
	bounce = 0.3
}

-- Checks Padding location for translation 
function checkLocation(x,y)
	if (y  < windowheight - paddlewidth/2 - walltickness) and (y > walltickness + paddlewidth/2) then
		return true
	end
	return false
end

-- Checks the x pos is in screen bounds
function checkOutOfScreen(x)
	if (x < 0 or x > windowwidth) then
		return true
	end
	return false
end

-- Setting the object pos
function setObjectPos(obj, x, y)

	if checkLocation(x,y) then
		obj.x = x
		obj.y = y
	end
end

-- Global Touch Listener
local touchListener = function(event)
	local phase = event.phase
	if phase == "began" and gameStarted ==false then
		startGame()
	elseif phase == "moved" and gameStarted then
		setObjectPos(paddle1, paddle1.x,event.y)
	elseif phase == "ended" then
		--debugText.text = "ended"
	end
end

-- Checks game end by  looking to scores of the players
function checkGameEnd()

	if (player1Score == 3 or player2Score == 3) then
		return true
	end

	return false
end

-- Update function called each frame
function update()
	
	-- check pong is out of screen
	if checkOutOfScreen(pong.x) and gameStarted  then
		-- Update player scores
		if pong.x < 0 then
			player2Score = player2Score + 1
		else
			player1Score = player1Score + 1
		end
		updateScoreFonts()
		if checkGameEnd() then -- checks weather game end
			gameStarted = false
			gameEndCleanUp()
		else -- Give Pong speed for new play
			setObjectPos(pong,windowwidth/2, windowheight/2)
			pong:setLinearVelocity(math.random(3,6) * 100,math.random(1,10) * 10)
		end
		
	end	
	if gameStarted and checkLocation(0,pong.y) then
		paddle2.y = (pong.y - paddle2.y)/10 + paddle2.y -- update paddle2's location
	end

end

-- initialize of variables
function initApp()
	display.setStatusBar(display.HiddenStatusBar)
	windowwidth = display.contentWidth
	windowheight=display.contentHeight
	wallwidth = display.contentWidth
end

-- Set the world, walls
function setGround()
	local wall
	wall = display.newRect(topLeft.x,topLeft.y,wallwidth,walltickness)
	wall:setFillColor(255,255,255)
	defaultPhysicProp.shape = {-wall.width/2,- wall.height/2, wall.width/2,-wall.height/2,wall.width/2,wall.height/2,-wall.width/2,wall.height/2 }
	physics.addBody(wall, "static", defaultPhysicProp)
	wall = display.newRect(0,display.contentHeight-10, wallwidth,walltickness)
	wall:setFillColor(255,255,255)
	defaultPhysicProp.shape = {-wall.width/2,- wall.height/2, wall.width/2,-wall.height/2,wall.width/2,wall.height/2,-wall.width/2,wall.height/2 }
	physics.addBody(wall, "static", defaultPhysicProp)
end

-- Set the Fonts that holds players scores
function setScoreFonts()
	player1Font = display.newText("0", 20, 40, nil, 18)
	player1Font:setTextColor(0,0,255)
	player2Font = display.newText("0",windowwidth - 30, 40, nil, 18)
	player2Font:setTextColor(0,255,0)
end

-- Update Score Fonts
function updateScoreFonts()
	player1Font.text = player1Score
	player2Font.text = player2Score
end


-- Init of paddles; two kinematic body
function setPaddles()
	paddle1 = display.newRect(10,display.contentHeight/2 - paddlewidth/2,paddletickness, paddlewidth )
	paddle1:setFillColor(0,0,255)
	paddlePhysicProp.shape = {-paddle1.width/2,- paddle1.height/2, paddle1.width/2,-paddle1.height/2,paddle1.width/2,paddle1.height/2,-paddle1.width/2,paddle1.height/2 }
	physics.addBody(paddle1, "kinematic", paddlePhysicProp)
	paddlePhysicProp.shape = nil
	paddle1.name = "paddle1"

	-- Set the on touch event
	--paddle1:addEventListener("touch", onPaddleTouch)	
	
	paddle2 = display.newRect(display.viewableContentWidth-20,display.contentHeight/2 - paddlewidth/2,paddletickness, paddlewidth )
	paddle2:setFillColor(0,255,0)
	paddlePhysicProp.shape = {-paddle2.width/2,- paddle2.height/2, paddle2.width/2,-paddle2.height/2,paddle2.width/2,paddle2.height/2,-paddle2.width/2,paddle2.height/2 }
	physics.addBody(paddle2, "kinematic", paddlePhysicProp)
	paddlePhysicProp.shape = nil
	paddle2.name = "paddle2"

	--paddle2:addEventListener("touch", onPaddleTouch)	

end

function onPaddleTouch(event)
	--debugText.text = event.target.name
end



-- Init the pong
function setPong()
	pong = display.newCircle(windowwidth/ 2, windowheight/2, pongradius)
	pong:setFillColor(255,255,255)
	physics.addBody(pong,"dynamic",pongPhysicProp)
	pong.isBullet = true
end

-- Restarting the Game
function debugText:tap(event)
	startGame()
end

-- On Start Game -- Some initializations
function startGame()
	gameStarted = true
	player1Score = 0
	player2Score = 0
	updateScoreFonts()
	setObjectPos(paddle1, paddle1.x, windowheight/2)
	setObjectPos(paddle2, paddle2.x, windowheight/2)
	setObjectPos(pong, windowwidth/2, windowheight/2)	
	debugText.text = "Restart"
	if winnerText == nil then
		-- do nothing for this case
	else
		winnerText.alpha = 0.0
	end
	
	pong:setLinearVelocity(300,math.random(1,10) * 10)
end

-- When the game ends the positions set back ti default and give pong 0 velocity
function gameEndCleanUp()
	if winnerText == nil then
		winnerText = display.newText("", windowwidth/2,windowheight/2 + 20, nil,20)
	else
		winnerText.alpha = 1.0	
	end

	if	player1Score > player2Score then
		winnerText.text = "You Win"
	else
		winnerText.text = "You Lost"
	end
	debugText.text = "Tap to Begin Game"
	setObjectPos(paddle1, paddle1.x, windowheight/2)
	setObjectPos(paddle2, paddle2.x, windowheight/2)
	pong:setLinearVelocity(0,0)
	setObjectPos(pong, windowwidth/2, windowheight/2)	
end

-- Entry Point of app
function main()
	Runtime:addEventListener("touch", touchListener)
	Runtime:addEventListener("enterFrame", update)	
	debugText:addEventListener("tap",debugText)
	initApp()
	setGround()
	setScoreFonts()
	setPaddles()
	setPong()
end

main()
--startGame()
