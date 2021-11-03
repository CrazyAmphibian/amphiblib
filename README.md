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
  = print(table.tostring(a,true))
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
