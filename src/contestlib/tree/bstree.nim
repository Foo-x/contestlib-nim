## 二分探索木
## 右同値

import options, sugar, strformat, deques

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

proc replaceWithChild(parentTree: BSTree, childTree: Option[BSTree]) =
  ## 1つ以下の子を持つparentTreeをその子で置き換えます。
  ## parentTreeが根でchildTreeがnoneの場合は何もしません。
  if parentTree.left.isSome and parentTree.right.isSome:
    return
  if parentTree.left != childTree and parentTree.right != childTree:
    return
  if parentTree.root == parentTree and childTree.isNone:
    return

  if parentTree.root == parentTree:
    parentTree.value = childTree.get.value

    parentTree.left = childTree.get.left
    if parentTree.left.isSome:
      parentTree.left.get.parent = parentTree.some

    parentTree.right = childTree.get.right
    if parentTree.right.isSome:
      parentTree.right.get.parent = parentTree.some
    return

  let gparent = parentTree.parent

  if childTree.isSome:
    childTree.get.parent = gparent

  if gparent.get.left == parentTree.some:
    gparent.get.left = childTree
  else:
    gparent.get.right = childTree

proc replaceWithLeft(tree: BSTree) =
  ## 自身を左の子で置き換えます。
  ## 自身が根で左の子が存在しない場合は何もしません。
  replaceWithChild(tree, tree.left)

proc replaceWithRight(tree: BSTree) =
  ## 自身を右の子で置き換えます。
  ## 自身が根で右の子が存在しない場合は何もしません。
  replaceWithChild(tree, tree.right)

proc remove*(tree: BSTree, value: int) =
  ## ノードを削除します。
  ## 対象のノードが複数ある場合は最も浅いものを削除します。
  ## 木が1ノードからなる場合はそのまま返します。
  let
    root = tree.root
    target = root.findByValue(value)
  if target.isNone:
    return

  let targetContent = target.get
  if targetContent.left.isNone:
    targetContent.replaceWithRight
  elif targetContent.right.isNone:
    targetContent.replaceWithLeft
  else:
    let newTree = targetContent.right.get.min
    targetContent.value = newTree.value
    newTree.replaceWithRight

proc remove*(tree: BSTree, child: BSTree) =
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
    var queue = initDeque[BSTree]()
    queue.addLast(tree)
    while queue.len > 0:
      let cur = queue.popFirst()
      result.add cur
      if cur.left.isSome:
        queue.addLast(cur.left.get)
      if cur.right.isSome:
        queue.addLast(cur.right.get)

proc flat*(tree: BSTree, order: WalkOrder = Pre): seq[BSTree] =
  ## treeにつながっている全ノードを指定された順で返します。
  flatInternal(tree.root, order)

proc `$`*(tree: BSTree): string =
  &"BSTree@value={tree.value},left={tree.left},right={tree.right}"
