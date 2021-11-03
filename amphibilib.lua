--[[
## Amphibilib
## the amphibian library

included functions:

table.tosring | convert a table to a usable string. can be set to keep all numeric keys.
has, string.has | check to see if the first term contains the second. returns a bool
string.cap | makes letters capital. can be set to force proper casing
string.plural | makes a word plural using english rules
string.letters | returns a table with all letters in a string. returns empty if not string.
string.words | returns a table with all words. space is the default seperator
pickrandom | picks a random item in a table.

]]


table.tostring = function(tab,keepkeys) --converts a table to a string. keepkeys will keep numeric type keys. it will always keep string keys
if type(tab)~="table" then return tab end --only execute if its a table
local textout=""
if not keepkeys then keepkeys=false end
local currentlen = 0
textout=textout.."{"
local targetlen=0
for _ in pairs(tab) do targetlen=targetlen+1 end
	for i,v in pairs(tab) do	
		if type(v)=="table" then
		textout=textout..table.tostring(v)		
		elseif type(v)=="function" then --in the event of a function, just convert it lazily
			if keepkeys or type(i)~="number" then
				if type(i)=="number" then
					textout=textout.."["..i.."]="	
				else
					textout=textout.."[\""..i.."\"]="	
				end	
			end
			textout=textout.."\""..tostring(v).."\""
		elseif type(v)=="string" then
			if keepkeys or type(i)~="number" then
				if type(i)=="number" then
					textout=textout.."["..i.."]="	
				else
					textout=textout.."[\""..i.."\"]="	
				end	
			end
			textout=textout.."\""..v.."\""
		else	
			if keepkeys or type(i)~="number" then
				if type(i)=="number" then
					textout=textout.."["..i.."]="	
				else
					textout=textout.."[\""..i.."\"]="	
				end
			end
			textout=textout..v		
		end			
		currentlen=currentlen+1
		if currentlen<targetlen then textout=textout.."," end		
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

string.words = function(s,seperator) --extract words into a table. can set a custom separator default " "
if type(s) ~= "string" then return {} end
local sep=seperator
if not seperator then sep=" " end
local out={}
local n=1
	for i=1,#s do
		if s:sub(i,i) ~= sep then
			if not out[n] then out[n]="" end
			out[n]=out[n]..s:sub(i,i)
		else
		n=n+1
		end
	end
return out	
end


pickrandom = function(s) --pick a random item in the table
if type(s) ~= "table" then return s end
local rng = math.random(1,#s)
local n=0
	for _,v in pairs(s) do
	n=n+1
	if n==rng then return v end
	end
end