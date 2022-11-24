--[[
## Amphibilib
## the amphibian library

included functions:

table.tosring | convert a table to a usable string. can be set to keep all numeric keys.
has, string.has | check to see if the first term contains the second. returns a bool
isin, string.isin | check to see if the first item appears in the second. returns a bool
string.cap | makes letters capital. can be set to force proper casing
string.plural | makes a word plural using english rules
string.letters | returns a table with all letters in a string. returns empty if not string.
string.words | returns a table with all words. space is the default seperator
pickrandom | picks a random item in a table.
cif | a compact if statment that returns the second or third paramater depending on the first.
getfiles | returns a table of all files within a directory. works in linux and windows
prompt | gets a user input for the terminal only. basicly the same as python's input() function. (except lua is better.)
table.copy | returns a copy of the supplied table without linking them in memory. does not support metamethods, i think.
math.normalrandom | returns random numbers along a normal distribution. can be supplied a mean and standard deviation, default 0 and 1. third argument samples (default 10) controls range and accuracy to a real normal distribution at the cost of speed.
math.sum | returns the sum of a table
math.mean | returns the mean of a table
math.stdev | returns the standard deviation of a table
table.next | returns the next item in a tabe. duplicate entries will mess it up.
table.prev | reterns the previous item in a table. duplicate entries will mess it up.
]]

table.tostring = function(tab,keepkeys, humanreadable , rlevel) --converts a table to a string. keepkeys will keep numeric type keys. it will always keep string keys
	if type(tab)~="table" then return tab end --only execute if its a table
	local textout=""
	local n=0
	rlevel=rlevel or 0 --recursion level.

	if humanreadable then
	for t=1,rlevel do textout=textout.."\t" end --tab for each level in.
	end

	--textout="{"..textout
	textout=textout.."{"
		
	for i,v in pairs(tab) do
		n=n+1

		if humanreadable and n~=1  then
			for t=1,rlevel do textout=textout.."\t" end --tab for each level in.
		end
		
		--first, key writting
		if type(i)=="number" and keepkeys then
			textout=textout.."["..i.."]="
		elseif type(i)=="number" then		
		elseif type(i)=="string" then
			textout=textout.."[\"".. i :gsub("\\","\\\\"):gsub("\"","\\\""):gsub("\n","\\n"):gsub("\r","\\r") .."\"]="
		else
			textout=textout.."["..tostring(i).."]"
		end

		--now the values
		if type(v)=="table" then
			textout=textout..table.tostring(v,keepkeys,humanreadable,rlevel+1)
			if humanreadable then textout=textout.."\n" end
		elseif type(v)=="number" then
			textout=textout..v
		elseif type(v)=="string" then
			textout=textout.."\"".. v :gsub("\\","\\\\"):gsub("\"","\\\""):gsub("\n","\\n"):gsub("\r","\\r") .."\""
			if textout:find("\v") then print(v) end
		else
			textout=textout.."\""..tostring(v).."\""
			print("aa")
		end	

		if n~=#tab then textout=textout.."," end
		if humanreadable and n<#tab then textout=textout.."\n" end
	end
	textout=textout.."}"

	return textout
end



has = function(s,t) --check if s has t in it
if type(s)=="number" then s=tostring(s) end --convert numbers to strings
if type(t)=="number" then t=tostring(t) end 
	if type(s)=="string" then --if source is string value
		if type(t)=="string" then --and the target is string, do a find operation
			if s:find(t) then return true end
		end
	elseif type(s)=="table" then --if it's a table
		for _,v in pairs(s) do --iterate through and find matches
			if v==t then return true end
		end
	end
return false
end
string.has=has --allow :has to be used with any string

isin = function(t,s)-- check if t is in s. this is the same as has() but in reverse order. code wise it is th same.
if type(s)=="number" then s=tostring(s) end --convert numbers to strings
if type(t)=="number" then t=tostring(t) end 
	if type(s)=="string" then --if source is string value
		if type(t)=="string" then --and the target is string, do a find operation
			if s:find(t) then return true end
		end
	elseif type(s)=="table" then --if it's a table
		for _,v in pairs(s) do --iterate through and find matches
			if v==t then return true end
		end
	end
return false
end
string.isin=isin --of course allow :isin to be called, which is more useful for strings anyways.



string.cap = function(str,forcelower) --capitalize the first letter of words. forcelower makes it so non uppered are lowered
if type(str)~="string" then return nil end
local out=""
	for i=1,str:len() do -- go through all of the letters
		local cl=str:sub(i-1,i-1)
		if cl == "" or cl == " " or cl=="."  then -- check for spaces or begining. also periods to preserve things like akronyms
			out=out..str:sub(i,i):upper()
		else
			if forcelower then
			out=out..str:sub(i,i):lower()
			else
			out=out..str:sub(i,i)
			end
		end
	
	end
return out
end

string.plural = function(s) --make a function into functions
			local function isconst(l) --determine if a letter is a vowel (false) or consonant (true)
			for _,v in pairs({"a","e","i","o","u"}) do 
			if l==v then return false end
			end return true end
	if s:sub(s:len()-1) == "fe" or s:sub(s:len()) == "f" then --generic cases, fe->ves | f -> ves
		return s:sub(1,s:len()-2).."ves"
	elseif	s:sub(s:len()) == "x" or s:sub(s:len()) == "s" or s:sub(s:len()) == "z" or s:sub(s:len()-1) == "ch" or s:sub(s:len()-1) == "sh" or s:sub(s:len()-1) == "ss" or ( s:sub(s:len())=="o" and isconst(s:sub(s:len()-1,s:len()-1)) )  then -- x -> xes | s -> ses | z -> zes | ss -> sses | ch -> ches | sh -> shes | o -> oes when constanant
		return s.."es"
	elseif 	s:sub(s:len()) == "y" and isconst(s:sub(s:len()-1,s:len()-1))   then-- y -> ies when consonant
		return s.."ies"
	elseif s:sub(s:len()-4,s:len()) == "goose" then --special cases, goose -> geese
		return s:sub(1,s:len()-5).."geese"
	else
		return s.."s" --  -> s , also the fallback
	end
end

string.letters = function(s) --return a table of all letters in the string
if type(s)~="string" then return {} end
local out={}
	for i=1,#s do
	table.insert(out,s:sub(i,i))
	end
return out	
end

string.words = function(s,seperator,keepsep) --extract words into a table. can set a custom separator default " "
if type(s) ~= "string" then return {} end
if not seperator then seperator={" "} end
if type(seperator) ~= "table" then seperator={seperator} end
local out={}
local buf=""
	for i=1,#s do
	local issep	
		for _,sep in pairs(seperator) do
			if sep==s:sub(i,i) then issep = true end
		end
	
		if issep then
		if buf~="" then table.insert(out,buf) end
			if keepsep then
			table.insert(out,s:sub(i,i))
			end	
		buf=""
		else
		buf=buf..s:sub(i,i)
		end	
	end
if buf~="" then table.insert(out,buf) end

return out	
end


pickrandom = function(s) --pick a random item in the table
if type(s) ~= "table" then return s end
local rng = math.random(1,#s)
local n=0
	for i,v in pairs(s) do
	n=n+1
	if n==rng then return v,i end
	end
end


cif = function(c,t,f) --adds in "compact if". more compact if statment, really. maybe more readable, who knows
	if c then
		return t
	else
		return f
	end
end

prompt = function(s,sep) --more compact way of getting user input for the command line
if not sep then sep="" end
io.write(s..sep)
return io.read()
end

getfiles=function(dir) --return all files in a directory
	local out={}
	local a=io.popen("ls \""..dir:gsub("\\","/").."\"" ):read("*all")
	if a:len()==0 then --if windows
		a=io.popen("dir \""..dir:gsub("/","\\").."\" /B" ):read("*all")	
	end
	
	local n=1
	for i=1,a:len() do
		if not out[n] then out[n] = "" end
			if a:sub(i,i) ~="\n" then
				out[n]=out[n]..a:sub(i,i)
			else
				n=n+1
			end	
	end
	return out
end


function table.copy(t) --because lua tables are funny. here's a cheap workaround
	if type(t)~="table" then return t end
	local out={}
	for i,v in pairs(t) do
		if type(v)=="table" then
			out[i]=table.copy(v)
		else
			out[i]=v
		end
	end
	return out
end

function math.normalrandom(mean,deviation,samples)
	mean=mean or 0
	deviation=deviation or 1
	samples=samples or 10

	local sum=0
	for i=1,samples do
		sum=sum+math.random()
	end
	sum=sum/samples --get average

	sum=sum-.5 --account for center of .5
	sum=sum*deviation*2 -- .5 default
	sum=sum*math.sqrt(samples)/.577614 --the magic number that makes it actually base deviations
	sum=sum+mean

	return sum
end

function math.sum(t)
	local sum=0
	for _,v in pairs(t) do
		sum=sum+v
	end
	return sum
end

function math.mean(t)
	sum,n=0,0
	for _,v in pairs(t) do
		sum=sum+v n=n+1
	end
	return sum/n
end

function math.stdev(t)
	local m=math.mean(t)
	sum,n=0,0
	for _,v in pairs(t) do
		sum=sum+((v-m)^2)
		n=n+1
	end
	sum=sum/(n-1)
	sum=math.sqrt(sum)
	return sum
end

function table.next(t,v,nocycle) --nocycle argument will not wrap tables
	local out
	local fallback
	local f
	local outind
	local outindfallback
	for i,nv in pairs(t) do
		if not fallback and not nocycle then fallback=nv outindfallback=i end --if all else, set to first
		if nocycle then fallback=nv outindfallback=i end
		if f then out=nv outind=i break end
		f=nv==v
	end
	return out or fallback , outind or outindfallback
end
function table.prev(t,v,nocycle)
	local out
	local fallback
	local outind
	local outindfallback
	for i,nv in pairs(t) do
		if not fallback and nocycle then fallback=nv  outindfallback=i end
		if v==nv and out then fallback=nil outindfallback=nil break end --all else, output last
		out=nv
		outind=i
	end
	return fallback or out , outind or outindfallback
end

function table.convolve(t1,t2) --no safeguards for non-number values. oh well. that would slow it down a lot.
	if type(t1)~="table" or type(t2)~="table" then return {} end 
	local t={}
	local out={}
	local x,y=1,1 --because lua tables can have any value for a key
	for _,v1 in pairs(t1) do
		for _,v2 in pairs(t2) do
			t[x+y]=(t[x+y] or 0) + v1*v2 --add diagonals
			x=x+1
		end
		x=1
		y=y+1
	end
	
	for _,v in pairs(t) do
		table.insert(out,v)
	end
	
	return out
end
