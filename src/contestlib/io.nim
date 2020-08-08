import strformat, macros, strutils

let readNext = iterator(getsChar: bool = false): string {.closure.} =
  for s in stdin.readAll.split:
    if getsChar:
      for i in 0..<s.len():
        yield s[i..i]
    else:
      yield s

proc read*(t: typedesc[string]): string = readNext()
proc read*(t: typedesc[char]): char = readNext(true)[0]
proc read*(t: typedesc[int]): int = readNext().parseInt
proc read*(t: typedesc[float]): float = readNext().parseFloat

macro read*(t: typedesc, n: varargs[int]): untyped =
  var repStr = ""
  for arg in n:
    repStr &= &"({arg.repr}).newSeqWith "
  parseExpr(&"{repStr}read({t})")
