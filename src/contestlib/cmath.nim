import math

proc isSquare*(n: Positive): bool =
  n.float.sqrt.int^2 == n
