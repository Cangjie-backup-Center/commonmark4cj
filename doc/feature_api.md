#### markdown互操作封装

```ts
/*
 * Js Node, commonmark.Node所有子类的属性集合
 */
@Sendable
class JsNode {
  constructor() 

  /* 节点类型 */
  nodeType: string = ""
  /* to string */
  toStr: string = ""
  /* 父节点 */
  parent: JsNode | undefined
  /* 第一个子节点 */
  firstChild: JsNode | undefined
  /* 最后一个子节点 */
  lastChild: JsNode | undefined
  /* 前节点 */
  prev: JsNode | undefined
  /* 后节点 */
  next: JsNode | undefined
  /**
   * 文本
   * 适用nodeType:Text/HtmlInline/Code/HtmlBlock/IndentedCodeBlock/FencedCodeBlock
   */
  literal: string | undefined
  /**
   * 目标
   * 适用nodeType:Image/LinkReferenceDefinition/Link
   */
  destination: string | undefined
  /**
   * 标题
   * 适用nodeType:Image/LinkReferenceDefinition/Link
   */
  title: string | undefined
  /**
   * 标签
   * 适用nodeType:LinkReferenceDefinition
   */
  label: string | undefined
  /**
   * 定界符
   * 适用nodeType:StrongEmphasis/Emphasis/OrderedList
   */
  delimiter: string | undefined
  /**
   * 围栏字符
   * 适用nodeType:FencedCodeBlock
   */
  fenceChar: string | undefined
  /**
   * 围栏长度
   * 适用nodeType:FencedCodeBlock
   */
  fenceLength: number | undefined
  /**
   * 围栏缩进长度
   * 适用nodeType:FencedCodeBlock
   */
  fenceIndent: number | undefined
  /**
   * 等级
   * 适用nodeType:Heading
   */
  level: number | undefined
  /**
   * 无序列表标志
   * 适用nodeType:BulletList
   */
  bulletMarker: string | undefined
  /**
   * 有序列表开始数字
   * 适用nodeType:OrderedList
   */
  startNumber: number | undefined
  /**
   * 信息
   * 适用nodeType:FencedCodeBlock
   */
  info: string | undefined
  /**
   * 列表密集排布
   * 适用nodeType:BulletList/OrderedList
   */
  tight: boolean | undefined
  /**
   * 表格头
   * 适用nodeType:TableCell
   */
  header: boolean | undefined
  /**
   * 表格对齐
   * 适用nodeType:TableCell
   */
  alignment: string | undefined
  /**
   * 用于存放Js行内自定义解析插件所产生的数据
   */
  props: collections.Map<string, string> | undefined
  /**
   * 任务列表选中标志
   * 适用nodeType:TaskListItem
   */
  isdone: boolean | undefined
  /**
   * 数学公式
   * 适用nodeType:LatexMathBlock/LatexMathNode
   */
  latex: string | undefined
  /**
   * 脚注id
   * 适用nodeType:Footnote/FootnoteBlock
   */
  noteid: string | undefined
  /**
   * FootnoteBlock下标
   * 适用nodeType:Footnote/FootnoteBlock
   */
  blockIndex: number | undefined
  /**
   * toc标题链接
   * 适用nodeType:HeadLink
   */
  headIndex: number | undefined
}

/**
 * 自定义行内解析
 */
interface InlineContentParser {
  /**
   * 指示触发Parser的字符
   */
  getTriggerCharacters(): Array<string>

  /**
   * 从指定的位置尝试解析行内markdown文本
   *
   * @param scanner 行内解析器的状态
   * @return 解析结果
   */
  tryParse(scanner: Scanner): undefined | ParsedInline
}

/**
 * markdown上下文, 指示parser的游标状态
 */
class Scanner {
  lines: Array<string> // 上下文
  lineIndex: number // 行号
  index: number // utf8字节下标
}

/**
 * InlineContentParser返回的自定义Node结构
 */
interface JsInlineCustomNode {
  nodeType: string
  props: Map<string, string>
}

/**
 * InlineContentParser返回的parse状态
 */
interface ParsedInline {
  node: JsInlineCustomNode // 必须设置nodeType/props 其他属性会忽略
  lineIndex: number // 行号
  index: number // utf8字节下标
}

/**
 * 解析markdown文本
 * 返回JsNode
 */
async function parseIntoJsNode(md: string, ...customParsers: Array<InlineContentParser>): Promise<JsNode>
```