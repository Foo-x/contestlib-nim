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

proc newBSTree*(value: int, left: Option[BSTree], right: Option[
    BSTree]): BSTree =
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

proc sibling*(tree: BSTree): Option[BSTree] =
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
    return max(tree.left.map(x => x.height).get(0), tree.right.map(x =>
        x.height).get(0)) + 1

proc max*(tree: BStree): BSTree =
  result = tree
  while result.right.isSome:
    result = result.right.get

proc min*(tree: BStree): BSTree =
  result = tree
  while result.left.isSome:
    result = result.left.get

proc insert*(tree: BSTree, child: BSTree) =
  var target = tree.root
  while true:
    let isNextLeft = child.value < target.value
    if isNextLeft and target.left.isNone:
      target.left = child.some
      child.parent = target.some
      break

    if not isNextLeft and target.right.isNone:
      target.right = child.some
      child.parent = target.some
      break

    if isNextLeft:
      target = target.left.get
    else:
      target = target.right.get

proc insert*(tree: BSTree, value: int) =
  insert(tree, newBSTree(value))

proc findByValue*(tree: BSTree, value: int): Option[BSTree] =
  ## 木から二分探索をします。
  if tree.value == value:
    return tree.some

  let child =
    if value < tree.value:
      tree.left
    else:
      tree.right

  return child.flatMap((x: BSTree) => findByValue(x, value))

proc remove*(tree: var BSTree, value: int) =
  ## ノードを削除します。
  ## 対象のノードが複数ある場合は最も浅いものを削除します。
  ## 木が1ノードからなる場合はそのまま返します。
  let root = tree.root
  if root.left.isNone and root.right.isNone:
    return

  # 削除するノードが根の場合
  if value == root.value:
    if root.right.isNone:
      tree = root.left.get
      tree.parent = BSTree.none
      return

    if root.left.isNone:
      tree = root.right.get
      tree.parent = BSTree.none
      return

    tree = root.right.get.min
    if root.right.get != tree:
      tree.parent.get.left = tree.right
      tree.right = root.right
      tree.right.get.parent = tree.some
    else:
      tree.right = BSTree.none

    tree.parent = BSTree.none
    tree.left = root.left
    tree.left.get.parent = tree.some
    return

  let target = root.findByValue(value)
  if target.isNone:
    return

  let
    targetContent = target.get
  var
    newChild: Option[BSTree]

  if targetContent.left.isNone and targetContent.right.isNone:
    newChild = BSTree.none
  elif targetContent.left.isSome and targetContent.right.isNone:
    newChild = targetContent.left
  elif targetContent.left.isNone and targetContent.right.isSome:
    newChild = targetContent.right
  else:
    newChild = targetContent.right.get.min.some

    if targetContent.right != newChild:
      newChild.get.parent.get.left = newChild.get.right
      newChild.get.right = targetContent.right
      newChild.get.right.get.parent = newChild
    else:
      newChild.get.right = BSTree.none

    newChild.get.left = targetContent.left
    newChild.get.left.get.parent = newChild

  if newChild.isSome:
    newChild.get.parent = targetContent.parent

  if targetContent.parent.get.left == target:
    targetContent.parent.get.left = newChild
  else:
    targetContent.parent.get.right = newChild

proc remove*(tree: var BSTree, child: BSTree) =
  ## ノードを削除します。
  ## 対象のノードが複数ある場合は最も浅いものを削除します。
  ## 木が1ノードからなる場合はそのまま返します。
  remove(tree, child.value)

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
