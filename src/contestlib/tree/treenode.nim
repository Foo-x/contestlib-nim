import sequtils, options, strformat

type
  TreeNode* = ref object
    id*: Natural
    parent*: Option[TreeNode]
    children*: seq[TreeNode]

proc newNode*(id: Natural, parent: Option[TreeNode], children: openArray[TreeNode]): TreeNode =
  TreeNode(id: id, parent: parent, children: children.toSeq)

proc newNode*(id: Natural, parent: TreeNode, children: openArray[TreeNode]): TreeNode =
  newNode(id, parent.some, children)

proc newNode*(id: Natural, children: openArray[TreeNode]): TreeNode =
  newNode(id, TreeNode.none, children)

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

proc depth*(node: TreeNode): int =
  var parent = node.parent
  if parent.isSome:
    result = parent.get.depth + 1
  else:
    result = 0

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

proc `$`*(node: TreeNode): string =
  &"TreeNode@id={node.id},children={node.children}"
