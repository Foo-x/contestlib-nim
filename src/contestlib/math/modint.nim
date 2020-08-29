type
  ModInt* = object
    v*: Natural # 0..<m
    m*: Positive

proc toModInt*(v: int, m: Positive): ModInt =
  let
    v =
      if v < -m:
        ((v mod m) + m) mod m
      elif v < 0:
        v + m
      elif v < m:
        v
      else:
        v mod m

  result = ModInt(v: v, m: m)

proc `+`*(a, b: ModInt): ModInt =
  var v = a.v + b.v
  if v >= a.m:
    v = v mod a.m

  result = ModInt(v: v, m: a.m)

proc `*`*(a, b: ModInt): ModInt =
  var v = a.v * b.v
  if v >= a.m:
    v = v mod a.m

  result = ModInt(v: v, m: a.m)

proc `^`*(a: ModInt, b: Natural): ModInt =
  if a.v == 0:
    return 0.toModInt a.m
  if b == 0:
    return 1.toModInt a.m
  if b == 1:
    return a
  if b > a.m:
    return a^(b mod (a.m-1))

  let pow = a^(b div 2)
  if b mod 2 == 0:
    return pow * pow
  return pow * pow * a

proc `+`*(a: int, b: ModInt): ModInt =
  a.toModInt(b.m) + b

proc `+`*(a: ModInt, b: int): ModInt =
  a + b.toModInt(a.m)

proc `-`*(a: ModInt, b: int): ModInt =
  a + -b

proc `-`*(a, b: ModInt): ModInt =
  a + -b.v

proc `-`*(a: int, b: ModInt): ModInt =
  a.toModInt(b.m) + -b.v

proc `*`*(a: int, b: ModInt): ModInt =
  a.toModInt(b.m) * b

proc `*`*(a: ModInt, b: int): ModInt =
  a * b.toModInt(a.m)

proc `/`*(a: ModInt, b: int): ModInt =
  ## aの法が素数でない場合は意図しない挙動になる可能性があります。
  a * b.toModInt(a.m)^(a.m-2)

proc `/`*(a, b: ModInt): ModInt =
  ## aの法が素数でない場合は意図しない挙動になる可能性があります。
  a / b.v

proc `+=`*(a: var ModInt, b: ModInt) =
  a = a + b

proc `+=`*(a: var ModInt, b: int) =
  a = a + b

proc `-=`*(a: var ModInt, b: ModInt) =
  a = a - b

proc `-=`*(a: var ModInt, b: int) =
  a = a - b

proc `*=`*(a: var ModInt, b: ModInt) =
  a = a * b

proc `*=`*(a: var ModInt, b: int) =
  a = a * b

proc `/=`*(a: var ModInt, b: ModInt) =
  a = a / b

proc `/=`*(a: var ModInt, b: int) =
  a = a / b

proc modpow*(a, b: int, m: Natural): int =
  (a.toModInt(m)^b).v
