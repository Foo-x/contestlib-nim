type
  BIT*[T] = ref object
    data: seq[T]

proc newBIT*[T](n: Natural): BIT[T] =
  new(result)
  result.data = newSeq[T](n+1)

proc add*[T](bit: BIT[T], i: Natural, v: T) =
  ## 1-indexed add
  var i = i
  while i < bit.data.len:
    bit.data[i] += v
    i += i and -i

proc add0*[T](bit: BIT[T], i: Natural, v: T) =
  ## 0-indexed add
  add(bit, i + 1, v)

proc sum*[T](bit: BIT[T], i: Natural): T =
  ## 1-indexed sum
  var i = i
  while i > 0:
    result += bit.data[i]
    i -= i and -i

proc sum0*[T](bit: BIT[T], i: Natural): T =
  ## 0-indexed sum
  sum(bit, i + 1)

proc `$`*(bit: BIT): string =
  $bit.data
