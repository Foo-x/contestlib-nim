import strutils, sequtils

type Matrix*[T] = ref object
  r*, c*: Positive
  data: seq[T]

proc `[]`*[T](m: Matrix[T], r, c: Natural): T =
  m.data[r + c * m.r]

proc `[]=`*[T](m: var Matrix[T], r, c: Natural, v: T) =
  m.data[r + c * m.r] = v

proc row*[T](m: Matrix[T], r: Natural): seq[T] =
  result = newSeq[T](m.c)
  for c in 0..<m.c:
    result[c] = m.data[r + c * m.r]

proc column*[T](m: Matrix[T], c: Natural): seq[T] =
  let p = c * m.r
  m.data[p..<m.r+p]

proc swapRow*[T](m: var Matrix[T], r1, r2: Natural) =
  for c in 0..<m.c:
    swap m.data[r1 + c * m.r], m.data[r2 + c * m.r]

proc swapColumn*[T](m: var Matrix[T], c1, c2: Natural) =
  for r in 0..<m.r:
    swap m.data[r + c1 * m.r], m.data[r + c2 * m.r]

proc newMatrix*[T](r, c: Positive): Matrix[T] =
  new(result)
  result.r = r
  result.c = c
  result.data = newSeq[T](r * c)

proc newMatrix*[T](n: Positive): Matrix[T] =
  newMatrix[T](n, n)

proc newMatrix*[T](arr: openArray[seq[T]]): Matrix[T] =
  new(result)
  result.r = arr.len
  result.c = arr[0].len
  result.data = newSeq[T](result.r * result.c)
  for r in 0..<result.r:
    for c in 0..<result.c:
      result[r, c] = arr[r][c]

proc toMatrix*[T](arr: openArray[seq[T]]): Matrix[T] =
  ## alias for newMatrix
  newMatrix(arr)

proc identityMatrix*[T](n: Positive): Matrix[T] =
  result = newMatrix[T](n)
  for i in 0..<n:
    result[i, i] = 1

proc `*`*[T](a, b: Matrix[T]): Matrix[T] =
  assert a.c == b.r
  result = newMatrix[T](a.r, b.c)
  for r in 0..<a.r:
    for c in 0..<b.c:
      var n: T
      for k in 0..<a.c:
        n += a[r, k] * b[k, c]
      result[r, c] = n

proc `^`*[T](m: Matrix[T], n: Positive): Matrix[T] =
  assert m.r == m.c

  var
    m = m
    n: int = n
  result = identityMatrix[T](m.r)

  while n > 0:
    if n mod 2 == 1:
      result = m * result
    m = m * m
    n = n shr 1

proc `*`*[T](a: Matrix, b: openArray[T]): seq[T] =
  assert a.c == b.len
  result = newSeq[T](b.len)
  for r in 0..<a.r:
    var n : T
    for k in 0..<a.c:
      n += a[r, k] * b[k]
    result[r] = n

proc `+`*[T](a, b: Matrix[T]): Matrix[T] =
  assert a.r == b.r and a.c == b.c
  result = newMatrix[T](a.r, a.c)
  for r in 0..<a.r:
    for c in 0..<b.c:
      result[r, c] = a[r, c] + b[r, c]

proc transpose*[T](a: Matrix[T]): Matrix[T] =
  result = newMatrix[T](a.r, a.c)
  for r in 0..<a.r:
    for c in 0..<a.c:
      result[r, c] = a[c, r]

proc gaussJordan(a: var Matrix[float], isExtended: bool = true): int =
  let
    lastColumn = if isExtended: a.c-1 else: a.c
    eps = 1e-10

  for c in 0..<lastColumn:
    # search pivot
    var
      pivot = -1
      max = eps

    for r in result..<a.r:
      if abs(a[r, c]) > max:
        max = abs(a[r, c])
        pivot = r

    if pivot == -1:
      continue

    swapRow(a, pivot, result)

    let fac = a[result, c]
    for c2 in 0..<a.c:
      a[result, c2] = a[result, c2] / fac

    # reduction
    for r in 0..<a.r:
      if r != result and abs(a[r, c]) > eps:
        let fac = a[r, c]
        for c2 in 0..<a.c:
          a[r, c2] = a[r, c2] - a[result, c2] * fac

    result += 1

proc linearEq*[T](a: Matrix[T], b: openArray[T]): seq[T] =
  ## 連立一次方程式を解きます。
  ## 解が存在しない場合は空のseqを返します。
  var
    m = newMatrix[float](a.r, a.c + 1)

  for i in 0..<a.r:
    for j in 0..<a.c:
      m[i, j] = a[i, j].float

    m[i, a.c] = b[i].float

  let
    rank = gaussJordan(m)
    eps = 1e-10

  for r in rank..<a.r:
    if abs(m[r, a.c]) > eps:
      return newSeq[T]()

  let
    isInt = typeof(a[0,0]) is int

  result = newSeqUninitialized[T](a.c)
  for i in 0..<rank:
    if isInt:
      result[i] = m[i, a.c].toInt
    else:
      result[i] = m[i, a.c].T

proc `$`*[T](m: Matrix[T]): string =
  var rows = newSeq[string](m.r)
  for r in 0..<m.r:
    rows[r] = "[" & (0..<m.c.int).toSeq.mapIt(m[r, it]).join(", ") & "]"
  result = rows.join("\n")
