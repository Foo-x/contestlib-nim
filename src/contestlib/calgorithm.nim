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
