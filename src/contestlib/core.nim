import math

const
  InfInt* = 10^12
  NegInfInt* = -10^12
  MOD* = 10^9 + 7

template loop*(n: int, body) = (for _ in 0..<n: body)
template `max=`*(x, y) = x = max(x, y)
template `min=`*(x, y) = x = min(x, y)
