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

macro read*(ts: varargs[auto]): untyped =
  var tupStr = ""
  for t in ts:
    tupStr &= &"read({t.repr}),"
  parseExpr(&"({tupStr})")

macro read*(n: int, ts: varargs[auto]): untyped =
  var
    idents = newStmtList()
    asgns = newStmtList()
    tupStr = ""
  let index = ident("i")
  for j, typ in ts:
    idents.add parseExpr(&"var v{j} = newSeq[{typ}]({n.repr})")
    asgns.add parseExpr(&"v{j}[{index}] = read({typ})")
    tupStr &= &"v{j},"
  let tup = parseExpr(&"({tupStr})")

  result = quote do:
    block:
      `idents`
      for `index` in 0..<`n`:
        `asgns`
      `tup`
