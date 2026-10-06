-- Server-owned, session-only food, duration products and same-server friends.
local Players=game:GetService("Players")
local C=require(game:GetService("ReplicatedStorage"):WaitForChild("PowerBoostConfig"))
local S={};local states={};local friendships={}
local function get(p)
 if not states[p]then states[p]={food=1,power=1,powerUntil=0,wins=1,winsUntil=0,last=-math.huge}end
 return states[p]
end
local function friends(p)
 local n=0
 for other,isFriend in friendships[p]or {}do if isFriend and other.Parent==Players then n+=1 end end
 return n
end
function S.Factors(p,now)
 local s=get(p);now=now or workspace:GetServerTimeNow()
 return C.Active(s.power,s.powerUntil,now),C.Foods[s.food].Percent,friends(p)*C.FriendPercent,C.Active(s.wins,s.winsUntil,now)
end
function S.Power(p,base)
 local mult,food,friend=S.Factors(p)
 return C.Apply(base,mult,food,friend)
end
function S.Trophies(p,gain)
 local _,_,_,mult=S.Factors(p)
 return math.min(40000000,math.floor(gain*mult))
end
function S.Publish(p)
 local s=get(p);local mult,food,friend,wins=S.Factors(p)
 p:SetAttribute("PowerMultiplier",mult);p:SetAttribute("FoodPowerPercent",food);p:SetAttribute("FriendPowerPercent",friend)
 p:SetAttribute("FoodSelected",s.food);p:SetAttribute("WinsMultiplier",wins)
 p:SetAttribute("PowerBoostUntil",s.powerUntil);p:SetAttribute("WinsBoostUntil",s.winsUntil)
end
-- Future receipt handler can grant only these server catalogue IDs. Replaces,
-- rather than stacks, the selected power boost; repeat use resets its duration.
function S.Grant(p,id)
 local item=C.Products[id];if not item then return false,"Unknown boost"end
 local s=get(p);local untilTime=workspace:GetServerTimeNow()+C.Duration
 if item.Kind=="Wins"then s.wins=item.Multiplier;s.winsUntil=untilTime
 else s.power=item.Multiplier;s.powerUntil=untilTime end
 S.Publish(p);return true,item.Name.." active for 15 minutes"
end
function S.Request(p,action,id)
 if not C.TemporaryFreeTesting then return false,"Purchases coming soon"end
 if p:GetAttribute("DataReady")~=true then return false,"Data is not ready"end
 local phase=p:GetAttribute("FlightState")
 if phase and phase~="Idle"then return false,"Return before using"end
 local s=get(p);local now=os.clock()
 if now-s.last<.4 then return false,"Please try again shortly"end;s.last=now
 if action=="Boost"and type(id)=="string"then return S.Grant(p,id)end
 if action=="Food"and type(id)=="number"and id==math.floor(id)and C.Foods[id]then
  s.food=id;S.Publish(p);return true,C.Foods[id].Name.." selected"
 end
 return false,"Unknown request"
end
local function check(p,other)
 if p==other then return end
 task.spawn(function()
  for attempt=1,3 do
   local ok,result=pcall(function()return p:IsFriendsWithAsync(other.UserId)end)
   if p.Parent~=Players or other.Parent~=Players then return end
   if ok then
    friendships[p]=friendships[p]or {};friendships[other]=friendships[other]or {}
    friendships[p][other]=result;friendships[other][p]=result;S.Publish(p);S.Publish(other);return
   end
   task.wait(attempt*2)
  end
  warn("Friend boost lookup unavailable; no unverified bonus granted")
 end)
end
function S.Start()
 local function joined(p)
  S.Publish(p);for _,other in Players:GetPlayers()do check(p,other)end
 end
 Players.PlayerAdded:Connect(joined)
 Players.PlayerRemoving:Connect(function(p)
  states[p]=nil;friendships[p]=nil
  for other,row in friendships do row[p]=nil;S.Publish(other)end
 end)
 for _,p in Players:GetPlayers()do joined(p)end
 task.spawn(function()while true do task.wait(1);for _,p in Players:GetPlayers()do S.Publish(p)end end end)
end
return S
