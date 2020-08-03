## Treap

import options, sugar, strformat

type
  Treap* = ref object
    value*: int
    priority*: int
    left*: Option[Treap]
    right*: Option[Treap]

  WalkOrder* = enum
    Pre, In, Post, Level

proc newTreap*(value: int, priority: int, left: Option[Treap], right: Option[
    Treap]): Treap =
  Treap(value: value, priority: priority, left: left, right: right)

proc newTreap*(value: int, priority: int): Treap =
  newTreap(value, priority, Treap.none, Treap.none)

proc isLeaf*(treap: Treap): bool =
  treap.left.isNone and treap.right.isNone

proc height*(treap: Treap): int =
  if treap.isLeaf:
    return 0
  else:
    return max(treap.left.map(x => x.height).get(0), treap.right.map(x =>
        x.height).get(0)) + 1

proc max*(treap: Treap): Treap =
  result = treap
  while result.right.isSome:
    result = result.right.get

proc min*(treap: Treap): Treap =
  result = treap
  while result.left.isSome:
    result = result.left.get

proc splitInternal(treap: Option[Treap], value: int, left, right: var Option[Treap]) =
  if treap.isNone:
    left = Treap.none
    right = Treap.none
    return

  let treap = treap.get
  if value <= treap.value:
    splitInternal(treap.left, value, left, treap.left)
    right = treap.some
  else:
    splitInternal(treap.right, value, treap.right, right)
    left = treap.some

proc split*(treap: Treap, value: int): (Option[Treap], Option[Treap]) =
  ## Treapをvalue未満とvalue以上に分割します。
  var
    left, right: Option[Treap]
  splitInternal(treap.some, value, left, right)
  return (left, right)

proc insertInternal(treap: var Option[Treap], child: Treap) =
  if treap.isNone:
    treap = child.some
  elif child.priority > treap.get.priority:
    splitInternal(treap, child.value, child.left, child.right)
    treap = child.some
  elif child.value < treap.get.value:
    insertInternal(treap.get.left, child)
  else:
    insertInternal(treap.get.right, child)

proc insert*(treap: var Treap, child: Treap) =
  var treapOption = treap.some
  insertInternal(treapOption, child)
  treap = treapOption.get

proc insert*(treap: var Treap, value, priority: int) =
  insert(treap, newTreap(value, priority))

proc mergeInternal(treap: var Option[Treap], left, right: Option[Treap]) =
  if left.isNone:
    treap = right
  elif right.isNone:
    treap = left
  elif left.get.priority > right.get.priority:
    mergeInternal(left.get.right, left.get.right, right)
    treap = left
  else:
    mergeInternal(right.get.left, left, right.get.left)
    treap = right

proc merge*(left, right: Treap): Treap =
  var treapOption: Option[Treap]
  mergeInternal(treapOption, left.some, right.some)
  return treapOption.get

proc removeInternal(treap: var Option[Treap], value: int) =
  if treap.isNone:
    return

  if treap.get.value == value:
    mergeInternal(treap, treap.get.left, treap.get.right)
  elif value < treap.get.value:
    removeInternal(treap.get.left, value)
  else:
    removeInternal(treap.get.right, value)

proc remove*(treap: var Treap, value: int) =
  var treapOption = treap.some
  removeInternal(treapOption, value)
  treap = treapOption.get

proc remove*(treap: var Treap, child: Treap) =
  remove(treap, child.value)

proc findByValue*(treap: Treap, value: int): Option[Treap] =
  ## 木から二分探索をします。
  if treap.value == value:
    return treap.some

  let child =
    if value < treap.value:
      treap.left
    else:
      treap.right

  return child.flatMap((x: Treap) => findByValue(x, value))

proc flatInternal(treap: Treap, order: WalkOrder): seq[Treap] =
  case order:
  of Pre:
    result.add treap
    if treap.left.isSome:
      result.add flatInternal(treap.left.get, order)
    if treap.right.isSome:
      result.add flatInternal(treap.right.get, order)

  of Post:
    if treap.left.isSome:
      result.add flatInternal(treap.left.get, order)
    if treap.right.isSome:
      result.add flatInternal(treap.right.get, order)
    result.add treap

  of In:
    if treap.left.isSome:
      result.add flatInternal(treap.left.get, order)

    result.add treap

    if treap.right.isSome:
      result.add flatInternal(treap.right.get, order)

  of Level:
    var queue = @[treap]
    while queue.len > 0:
      let cur = queue.pop()
      result.add cur
      if cur.left.isSome:
        queue.insert(cur.left.get, 0)
      if cur.right.isSome:
        queue.insert(cur.right.get, 0)

proc flat*(treap: Treap, order: WalkOrder = Pre): seq[Treap] =
  ## treapにつながっている全ノードを指定された順で返します。
  flatInternal(treap, order)

proc `$`*(treap: Treap): string =
  &"Treap@value={treap.value},priority={treap.priority},left={treap.left},right={treap.right}"
