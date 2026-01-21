import { JsNode, opt } from "./md"
import { cjLib} from "./md"
import { hilog } from "@kit.PerformanceAnalysisKit"
import { JsNodeSendableImpl } from "./md"
import { JsNodeImpl } from "@cangjie-tpc/commonmark_hybrid"

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
  let doc: JsNode = await cjLib.parseIntoJsNode(fullMdStr, opt(() => nodepool.getJsNode(), 0)) as JsNode
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
    node.reset()
    arr.push(node)
    traverseTree(child, arr)
    traverseTree(next, arr)
  }
}
