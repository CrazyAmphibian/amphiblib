# amphiblib

a collection of functions that may or may not be useful depending on what you need



functions included;



table.tostring:

converts a table into a string, it is suitable for dofile() or dostring()

supports nested tables, string values, number values, but NOT function values. function values are instead converted into their memory representation due to a tostring operation

there is also an optional argument "keepkeys" (default false), which will preserve number keys. string keys are always preserved.



  example:

  = a={1,2,3}

  = print(table.tostring(a))

  = > {1,2,3}

  = print(table.tostring(a,true))--[[
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
prompt
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
	local a=io.popen("ls "..dir:gsub("\\","/") ):read("*all")
	if a:len()==0 then --if windows
		a=io.popen("dir "..dir:gsub("/","\\").." /B" ):read("*all")	
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



  = > {[1]=1,[2]=2,[3]=3}

  = a={1,2} a.test="foo" a.test2="bar"

  = print(table.tostring(a))

  = > {1,2,["test2"]="bar",["test"]="foo"}

  = print(table.tostring(a,true))

  = > {[1]=1,[2]=2,["test"]="foo",["test2"]="bar"}

 

 

has:

checks to see if the first argument has the second in it, and returns a boolean

number values are converted into strings, other types are ignored 

if the first value is a table, then it is iterated through to check for the second argument appearing in the first

if the first is instead a string, a :find() operation will be performed and will look for a result

  

this has also been added as string.has(), so you can use a colon to call it with a string value

  

 example:

 = a="foobar"

 = b="foo"

 = print(a:has(b))

 = > true

 = print(b:has(a))

 = >false

 = a={"foo","bar"}

 = b="foo"  

 = print(has(a,b))

 = >true

 = b="hello"  

 = print(has(a,b))

 = >false

 
 isin:
 the isin function operates exactly like the has function, but the inputs are flipped. this can be useful for string checking so that one can use a colon for cleaner looking/more readable code
 
 example:

 = a="foobar"

 = b="foo"

 = print(a:isin(b))

 = > false

 = print(b:isin(a))

 = >true

 = a={"foo","bar"}

 = b="foo"  

 = print(b:isin(a))

 = >true

 = b="hello"  

 = print(b:isin(a))

 = >false

 

string.cap:

capitalises the first letter of each word. words are seperated with " " or "."

optional argument forcelower makes all non capitals lowercase

can be called with :cap()



  example:

  = a="foo bar"

  = print(a:cap())

  = >Foo Bar

  = a="fOO BAr"

  = print(a:cap())

  = >FOO BAr

  = print(a:cap(true))

  = >Foo Bar

 

 

string.plural:

makes the given word plural using standard english rules. notice that some exception may not be caught, any may be added at a later daye

can be called on a string with :plural()

 

  example:

  = a="foo"

  = print(a:plural())

  = >foos

  = a="bar"

  = print(a:plural())

  = >bars

  = a="box"

  = print(a:plural())

  = >boxes

  

  

 string.letters:

 returns a table of all of the letters in a string

 if a non string value is provided, an empty table will be returned

 can be called with :letters()

 

 example:

 = a="foo"

 = print(table.concat(a:letters()," "))

 = >f o o

  

  

string.words:

returns a table of all the words in a string

the seperator is " " by default, but can be optionally set

a non string input will return an empty table



  example:

  = a="hello world"

  = print(table.concat(a:letters(),"\n"))

  = >hello

  = >world

  

  

 pickrandom:

 picks a random value from the provided table. if not provided with a table, returns with hte provided statment

 

  example:

  = a={1,2,3}

  = print(pickrandom(a))

  = >2

  = print(pickrandom(a))

  = >1

  = print(pickrandom(a))

  = >3

  = a="foo"

  = print(pickrandom(a))

  = >foo



cif:
an if statment, but more compact. takes 3 arguments, the condition, true output and false output



example:

  = a="foo"
  
  = b="bar"
  
  = print(cif(1==1,a,b))
  
  = > foo
  
  = print(cif(1==2,a,b))
  
  = > bar
  
  
 
  
prompt:
 calls for user input in a termilal. optional  seperator command to put something like a newline afterwards. returns a string
  
  
  example:
  
    = a=prompt("enter a number")
  
      enter a number
  
      enter a number15
  
    =print(a)
  
    = > 15
  
    = a=prompt("enter a number","\n")
  
      enter a number
  
      15
  
    =print(a)
  
    = > 15
  
  
  getfiles:
  
    returns a table of all the files in a directory. works on both linux and windows.
  
  example:
  
    = files = getfiles("Desktop")
  
    files={"file1.txt","example.png",.....}
