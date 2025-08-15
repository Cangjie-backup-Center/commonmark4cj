import { JsNode } from "@cangjie-tpc/commonmark_hybrid/src/main/ets/JsNode"
import { cjLib} from "@cangjie-tpc/commonmark_hybrid/src/main/ets/interop_api"
import { hilog } from "@kit.PerformanceAnalysisKit"
import { JsNodeSendableImpl } from "@cangjie-tpc/commonmark_hybrid"

/**
 * 解析markdown 支持JsNode复用
 * @param fullMdStr 全量markdown文本
 * @param nodepool Node缓存池
 * @returns
 * @example
 *  let nodepool = new JsNodePoolImpl(new JsNodeSendableImpl())
 *  let doc = await parseIntoJsNodeCached(str, nodepool)
 */
export async function parseIntoJsNodeCached(fullMdStr: string, nodepool: JsNodePool): Promise<JsNode> {
  let doc: JsNode = await cjLib.parseIntoJsNode(fullMdStr, () => nodepool.getJsNode()) as JsNode
  return doc
}

/**
 * node缓存池
 */
export interface JsNodePool {
  getJsNode(): JsNode
}

export class JsNodePoolImpl implements JsNodePool {
  generator: Array<JsNode> = []

  constructor(nodeTree: JsNode) {
    traverseTree(nodeTree, this.generator)
  }
  put(nodeTree: JsNode) {
    traverseTree(nodeTree, this.generator)
  }

  /**
   * 将节点树中的Node依次取出,若无则返回新Node
   * @returns
   */
  getJsNode(): JsNode {
    return this.generator.pop() ?? new JsNodeSendableImpl()
  }
}

/**
 * 取出所有可用节点
 * @param node
 * @param arr
 */
function traverseTree(node: JsNode | undefined, arr: Array<JsNode>) {
  if (node) {
    let child = node.getFirstChild()
    let next = node.getNext()
    cleanNode(node)
    arr.push(node)
    traverseTree(child, arr)
    traverseTree(next, arr)
  }
}

/**
 * 清除node关联关系 清理node数据
 * @param n
 */
function cleanNode(n: JsNode) {
  n.unlink()
  n['parent'] = undefined
  n['firstChild'] = undefined
  n['lastChild'] = undefined
  n['prev'] = undefined
  n['next'] = undefined
  /* node attr */
  n['literal'] = undefined
  n['destination'] = undefined
  n['title'] = undefined
  n['label'] = undefined
  n['delimiter'] = undefined
  n['fenceChar'] = undefined
  n['fenceLength'] = undefined
  n['fenceIndent'] = undefined
  n['level'] = undefined
  n['bulletMarker'] = undefined
  n['startNumber'] = undefined
  n['info'] = undefined
  n['tight'] = undefined
  n['header'] = undefined
  n['alignment'] = undefined
  n['props'] = undefined
  n['isdone'] = undefined
  n['latex'] = undefined
  n['isClosed'] = undefined
  n['noteid'] = undefined
  n['blockIndex'] = undefined
  n['headIndex'] = undefined
}