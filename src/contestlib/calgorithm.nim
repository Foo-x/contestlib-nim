import algorithm, sequtils

proc minMatch*(left, right: int, pred: proc(x: int): bool): int =
  ## `left`以上`right`以下の整数のうち、`pred`を満たす最小の値を返します。
  ## `pred`を満たす値が存在しない場合は`right + 1`を返します。
  if pred(left):
    return left

  if not pred(right):
    return right + 1

  var
    ng = left - 1
    ok = right + 1

  while ok - ng > 1:
    let mid = (ok + ng) div 2
    if pred(mid):
      ok = mid
    else:
      ng = mid

  ok

proc maxMatch*(left, right: int, pred: proc(x: int): bool): int =
  ## `left`以上`right`以下の整数のうち、`pred`を満たす最大の値を返します。
  ## `pred`を満たす値が存在しない場合は`left - 1`を返します。
  if pred(right):
    return right

  if not pred(left):
    return left - 1

  var
    ng = right + 1
    ok = left - 1

  while ng - ok > 1:
    let mid = (ok + ng) div 2
    if pred(mid):
      ok = mid
    else:
      ng = mid

  ok

iterator permutations*[T](a: var openArray[T]): seq[T] =
  var v = a.toSeq
  yield v
  while v.nextPermutation():
    yield v

iterator reversedIter*[T](a: openArray[T]): T =
  for i in countdown(a.len - 1, 0):
    yield a[i]

iterator reversedPairs*[T](a: openArray[T]): tuple[key: int, val: T] =
  for i in countdown(a.len - 1, 0):
    yield (i, a[i])

proc findLast*[T](a: openArray[T], item: T): int =
  for i, x in a.reversedPairs:
    if x == item:
      return i

  return -1

proc findIf*[T](a: openArray[T], pred: proc (x: T): bool): int =
  for i, x in a.pairs:
    if pred(x):
      return i

  return -1

proc findLastIf*[T](a: openArray[T], pred: proc (x: T): bool): int =
  for i, x in a.reversedPairs:
    if pred(x):
      return i

  return -1
