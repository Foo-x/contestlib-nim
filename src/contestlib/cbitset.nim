import algorithm, sequtils, bitops

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

proc fromBoolSeq*(a: openArray[bool]): BitSet =
  result = 0
  for i in 0..<a.len:
    result[i] = a[i]

proc keys*(a: BitSet): seq[int] =
  (0..bitLen(typeof a)).toSeq.filterIt(a[it])

proc fromKeys*(keys: openArray[int]): BitSet =
  result = 0
  for k in keys:
    result[k] = true

proc toBinSeq*(a: BitSet, maxLen: range[0..bitLen(int)+1] = 0): seq[int] =
  ## 2進数のseqに変換します。
  ## `maxLen`が0の場合、`BitSet`を表す最短の長さで返します。
  runnableExamples:
    doAssert 29.toBinSeq() == @[1, 1, 1, 0, 1]
    doAssert 29.toBinSeq(3) == @[1, 0, 1]
    doAssert 29.toBinSeq(10) == @[0, 0, 0, 0, 0, 1, 1, 1, 0, 1]

  if maxLen == 0:
    var i = 0
    while 1 shl i <= a:
      result.insert(if a.testBit i: 1 else: 0, 0)
      i += 1

  else:
    result = newSeq[int](maxLen)
    for i in 0..<maxLen:
      result[^(i+1)] = if a.testBit i: 1 else: 0

proc fromBinSeq*(bs: openArray[int]): BitSet =
  ## 2進数のseqから`BitSet`に変換します。
  ## 2進数以外の値が含まれていた場合は0を返します。
  runnableExamples:
    doAssert @[1, 1, 1, 0, 1].fromBinSeq() == 29
    doAssert @[0, 0, 0, 0, 0, 1, 1, 1, 0, 1].fromBinSeq() == 29
    doAssert @[1, 1, 2, 0, 1].fromBinSeq() == 0

  if bs.filterIt(it != 0 and it != 1).len > 0:
    return 0
  if bs.find(1) == -1:
    return 0

  result = 0
  for i in bs.reversed.find(1)..<(bs.len - bs.find(1)):
    if bs[^(i+1)] == 1:
      result += 1 shl i
