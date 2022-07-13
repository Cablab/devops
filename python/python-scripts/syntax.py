#!/usr/bin/python3

### List vs Tuple ##
list1 = [1, "four", 3.2, True] # mutable
tuple1 = (1, "four", 3.2, False) # immutable

print(list1)
print(tuple1)

### Format Printing ###
color1, color2 = "blue", "purple"

print("I like the colors {} and {}".format(color1, color2))
print(f"I like the colors {color1} and {color2}")

### Slicing ###
hello = "Hello World!"
print(hello[0]) # H
print(hello[-1]) # ! (negative indexing starts from the end and goes backward)
print(hello[1:5]) # ello
print(hello[:5]) # Hello
print(hello[6:]) # World!

### Keyword Function Arguments ###
def dumb(s1, i1):
    print(f"You passed String \"{s1}\" and integer \"{i1}\"")

dumb("yup", 2) # normal call, arg order matters
dumb(i1=5, s1="wut") # keyword call, order doesn't matter if set

### Variable Length Arguments ###
"""
This is wild. For a function with a variable amount of arguments, you
access the non-keyword arguments with *args and access the arguments
that specified a keyword with **kwargs

*args is a Tuple
**kwargs is a Dictionary

Note: args and kwargs are choices. They can be *<name> and **<name>
      where <name> is whatever you want to call the variable
"""
def wow(*args, **kwargs):
    arg_sum = 0
    for arg in args:
        arg_sum+=arg
    print(f"Sum of int args: {arg_sum}")

    print(f"Dictionary of keyword args: {kwargs}")

wow(10, 11, 12, s1="this", s2="is", s3="crazy")