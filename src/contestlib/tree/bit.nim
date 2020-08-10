type
  BIT*[T] = ref object
    data: seq[T]
    apply: proc(x, y: T): T
    unit: T

proc newBIT*[T](n: Natural, apply: proc(x, y: T): T, unit: T): BIT[T] =
  new(result)
  result.data = newSeq[T](n+1)
  for i in 1..n:
    result.data[i] = unit
  result.apply = apply
  result.unit = unit

proc newBIT*[T](n: Natural): BIT[T] =
  newBIT[T](n, proc(x, y: T): T = x + y, 0)

proc newMaxBIT*[T](n: Natural): BIT[T] =
  newBIT[T](n, proc(x, y: T): T = (if x >= y: x else: y), -1e18.T)

proc newMinBIT*[T](n: Natural): BIT[T] =
  newBIT[T](n, proc(x, y: T): T = (if x <= y: x else: y), 1e18.T)

proc update*[T](bit: BIT[T], i: Positive, v: T) =
  ## 1-indexed
  var i = i
  while i < bit.data.len:
    bit.data[i] = bit.apply(bit.data[i], v)
    i += i and -i

proc update0*[T](bit: BIT[T], i: Natural, v: T) =
  ## 0-indexed
  update(bit, i + 1, v)

proc until*[T](bit: BIT[T], i: Positive): T =
  ## 1-indexed
  var i: int = i
  result = bit.unit
  while i > 0:
    result = bit.apply(result, bit.data[i])
    i -= i and -i

proc until0*[T](bit: BIT[T], i: Natural): T =
  ## 0-indexed
  until(bit, i + 1)

proc add*[T](bit: BIT[T], i: Positive, v: T) =
  ## alias for update
  update(bit, i, v)

proc add0*[T](bit: BIT[T], i: Natural, v: T) =
  ## alias for update0
  update0(bit, i, v)

proc sum*[T](bit: BIT[T], i: Positive): T =
  ## alias for until
  until(bit, i)

proc sum0*[T](bit: BIT[T], i: Natural): T =
  ## alias for until0
  until0(bit, i)

proc `$`*(bit: BIT): string =
  $bit.data[1..^1]
