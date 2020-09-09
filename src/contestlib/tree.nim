import tree/[bit, unionfind]
import std/algorithm

proc invCount*[T](s: openArray[T]): int =
  ## `s`の最大値を長さとするBITを使用し、転倒数を計算して返します。
  var bit = newBIT[T](s.max)
  for i in 0..<s.len:
    result += i - bit.sum(s[i])
    bit.add(s[i], 1)

proc invCountWithLen*[T](s: openArray[T]): int =
  ## `s`の長さを長さとするBITを使用し、転倒数を計算して返します。
  var
    bit = newBIT[T](s.len)
    sortedS = s.sorted()

  for i in 0..<s.len:
    var index = sortedS.find(s[i])
    result += i - bit.sum0(index)
    bit.add0(index, 1)

type
  Edge* = tuple[src, dst, cost: int]

proc kruskal*(edges: seq[Edge], maxN: int): int =
  ## 最小全域木の和を返します。
  ## クラスカル法: O(ElogV)
  var uf = newUnionFind(maxN)
  for e in edges.sortedByIt(it.cost):
    if uf.isSame(e.src, e.dst):
      continue

    uf.merge(e.src, e.dst)
    result = max(result, e.cost)
