import heapqueue, sequtils

const
  InfInt = 1e18.int

type
  Edge* = tuple[dst, cost: int]

proc `<`(a, b: Edge): bool = a.cost < b.cost

proc dijkstra*(G: seq[seq[Edge]], start: int): seq[int] =
  ## 負数を含まない重み付きグラフの`start`から各ノードへの最短距離を返します。
  ## `G`は隣接リスト
  ## ダイクストラ法: O(ElogE)
  result = newSeqWith(G.len, -1)

  var queue = initHeapQueue[Edge]()
  queue.push((start, 0))

  while queue.len > 0:
    let (src, cost) = queue.pop()
    if result[src] != -1:
      continue

    result[src] = cost

    for edge in G[src]:
      if result[edge.dst] != -1:
        continue

      queue.push((edge.dst, cost + edge.cost))

proc bfs*(G: seq[seq[int]], start: int): seq[int] =
  ## 重みなしグラフの`start`から各ノードへの最短距離を返します。
  ## `G`は隣接リスト
  ## 幅優先探索: O(E)
  result = newSeqWith(G.len, -1)
  result[start] = 0

  var queue = initHeapQueue[int]()
  queue.push(start)

  while queue.len > 0:
    let src = queue.pop()
    for edge in G[src]:
      if result[edge] != -1:
        continue

      result[edge] = result[src] + 1
      queue.push(edge)

proc spfa*(G: seq[seq[Edge]], start: int): seq[int] =
  ## 負数を含む重み付きグラフの`start`から各ノードへの最短距離を返します。
  ## 負の閉路を含む場合は空の`seq`を返します。
  ## `G`は隣接リスト
  ## Shortest Path Faster Algorithm(改良版ベルマンフォード法): O(EV)
  result = newSeqWith(G.len, InfInt)
  var
    queue = newSeq[int]()
    inQueue = newSeq[bool](G.len)
    counts = newSeq[int](G.len)

  queue.insert(start, 0)
  result[start] = 0
  inQueue[start] = true
  counts[start] = 1

  while queue.len > 0:
    let src = queue.pop()
    inQueue[src] = false

    for edge in G[src]:
      if result[src] + edge.cost >= result[edge.dst]:
        continue

      result[edge.dst] = result[src] + edge.cost
      if inQueue[edge.dst]:
        continue
      if counts[edge.dst] >= G.len:
        return @[]

      counts[edge.dst] += 1
      inQueue[edge.dst] = true
      queue.insert(edge.dst, 0)

proc warshallFroyd*(G: seq[seq[int]]): seq[seq[int]] =
  ## 負数を含む重み付きグラフの全ノード間の最短距離を返します。
  ## `G`は隣接行列（非連結は無限大）
  ## ワーシャルフロイド法: O(V^3)
  result = G
  let n = G.len
  for k in 0..<n:
    for i in 0..<n:
      for j in 0..<n:
        result[i][j] = result[i][j].min(result[i][k] + result[k][j])
