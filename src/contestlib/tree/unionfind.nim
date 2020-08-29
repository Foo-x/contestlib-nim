type
  UnionFind* = seq[int]
    ## 各クエリはO(α(N))
    ## α(N)はアッカーマン関数の逆関数でほぼ定数

proc newUnionFind*(size: int): UnionFind =
  result = newSeqUninitialized[int](size)
  for i in 0..<size:
    result[i] = -1

proc root*(uf: var UnionFind, x: int): int =
  if uf[x] < 0:
    return x

  uf[x] = uf.root(uf[x])
  return uf[x]

proc isSame*(uf: var UnionFind, x, y: int): bool =
  uf.root(x) == uf.root(y)

proc merge*(uf: var UnionFind, x, y: int): bool {.discardable.} =
  var
    rx = uf.root(x)
    ry = uf.root(y)

  if rx == ry:
    return false

  if uf[ry] < uf[rx]:
    swap rx, ry
  uf[rx] += uf[ry]
  uf[ry] = rx

  return true

proc count*(uf: var UnionFind, x: int): int =
  -uf[uf.root(x)]
