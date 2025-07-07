/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2025-2025. All rights reserved.
 */
package markdown.plugin

public class IncreaseParser {
    public IncreaseParser(let md: Markdown) {}

    public var input: String = ""
    public var doc: Node = Document() // 最新的Document
    public var docView: NodeView = NodeView(doc) // 最新的Document NodeView

    /* 是否延迟解析 */
    public var lazy = true
    /* 缓冲区 不满一行的数据存在这里 满一行则触发解析 并清空缓冲区 */
    public var incBuffer = StringBuilder()
    /* 是否有新block需要渲染 需配合lazy使用*/
    public prop hasNew: Bool {
        get() {
            incBuffer.size == 0 // 缓冲区清空 说明block有更新
        }
    }
    var inc: String = ""

    /**
     * 增量解析markdown
     * 当前增量文本具有一些特点:
     * 1. 多字符语法分隔符 不会截断
     * 1. 软换行\n总在末尾
     * 1. 段落分隔符\n\n总在末尾
     * 粘连场景:
     * 1. 行内 通过lazy机制 incBuffer积攒出一行 再执行增量解析
     * 1. 跨行 当前列表涉及层级不好解决
     * 常用语法:
     * 1. 加粗
     * 1. 文本
     * 1. 标题
     * 1. 高亮代码块
     * 1. 缩进代码块
     * 1. 有序列表
     * 1. 无序列表
     * 1. 表格
     * @param input 增量文本
     */
    public func append(inc_str: String): Unit {
        inc = inc_str

        if (lazy) {
            incBuffer.append(inc)
            if (inc.endsWith("\n")) {
                inc = incBuffer.toString()
                incBuffer.reset()
            } else {
                return
            }
        }

        this.input += inc
        parse()
    }
    /* 解析当前所有数据 */
    public func parse(): Unit {
        doc = md.parse(input)
//        releaseNodeRelation(docView)
        docView = md.render(doc)
        dealLast()
    }
    func dealLast(): Unit {
        var last = docView
        while (last.children.size > 0) {
            last = last.children[last.children.size - 1]
        }
        match (last.node) {
            case v: FencedCodeBlock =>
                let closed = v.getLiteral().size > 0 && input.trimAsciiEnd().endsWith("```")
                if(last.props.isNone()) {
                    last.props = HashMap()
                }
                last.props?.add("closed", closed)
            case _ => ()
        }
    }
}
