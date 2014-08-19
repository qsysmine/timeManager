--TimeManager
--© 2014 Quartz Systems
--A lightweight time-management app
--Split code from lua-users.org/Split-Join
-- explode(seperator, string)
function explode(d,p)
  local t, ll
  t={}
  ll=0
  if(#p == 1) then return {p} end
    while true do
      l=string.find(p,d,ll,true) -- find the next d in the string
      if l~=nil then -- if "not not" found then..
        table.insert(t, string.sub(p,ll,l-1)) -- Save it in our array.
        ll=l+1 -- save just after where we found it for searching next time.
      else
      	table.insert(t, string.sub(p,ll)) -- Save what's left in our array.
      	break -- Break at end, as it should be, according to the lua manual.
      end
    end
  return t
end
--Ari's code begins here.
local formatting = {
	cX = display.contentCenterX,
	cY = display.contentCenterY
}
local getSettings = function()
	local settings = {}
	local settingsH = io.open(system.pathForFile("settings.txt"), "r")
	if settingsH then
		print("Settings exist, now parsing")
		for setting in settingsH:lines() do
			local key = explode(":",setting)[1]
			local value = explode(":",setting)[2]
			settings[key] = value
			print("Parsing: "..key.." = "..value..".")
		end
		settingsH:close()
	end
	return settings
end
local setSettings = function(settings)
	local settingsH = io.open(system.pathForFile("settings.txt"),"w")
	if settingsH then
		print("Write start successful, now writing")
		local buffer = ""
		local settingsComb = {}
		for k,v in pairs(settings) do
			table.insert(settingsComb, k..":"..v)
		end
		buffer = table.concat(settingsComb, "\n")
		settingsH:write(buffer)
		settingsH:close()
		print("Write successful, now closing.")
	end
end
--Title Screen
local white = display.newImage("white.jpg")
white.x = formatting.cX
white.y = formatting.cY
white:scale(2,2)
local red = display.newImage("red.jpg")
red.x = formatting.cX
red.y = formatting.cY
red.alpha = 0
red:scale(2,2)
local green = display.newImage("green.jpg")
green.x = formatting.cX
green.y = formatting.cY
green.alpha = 0
green:scale(2,2)
local blue = display.newImage("blue.jpg")
blue.x = formatting.cX
blue.y = formatting.cY
blue.alpha = 0
blue:scale(2,2)
local mainTitle = display.newText({text="TimeManager",x=-200,y=0,fontSize=50,font="HelveticaNeue-Light"})
mainTitle:setTextColor(0,0,0)
transition.to(mainTitle,{x=formatting.cX,time=500,transition=easing.inSine,onCompletion=sBIn})
local startButton = display.newText({text="Start",x=-10000,y=75,fontSize=40,font="HelveticaNeue-Light"})
startButton:setTextColor(0,0,0)
transition.to(startButton,{x=formatting.cX,time=1000,transition=easing.outSine})
--Start Timer
local settings = getSettings()
local onLoop,delay,timeLeft,isWork,tLT,isStopped,currentColor
currentColor = blue
function changeColor(color)
	local oldCC = currentColor
	currentColor = color
	transition.to(oldCC, {time=500,alpha=0,transition=easing.outSine})
	transition.to(currentColor, {time=500,alpha=1,transition=easing.outSine})
end
isStopped = false
function toggle()
	if isStopped == true then
		isStopped = false
		if isWork then
			changeColor(red)
		else
			changeColor(green)
		end
	else
		isStopped = true
		changeColor(blue)
	end
	print(isStopped)
end
timeLeft = settings.workInv
tLT = display.newText({text=timeLeft,x=-1000,y=-100,fontSize=50,font="HelveticaNeue-Light"})
tLT:setTextColor(0,0,0)
isWork = true
tLT:addEventListener("tap",toggle)
local function startTimer()
	transition.to(mainTitle,{time=1000,x=-1000})
	transition.to(startButton,{time=1000,x=10000})
	transition.to(tLT,{time=1000,x=formatting.cX,y=formatting.cY,transition=easing.outSine})
	changeColor(red)
	onLoop()
end
onLoop = function()
	if isStopped then
	else
		timeLeft = timeLeft - 1
		if timeLeft <= 0 then
			if isWork then
				isWork = false
				timeLeft = settings.playInv
				changeColor(green)
			else
				isWork = true
				timeLeft = settings.workInv
				changeColor(red)
			end
		end
		if isWork then
			tLT.text = timeLeft.." [Work]"
		else
			tLT.text = timeLeft.." [Relaxation]"
		end
	end
	delay()
end
delay = function()
	timer.performWithDelay(1000,onLoop)
end
startButton:addEventListener("tap",startTimer)