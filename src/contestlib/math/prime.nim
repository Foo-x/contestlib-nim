import std/math, sequtils, random, tables, algorithm
from ./modint import modpow

randomize()

proc isPrime*(n: Positive): bool =
  ## 決定的素数判定を行います。
  ## O(N^(1/2))
  if n == 1:
    return false
  if n == 2 or n == 3:
    return true
  if n mod 2 == 0:
    return false

  for i in countup(3, n.toFloat.sqrt.int, 2):
    if n mod i == 0:
      return false

  return true

proc isProbablyPrime(n: Positive): bool =
  ## 確率的素数判定を行います。
  ## Miller-Rabin法: O(25*log^3(N))
  ## 偽陽性確率: (1/4)^25 < 1e-15
  ## 偽陰性確率: 0
  ## TODO: 大きい数はbigintでないとoverflowするので一旦private
  if n == 2:
    return true
  if n == 1 or (n and 1) == 0:
    return false

  var
    d = n-1
  while (d and 1) == 0:
    d = d shr 1

  for _ in 0..<25:
    var
      a = rand(n-2) + 1
      t = d
      y = modpow(a, t, n)

    while t != n-1 and y != 1 and y != n-1:
      y = (y * y) mod n
      t = t shl 1

    if y != n-1 and (t and 1) == 0:
      return false

  return true

proc getPrimesTable*(n: Positive): seq[bool] =
  ## n以下の素数表を返します。
  ## エラトステネスの篩: O(Nloglog(N))
  result = newSeqWith(n+1, true)
  result[0] = false
  result[1] = false
  for i in 2..n.toFloat.sqrt.int:
    if not result[i]:
      continue
    for j in countup(i*2, n, i):
      result[j] = false

proc getPrimes*(n: Positive): seq[int] =
  ## n以下の素数リストを返します。
  ## エラトステネスの篩: O(Nloglog(N))
  let primesTable = getPrimesTable(n)
  result = @[]
  for i, p in primesTable:
    if p:
      result.add i

proc primeFactorize*(n: Positive): CountTable[int] =
  if n == 1:
    return

  var n = n
  for i in 2..n.toFloat.sqrt.int:
    while n mod i == 0:
      n = n div i
      result.inc(i)

  if n != 1:
    result.inc(n)

proc getDivisors*(n: Positive): seq[int] =
  result = @[]
  for i in 1..n.float.sqrt.int:
    if n mod i == 0:
      result.add i
      if i * i != n:
        result.add n div i

  result.sort()
