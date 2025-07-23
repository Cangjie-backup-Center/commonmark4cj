/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2025-2025. All rights reserved.
 */
import { parseIntoJsNode, printNode, JsNode } from '@cangjie-tpc/markdown_hybrid';
import { hilog } from '@kit.PerformanceAnalysisKit';

export async function sample_label(): Promise<string> {
  let md = 'this is a <label> 这段应该有一个背景色 ,**加粗** </label>, other words'
  let node = await parseIntoJsNode(md)
  visit(node)
  let nodeTreeStr = printNode(node)
  hilog.error(0, '', nodeTreeStr)
  return nodeTreeStr
}

function visit(node: JsNode | undefined): void {
  if (!node) {
    return
  }

  // 处理Paragraph中的行内元素
  if (node.getNodeType() == 'Paragraph') {
    dealLabel(node)
    return
  }

  // 遍历树
  visit(node?.getFirstChild())
  visit(node?.getNext())
}

function dealLabel(node: JsNode) {
  let child = node.getFirstChild()
  let lableNode: JsNode | undefined = undefined
  while (child) {
    if (child.getNodeType() == 'HtmlInline' && child.getLiteral() == '<label>') {
      // lable开始
      lableNode = new JsNode()
      lableNode.nodeType = 'LableNode'
      lableNode.toStr = 'LableNode'
      // 先处理循环
      let tmp = child
      child = child.getNext()
      // 再处理结构
      tmp.insertBefore(lableNode)
      tmp.unlink()
    } else if (lableNode) {
      // lable中
      // 先处理循环
      let tmp = child
      child = child.getNext()
      // 再处理结构
      tmp.unlink()
      lableNode.appendChild(tmp)
    } else if (child.getNodeType() == 'HtmlInline' && child.getLiteral() == '</label>') {
      // lable结束
      // 先处理循环
      let tmp = child
      child = child.getNext()
      // 再处理结构
      tmp.unlink()
      lableNode = undefined
    } else {
      child = child.getNext()
    }
  }
}
