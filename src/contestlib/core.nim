import math

const
  InfInt* = 10^18
  NegInfInt* = -10^18
  MOD* = 10^9 + 7

template loop*(n: int, body) = (for _ in 0..<n: body)
template `max=`*(x, y) = x = max(x, y)
template `min=`*(x, y) = x = min(x, y)
