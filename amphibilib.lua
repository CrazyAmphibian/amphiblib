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

function table.tostring(t,showallkeys,humanmode,rlevel,exclude)
	rlevel=rlevel or 1
	if not humanmode then rlevel=0 end
	exclude=exclude or {t} --internal use. prevent tables with themselves causing a stack overflow
	local formatnontab=function(val)
		if type(val)=="string" then
			local out="\""
			for i=1,#val do
				local n=val:sub(i,i):byte()
				if n>=0x20 and n<=0x7e and n~=0x5c and n~=0x22 then --standard letters that do not break
					out=out..val:sub(i,i)
				else
					nc="00"..n
					nc=nc:sub(#nc-2)
					out=out.."\\"..nc --for special characters, use decimal representation
				end
				
			end
			return out.."\""
		elseif type(val)=="number" then
			if val==1/0 then val="1/0" end  --inf --these are special cases which do not convet with tostring()
			if val==-1/0 then val="-1/0" end -- -inf
			if tostring(val)=="nan" then val="0/0" end -- nan. nan is weird, but we include it because the point is to save all the data, not cherry pick it.
			return tostring(val)
		elseif type(val)=="boolean" then
			return tostring(val)
		elseif val==nil then
			return "nil"
		elseif type(val)=="function" then
			return "load("..table.tostring(string.dump(val))..")"
		end

	end

	local function isexcluded(val)
		for _,v in pairs(exclude) do
			if v==val then return true end
		end
	end

	if type(t)~="table" then return	formatnontab(t) end
	local out="{"
	if humanmode then out=out.."\n" end
	for i,v in pairs(t) do
		local ti,tv=type(i),type(v)
		if (ti=="number" or ti=="string" or ti=="boolean") and (tv=="number" or tv=="string" or tv=="table" or tv=="boolean" or tv==nil or tv=="function") and not isexcluded(v) then --only results we can actually record

			for i=1,rlevel do
				out=out.."\t"	
			end

			if ti~="number" or showallkeys then
				out=out.."["..formatnontab(i).."]="	
			end

			if tv~="table" then
				out=out..formatnontab(v)
			else
				table.insert(exclude,v)
				out=out..table.tostring(v,showallkeys,humanmode,rlevel+1,exclude)
			end


			out=out..","
			if humanmode then out=out.."\n" end
		end
	end
	for i=1,rlevel-1 do out=out.."\t" end
	out=out.."}"
	return out

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

string.words = function(s,seperator,keepsep) 
if type(s)~="string" then return {} end
if type(seperator)~="table" then seperator={seperator or ""} end
local out={}
local n=1
local i=1

repeat
	for _,sp in pairs(seperator) do
		local cw=s:sub(i,i)
		if sp==cw or cw=="" then
			out[#out+1]=s:sub(n,i-1)
			if keepsep and cw~="" then
				out[#out+1]=cw
			end
			n=i+1
		end
	end
i=i+1
until n>=#s

return out
end


pickrandom = function(s) --pick a random item in the table
if type(s) ~= "table" then return s end
local len=0
for _ in pairs(s) do len=len+1 end
local rng = math.random(1,len)
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


getfiles=function(dir,OS) --return just files in a directory, not subdirectories
	dir=dir or "./"
	local out={}
	local a
	if not OS or OS:lower()~="windows" then
	a=io.popen("ls \""..dir:gsub("\\","/").."\" -p | grep -v /" ):read("*all")
	end
	if (a or ""):len()==0 or (OS or ""):lower()=="windows" then --if windows
		a=io.popen("dir \""..dir:gsub("/","\\").."\" /b /a-d" ):read("*all")	
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

getdirs=function(dir,OS) --return directories in a directory.
	dir=dir or "./"
	local out={}
	local a
	if not OS or OS:lower()~="windows" then
	print("ls \""..dir:gsub("\\","/").."\" -F | grep / | cut -f1 -d\"/\"")
	a=io.popen("ls \""..dir:gsub("\\","/").."\" -F | grep / | cut -f1 -d\"/\"" ):read("*all")
	end
	if (a or ""):len()==0 or (OS or ""):lower()=="windows" then --if windows
		a=io.popen("dir \""..dir:gsub("/","\\").."\" /b /ad" ):read("*all")	
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



function string.search(target,substring) --less fancy string.find that will always "just work"
if type(target) ~= "string" then return nil end
if not substring or type(substring) ~= "string" then return nil end
for i=1,#target-#substring+1 do
	if target:sub(i,i+#substring-1)==substring then
		return i,i+#substring-1
	end
end
end

--print(string.search("hello","o") )

function string.replace(base,pattern,repl) --gsub is kinda annoying to work with with the special formatting. let's fix that.
local newstr=""
local n=1

local stringsearch=function(target,substring) --here so you can remove the one above with no issues.
if type(target) ~= "string" then return nil end
if not substring or type(substring) ~= "string" then return nil end
for i=1,#target-#substring+1 do
	if target:sub(i,i+#substring-1)==substring then
		return i,i+#substring-1
	end
end
end

	repeat
		local sr,sr2=stringsearch(base:sub(n),pattern)
		
		if sr then
			newstr=newstr..base:sub(n,sr-1)
			newstr=newstr..repl
			n=sr2+1
		end
		if not sr then
			newstr=newstr..base:sub(n)
			n=n+#base:sub(n)
		end
	until n>#base

return newstr
end


function table.merge(basetable,addtable,protect) --push the contents of addtable into basetable. addtable will overwrite basetable unless protect is true
	local tabcop=function(tab) --copies a table without setting them equal. ensures ability to modify tables without changing the base.
		local out={}
		for i,v in pairs(tab) do
			if type(v)~="table" then
				out[i]=v
			else
				out[i]=tabcop(v)
			end
		end
		return out
	end

local out=tabcop(basetable) --first make a deep copy of the base table.

	for i,v in pairs(addtable) do --next let's go through what to add.
		if type(out[i])=="table" and type(addtable[i])=="table" then --if both tables
			out[i]=table.merge(out[i],addtable[i],protect)
			
		elseif (not out[i]) or (not protect) then --if not found in basetable, or protect.
			out[i]=v
		end
	end
	
return out
end

function consoleformat(text,style) --uses ANSI escape sequences to make stuff colorful. each call will also reset existing formatting.
	style=style or {}
	local newt="\27["
	local prev=false

	if style.fg then
		newt=newt.. (prev and ";" or "")
		newt=newt.."38;5;"..style.fg
		prev=true
	end

	if style.bg then
		newt=newt.. (prev and ";" or "")
		newt=newt.."48;5;"..style.bg
		prev=true
	end

	if style.blink then
		newt=newt.. (prev and ";" or "")
		newt=newt.."5"
		prev=true
	end

	if style.bold then
		newt=newt.. (prev and ";" or "")
		newt=newt.."1"
		prev=true
	end

	if style.italic then
		newt=newt.. (prev and ";" or "")
		newt=newt.."3"
		prev=true
	end

	if style.underline then
		newt=newt.. (prev and ";" or "")
		newt=newt.."4"
		prev=true
	end

	if style.strike then
		newt=newt.. (prev and ";" or "")
	newt=newt.."9"
		prev=true
	end

	if style.overline then
		newt=newt.. (prev and ";" or "")
		newt=newt.."53"
		prev=true
	end

	newt=newt.."m"..text.."\27[0m"
	return newt
end



function math.convertbase(number,from,to) --NOTICE:: returns a string, even in base 10 mode!
	local isneg=number:sub(1,1)=="-"
	number=(isneg and number:sub(2) or number)
	to=to or 10
	if from>36 or from<2 then error("invalid base: "..from) end
	if to>36 or to<2 then error("invalud base: "..to) end
	local out=""
	local c=0
	local basetable={ --god i fucking love lua tables
	--dec
	[0]="0",
	["0"]=0,
	[1]="1",
	["1"]=1,
	[2]="2",	
	["2"]=2,
	[3]="3",
	["3"]=3,
	[4]="4",
	["4"]=4,
	[5]="5",
	["5"]=5,
	[6]="6",
	["6"]=6,
	[7]="7",
	["7"]=7,
	[8]="8",
	["8"]=8,
	[9]="9",
	["9"]=9,
	--hex
	[10]="A",
	["A"]=10,
	[11]="B",
	["B"]=11,
	[12]="C",
	["C"]=12,
	[13]="D",
	["D"]=13,
	[14]="E",
	["E"]=14,
	[15]="F",
	["F"]=15,	
	--base 36
	[16]="G",
	["G"]=16,
	[17]="H",
	["H"]=17,
	[18]="I",
	["I"]=18,
	[19]="J",
	["J"]=19,
	[20]="K",
	["K"]=20,
	[21]="L",
	["L"]=21,
	[22]="M",
	["M"]=22,
	[23]="N",
	["N"]=23,
	[24]="O",
	["O"]=24,
	[25]="P",
	["P"]=25,	
	[26]="Q",
	["Q"]=26,	
	[27]="R",
	["R"]=27,	
	[28]="S",
	["S"]=28,	
	[29]="T",
	["T"]=29,		
	[30]="U",
	["U"]=30,	
	[31]="V",
	["V"]=31,	
	[32]="W",
	["W"]=32,	
	[33]="X",
	["X"]=33,	
	[34]="Y",
	["Y"]=34,	
	[35]="Z",
	["Z"]=35,	
	}
	
	for i=1,#number do
	c=c*from
	c=c+basetable[number:sub(i,i)] or 0
	end

	for q=math.ceil(math.log(c+1,to) ),1,-1 do --get how many places there will be. TODO: don't use log, use a solution using intiger math only, because it loses accuracy.
		for i=to-1,0,-1 do --count down digits
			if c>=i*(to^(q-1)) then
				out=out..basetable[i] or ""
				c=c-i*(to^(q-1))
				break
			end
		end
	end
	
	return (isneg and "-" or "") ..out
end


function table.equal(a,b)
	local ta,tb=type(a),type(b)
	if ta~="table" and tb~="table" then
		return a==b
	elseif (ta=="table" and tb~="table") or (tb=="table" and ta~="table") then
		return false
	end

	for i,v in pairs(a) do
		if not table.equal(a[i],b[i]) then
			return false
		end
	end
	for i,v in pairs(b) do
		if not table.equal(a[i],b[i]) then
			return false
		end
	end

	return true
end

function table.count(t)
	local n=0
	if not t or type(t)~="table" then return 0 end
	for i,v in pairs(t) do n=n+1 end
	return n
end

function table.dump(t,exclude)
	exclude=exclude or {t} --internal use. prevent tables with themselves causing a stack overflow
	local formatnontab=function(val)
		if type(val)=="string" then
			return "\""..val:gsub("\\","\\\\"):gsub("\"","\\\""):gsub("\n","\\n"):gsub("\r","\\r").."\""
		elseif type(val)=="number" then
			if val==1/0 then return "1/0" end  --inf --these are special cases which do not convert with tostring()
			if val==-1/0 then return "-1/0" end -- -inf
			if tostring(val)=="nan" then return "0/0" end -- nan. nan is weird, but we include it because the point is to save all the data, not cherry pick it.
			return tostring(val)
		elseif type(val)=="function" then
			return "load("..table.dump(string.dump(val))..")"
		else
			return tostring(val)
		end

	end

	local function isexcluded(val)
		for i=1,#exclude do
			if exclude[i]==val then return true end
		end
	end

	if type(t)~="table" then return	formatnontab(t) end
	local out="{"
	if humanmode then out=out.."\n" end
	for i,v in pairs(t) do
		local ti,tv=type(i),type(v)
		if (ti=="number" or ti=="string" or ti=="boolean") and (tv=="number" or tv=="string" or tv=="table" or tv=="boolean" or tv==nil or tv=="function") and not isexcluded(v) then --only results we can actually record

			out=out.."["..formatnontab(i).."]="	

			if tv~="table" then
				out=out..formatnontab(v)
			else
				exclude[#exclude+1]=v
				out=out..table.dump(v,exclude)
			end

			out=out..","
		end
	end

	out=out.."}"
	return out
end

function table.diff(basetable,newtable,activeindex) --returns a string which, when executed as code, will make it so that basetable will become newtable
		local formatnontab=function(val)
		if type(val)=="string" then
			return "\""..val:gsub("\\","\\\\"):gsub("\"","\\\""):gsub("\n","\\n"):gsub("\r","\\r").."\""
		elseif type(val)=="number" then
			if val==1/0 then val="1/0" end  --inf --these are special cases which do not convet with tostring()
			if val==-1/0 then val="-1/0" end -- -inf
			if tostring(val)=="nan" then val="0/0" end -- nan. nan is weird, but we include it because the point is to save all the data, not cherry pick it.
			return tostring(val)
		elseif type(val)=="boolean" then
			return tostring(val)
		elseif val==nil then
			return "nil"
		elseif type(val)=="function" then
			return "load("..table.tostring(string.dump(val))..")"
		else
			error("non-transferable type "..type(val))
		end

	end
	
	
	local output=""
	--an issue i realized is how the fuck we will add indices to a table whose varible name we don't know...
	--due to load()() executing with an _ENV of _G (unless you use fancy functions), the safest bet will be using the go-to fallback varible of _.
	--so i guess if you're doing stuff like setfenv(), you'll have to be mindful and pass your table in as _.
	
	if type(newtable)=="table" then
		if type(basetable)~="table" then
			output=output..(activeindex and string.format("_%s=%s;",activeindex,table.dump(newtable)) or string.format("_=%s;",table.dump(newtable) ))
			basetable={}
			return output
		end
		
	for i,v in pairs(newtable) do
		local activeindex=(activeindex or "")..string.format("[%s]",formatnontab(i))
		local btv=basetable[i]
		if not table.equal(v,btv) then
			if type(v)=="table" then
				output=output..table.diff(btv,v,activeindex)
			else
				output=output..string.format("_%s=%s;",activeindex,formatnontab(v))
			end
		end
	end
	
	for i,v in pairs(basetable) do
		local activeindex=(activeindex or "")..string.format("[%s]",formatnontab(i))
		if not newtable[i] then
			output=output..string.format("_%s=nil;",activeindex)
		end
	end
	else
		output=output..(activeindex and string.format("_%s=%s;",activeindex,formatnontab(newtable)) or string.format("_=%s;",formatnontab(newtable)))
	end
	
	return output
end
