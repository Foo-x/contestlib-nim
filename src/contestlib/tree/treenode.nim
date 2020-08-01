import sequtils, options, strformat, algorithm, sugar

type
  TreeNode* = ref object
    id*: Natural
    parent*: Option[TreeNode]
    children*: seq[TreeNode]

  WalkOrder* = enum
    Pre, In, Post, Level, Id

proc newNode*(id: Natural, children: openArray[TreeNode]): TreeNode =
  TreeNode(id: id, parent: TreeNode.none, children: children.toSeq)

proc newNode*(id: Natural): TreeNode =
  newNode(id, @[])

proc addChild*(node: TreeNode, child: TreeNode) =
  child.parent = node.some
  node.children.add(child)

proc fromChildrenMatrix*(childrenMatrix: openArray[seq[int]]): TreeNode =
  ## node-childrenリストから木を作成して、根の`TreeNode`を返します。
  var nodes = (0..<childrenMatrix.len).mapIt(newNode(it, @[]))
  for i in 0..<childrenMatrix.len:
    for childIndex in childrenMatrix[i]:
      nodes[i].addChild(nodes[childIndex])

  nodes.filterIt(it.parent.isNone)[0]

proc fromParentList*(parentList: openArray[int]): TreeNode =
  ## parentリストから木を作成して、根の`TreeNode`を返します。
  ## 親が存在しないノードのparentは-1である前提です。
  var nodes = (0..<parentList.len).mapIt(newNode(it, @[]))
  for i in 0..<parentList.len:
    if parentList[i] == -1:
      continue
    nodes[parentList[i]].addChild(nodes[i])

  nodes.filterIt(it.parent.isNone)[0]

proc isRoot*(node: TreeNode): bool =
  node.parent.isNone

proc isLeaf*(node: TreeNode): bool =
  node.children.len == 0

proc isInternal*(node: TreeNode): bool =
  not (node.isRoot or node.isLeaf)

proc root*(node: TreeNode): TreeNode =
  result = node
  while not result.isRoot:
    result = result.parent.get

proc siblings*(node: TreeNode): seq[TreeNode] =
  if node.isRoot:
    return @[]

  result = node.parent.get.children.filterIt(it != node)

proc depth*(node: TreeNode): int =
  if node.isRoot:
    result = 0
  else:
    result = node.parent.get.depth + 1

proc height*(node: TreeNode): int =
  if node.isLeaf:
    return 0
  else:
    return max(node.children.mapIt(it.height)) + 1

proc removeChild*(node: TreeNode, child: TreeNode) =
  let index = node.children.find(child)
  if index != -1:
    node.children.delete(index)

proc findById*(node: TreeNode, id: Natural): Option[TreeNode] =
  ## 子孫からidでDFS（深さ優先探索）します。
  for child in node.children:
    if child.id == id:
      return child.some

    let resultOption = findById(child, id)
    if resultOption.isSome:
      return resultOption

  return TreeNode.none

proc isBinaryTree*(node: TreeNode): bool =
  var stack = @[node.root]
  while stack.len != 0:
    var cur = stack.pop()
    if cur.children.len > 2:
      return false

    if cur.children.len != 0:
      stack.add cur.children

  return true

proc flatInternal(node: TreeNode, order: WalkOrder): seq[TreeNode] =
  case order:
  of Pre:
    result.add node
    result.add node.children.mapIt(flatInternal(it, order)).concat

  of Post:
    result.add node.children.mapIt(flatInternal(it, order)).concat
    result.add node

  of In:
    if not node.isBinaryTree:
      return

    if node.children.len > 0:
      result.add flatInternal(node.children[0], order)

    result.add node

    if node.children.len > 1:
      result.add flatInternal(node.children[1], order)

  of Level:
    var queue = @[node]
    while queue.len > 0:
      let cur = queue.pop()
      result.add cur
      queue.insert(cur.children.reversed, 0)

  of Id:
    result = flatInternal(node, Pre).sorted((x, y) => x.id > y.id)

proc flat*(node: TreeNode, order: WalkOrder = Pre): seq[TreeNode] =
  ## nodeにつながっている全ノードを指定された順で返します。
  ## 二分木以外に対して中間順（通りがけ順）を指定した場合は空リストを返します。
  flatInternal(node.root, order)

proc `$`*(node: TreeNode): string =
  &"TreeNode@id={node.id},children={node.children}"
