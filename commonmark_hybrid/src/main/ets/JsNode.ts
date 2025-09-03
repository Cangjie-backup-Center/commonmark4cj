/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2025-2025. All rights reserved.
 */
import { SourceType } from "@kit.InputKit"

export interface JsNode {
  /* 节点类型 */
  getNodeType(): string

  /* to string */
  toString(): string

  setParent(parent: JsNode | undefined): void

  setPrevious(prev: JsNode | undefined): void

  setNext(next: JsNode | undefined): void

  setFirstChild(firstChild: JsNode | undefined): void

  setLastChild(lastChild: JsNode | undefined): void

  appendChild(child: JsNode): void

  prependChild(child: JsNode): void

  unlink(): void

  insertAfter(sibling: JsNode): void

  insertBefore(sibling: JsNode): void

  /* 父节点 */
  getParent(): JsNode | undefined

  /* 第一个子节点 */
  getFirstChild(): JsNode | undefined

  /* 最后一个子节点 */
  getLastChild(): JsNode | undefined

  /* 前节点 */
  getPrevious(): JsNode | undefined

  /* 后节点 */
  getNext(): JsNode | undefined

  /**
   * 文本
   * 适用nodeType:Text/HtmlInline/Code/HtmlBlock/IndentedCodeBlock/FencedCodeBlock
   */
  getLiteral(): string | undefined

  /**
   * 目标
   * 适用nodeType:Image/LinkReferenceDefinition/Link
   */
  getDestination(): string | undefined

  /**
   * 标题
   * 适用nodeType:Image/LinkReferenceDefinition/Link
   */
  getTitle(): string | undefined

  /**
   * 标签
   * 适用nodeType:LinkReferenceDefinition
   */
  getLabel(): string | undefined

  /**
   * 定界符
   * 适用nodeType:StrongEmphasis/Emphasis/OrderedList
   */
  getDelimiter(): string | undefined

  /**
   * 开始定界符
   * 适用nodeType:Delimited子类系列
   */
  getOpeningDelimiter(): string | undefined

  /**
   * 结束定界符
   * 适用nodeType:Delimited子类系列
   */
  getClosingDelimiter(): string | undefined

  /**
   * 围栏字符
   * 适用nodeType:FencedCodeBlock
   */
  getFenceChar(): string | undefined

  /**
   * 围栏长度
   * 适用nodeType:FencedCodeBlock
   */
  getFenceLength(): number | undefined

  /**
   * 围栏缩进长度
   * 适用nodeType:FencedCodeBlock
   */
  getFenceIndent(): number | undefined

  /**
   * 等级
   * 适用nodeType:Heading
   */
  getLevel(): number | undefined

  /**
   * 无序列表标志
   * 适用nodeType:BulletList
   */
  getBulletMarker(): string | undefined

  /**
   * 有序列表开始数字
   * 适用nodeType:OrderedList
   */
  getStartNumber(): number | undefined

  /**
   * 信息
   * 适用nodeType:FencedCodeBlock
   */
  getInfo(): string | undefined

  /**
   * 列表密集排布
   * 适用nodeType:BulletList/OrderedList
   */
  isTight(): boolean | undefined

  /**
   * 表格头
   * 适用nodeType:TableCell
   */
  isHeader(): boolean | undefined

  /**
   * 表格对齐
   * 适用nodeType:TableCell
   */
  getAlignment(): string | undefined

  /**
   * 任务列表选中标志
   * 适用nodeType:TaskListItem
   */
  isDone(): boolean | undefined

  /**
   * 数学公式
   * 适用nodeType:LatexMathBlock/LatexMathNode
   */
  getLatex(): string | undefined

  /**
   * 脚注id
   * 适用nodeType:Footnote/FootnoteBlock
   */
  getNoteid(): string | undefined

  /**
   * FootnoteBlock下标
   * 适用nodeType:Footnote/FootnoteBlock
   */
  getBlockIndex(): number | undefined

  /**
   * toc标题链接
   * 适用nodeType:HeadLink
   */
  getHeadIndex(): number | undefined

  /**
   * 用于存放Js行内自定义解析插件所产生的数据
   */
  getProps(): Map<string, string> | undefined

  putProp(k: string, v: string): void

  /*
   * 获取SourceSpan信息
   */
  getSourceSpans(): Array<SourceSpan>

  /*
   * 添加SourceSpan信息
   */
  addSourceSpans(...numbers: Array<number>): void

  /*
   * 重置Node 以供复用
   */
  reset(): void
}

export interface SourceSpan {
  /*
   * 行号
   */
  getLineIndex(): number

  /*
   * 列号(utf8)
   */
  getColumnIndex(): number

  /*
   * 全文起始下标(utf8)
   */
  getInputIndex(): number

  /*
   * 长度
   */
  getLength(): number
}

export function printNode(node: JsNode): string {
  node = node as JsNode
  if (node) {
    let current: JsNode | undefined = node
    while (current?.getParent()) {
      current = (current as JsNode).getParent()
    }
    let builder = Array<string>()
    printNodeDep(current, 0, builder)
    return builder.join('')
  }
  return ''
}

function printNodeDep(node: JsNode | undefined, dep: number, builder: Array<string>) {
  node = node as JsNode
  if (node) {
    let str = node.toString()
    let sss = node.getSourceSpans().map((v) => JSON.stringify(v)).join(',')
    let sssize = node.getSourceSpans().length
    builder.push(`${' '.repeat(dep)}${str}${sssize}:[${sss}]\n`)
    let child = node.getFirstChild()
    printNodeDep(child, dep + 4, builder)
    let next = node.getNext()
    printNodeDep(next, dep, builder)
  }
}
