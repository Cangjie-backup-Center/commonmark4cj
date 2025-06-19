/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2025-2025. All rights reserved.
 */
package markdown.plugin

public class IncreaseParser1 {
    public IncreaseParser1(let md: Markdown) {}

    public var input: String = ""
    public var doc: Node = Document() // 最新的Document
    public var docView: NodeView = NodeView(doc) // 最新的Document NodeView

    /*
    包含最后一个\n\n的input长度
    \n\n作为绝对的block分隔符
    size之前的内容无需重复解析
    size之后的内容合并解析
     */
    var safeInputSize = -1
    var safeViewSize = -1

    /*
     * 解析当前所有数据
     * @param str 全量markdown文本
     */
    public func parse(str: String): Unit {
        this.input = str
        if (safeInputSize > 0) {
            let node = md.parse(str[safeInputSize..])
            let view = md.render(node)
            docView.children.remove(safeViewSize..docView.children.size)
            docView.children.appendAll(view.children)
        } else {
            doc = md.parse(str)
            docView = md.render(doc)
        }
        dealLast()
    }
    func dealLast(): Unit {
        var last = docView
        while (last.children.size > 0) {
            last = last.children[last.children.size - 1]
        }
        match (last.node) {
            case v: FencedCodeBlock =>
                let closed = v.getLiteral().size > 0 && input.trimAsciiRight().endsWith("```")
                if (last.props.isNone()) {
                    last.props = HashMap()
                }
                last.props?.put("closed", closed)
                if (closed && input.endsWith("\n\n")) {
                    safeInputSize = input.size
                    safeViewSize = docView.children.size
                }
            case _ =>
                if (input.endsWith("\n\n")) {
                    safeInputSize = input.size
                    safeViewSize = docView.children.size
                }
        }
    }
}

/*
 * 打断NodeView上下级关系
 * 打断Node上下前后关系
 * 清空NodeView
 */
public func releaseNodeRelation(view: NodeView): Unit {
    for (v in view.children) {
        releaseNodeRelation(v)
    }
    view.children.clear()
    view.node.unlink()

    // 清空NodeView
    view.clear()
}
