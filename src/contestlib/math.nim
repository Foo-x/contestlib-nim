import std/math

proc isSquare*(n: Positive): bool =
  n.float.sqrt.int^2 == n

proc xorTo(x: Natural): int =
  let
    onesCnt = (x+1) div 2
    xorOnesCnt = if onesCnt mod 2 == 0: 0 else: 1

  if x mod 2 == 0:
    result = xorOnesCnt xor x
  else:
    result = xorOnesCnt

proc xorRange*(first, last: Natural): int =
  if first == 0:
    result = xorTo(last)
  else:
    result = xorTo(last) xor xorTo(first - 1)
