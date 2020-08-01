## 二分探索木
## 右同値

import options, sugar, strformat

type
  BSTree* = ref object
    value*: int
    parent*: Option[BSTree]
    left*: Option[BSTree]
    right*: Option[BSTree]

  WalkOrder* = enum
    Pre, In, Post, Level

proc newBSTree*(value: int, left: Option[BSTree], right: Option[BSTree]): BSTree =
  BSTree(value: value, parent: BSTree.none, left: left, right: right)

proc newBSTree*(value: int): BSTree =
  newBSTree(value, BSTree.none, BSTree.none)

proc isRoot*(tree: BSTree): bool =
  tree.parent.isNone

proc isLeaf*(tree: BSTree): bool =
  tree.left.isNone and tree.right.isNone

proc isInternal*(tree: BSTree): bool =
  not (tree.isRoot or tree.isLeaf)

proc root*(tree: BSTree): BSTree =
  result = tree
  while not result.isRoot:
    result = result.parent.get

proc sibling*(tree: BSTree):Option[BSTree] =
  if tree.isRoot:
    return BSTree.none

  let parent = tree.parent.get
  if tree.some == parent.left:
    return parent.right
  else:
    return parent.left

proc depth*(tree: BSTree): int =
  if tree.isRoot:
    result = 0
  else:
    result = tree.parent.get.depth + 1

proc height*(tree: BSTree): int =
  if tree.isLeaf:
    return 0
  else:
    return max(tree.left.map(x => x.depth).get(0), tree.right.map(x => x.depth).get(0)) + 1

proc insert*(tree: BSTree, child: BSTree) =
  var target = tree.root
  while true:
    let isNextLeft = child.value < target.value
    if isNextLeft and target.left.isNone:
      target.left = child.some
      break

    if not isNextLeft and target.right.isNone:
      target.right = child.some
      break

    if isNextLeft:
      target = target.left.get
    else:
      target = target.right.get

proc insert*(tree: BSTree, value: int) =
  insert(tree, newBSTree(value))

proc flatInternal(tree: BSTree, order: WalkOrder): seq[BSTree] =
  case order:
  of Pre:
    result.add tree
    if tree.left.isSome:
      result.add flatInternal(tree.left.get, order)
    if tree.right.isSome:
      result.add flatInternal(tree.right.get, order)

  of Post:
    if tree.left.isSome:
      result.add flatInternal(tree.left.get, order)
    if tree.right.isSome:
      result.add flatInternal(tree.right.get, order)
    result.add tree

  of In:
    if tree.left.isSome:
      result.add flatInternal(tree.left.get, order)

    result.add tree

    if tree.right.isSome:
      result.add flatInternal(tree.right.get, order)

  of Level:
    var queue = @[tree]
    while queue.len > 0:
      let cur = queue.pop()
      result.add cur
      if cur.left.isSome:
        queue.insert(cur.left.get, 0)
      if cur.right.isSome:
        queue.insert(cur.right.get, 0)

proc flat*(tree: BSTree, order: WalkOrder = Pre): seq[BSTree] =
  ## treeにつながっている全ノードを指定された順で返します。
  flatInternal(tree.root, order)

proc `$`*(tree: BSTree): string =
  &"BSTree@value={tree.value},left={tree.left},right={tree.right}"
