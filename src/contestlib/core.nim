import math

const
  InfInt* = 1e18.int
  NegInfInt* = -1e18.int
  MOD* = 10^9 + 7

template loop*(n: int, body) = (for _ in 0..<n: body)
template `max=`*(x, y) = x = max(x, y)
template `min=`*(x, y) = x = min(x, y)
template `mod=`*(x, y) = x = x mod y
template `sumMod=`*(x, y, m = MOD) = x = (x + y) mod m
template `prodMod=`*(x, y, m = MOD) = x = (x * y) mod m
