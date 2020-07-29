import sequtils

proc bitLen(t: typedesc): int =
  sizeof(t) * 8 - 1

type
  BitSet* = SomeInteger
  BitsRange*[T] = range[0..bitLen(T)]

proc `[]=`*(a: var BitSet, i: BitsRange[typeof a], exists: bool) =
  if exists:
    a = a or (1 shl i)
  else:
    a = a and (not (1 shl i))

proc `[]`*(a: BitSet, i: BitsRange[typeof a]): bool =
  (a and (1 shl i)) != 0

proc toBoolSeq*(a: BitSet): seq[bool] =
  (0..bitLen(typeof a)).mapIt(a[it])

proc fromBoolSeq*(a: seq[bool]): BitSet =
  result = 0
  for i in 0..<a.len:
    result[i] = a[i]

proc keys*(a: BitSet): seq[int] =
  (0..bitLen(typeof a)).toSeq.filterIt(a[it])

proc fromKeys*(keys: seq[int]): BitSet =
  result = 0
  for k in keys:
    result[k] = true
