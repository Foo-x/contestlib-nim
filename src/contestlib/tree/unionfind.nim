type
  UnionFind* = seq[int]
    ## 各クエリはO(α(N))
    ## α(N)はアッカーマン関数の逆関数でほぼ定数


proc newUnionFind*(size: int): UnionFind =
  result = newSeqUninitialized[int](size)
  for i in 0..<size:
    result[i] = i

proc root*(uf: var UnionFind, x: int): int =
  if uf[x] == x:
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
  if uf[rx] == uf[ry]:
    uf[rx] -= 1
  uf[ry] = rx

  return true

proc count*(uf: var UnionFind, x: int): int =
  let root = uf.root(x)
  for p in uf:
    if uf.root(p) == root:
      result += 1
