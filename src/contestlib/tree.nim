import tree/bit
import algorithm

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
