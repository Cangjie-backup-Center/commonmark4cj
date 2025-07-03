/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2025-2025. All rights reserved.
 */
package markdown_hybrid

import ohos.ark_interop_macro.*
import encoding.json.JsonString
import encoding.json.JsonInt
import encoding.json.JsonBool
import encoding.json.JsonObject
import encoding.json.JsonValue
import std.time.DateTime
import encoding.json.JsonArray

extend JsonObject {
    func set<T>(name: String, value: Option<T>): Unit {
        match (value) {
            case Some(v: String) => this.put(name, JsonString(v))
            case Some(v: Rune) => this.put(name, JsonString(v.toString()))
            case Some(v: Int64) => this.put(name, JsonInt(v))
            case Some(v: Bool) => this.put(name, JsonBool(v))
            case Some(v: JsonValue) => this.put(name, v)
            case _ => () //this.put(name, context.undefined().toJSValue())
        }
    }
    func appendChild(newChild: JsonObject): Unit {
        if (let Some(children: JsonArray) <- this.get("children")) {
            children.add(newChild)
        } else {
            let children = JsonArray()
            children.add(newChild)
            this.put("children", children)
        }
    }
}

class JsonNodeBuilder {
    func buildJsNode(instance: MdNode): JsonObject {
        let jsNode = JsonObject()
        jsNode.set('nodeType', instance.getNodeType())
        jsNode.set('toStr', instance.toString())
        match (instance) {
            case v: JsInlineNode =>
                let props = JsonObject()
                for ((k, v) in v.props) {
                    props.put(k, JsonString(v))
                }
                jsNode.set('props', props)
            case v: TaskListItem => jsNode.set('isdone', v.isDone())
            case v: LatexMathBlock => jsNode.set('latex', v.latex)
            case v: LatexMathNode => jsNode.set('latex', v.latex)
            case v: Footnote =>
                jsNode.set('noteid', v.noteid)
                jsNode.set('blockIndex', v.block?.blockIndex ?? -1)
            case v: FootnoteBlock =>
                jsNode.set('noteid', v.noteid)
                jsNode.set('blockIndex', v.blockIndex)
            case v: HeadLink => jsNode.set('headIndex', v.headIndex)
            case v: MdText => jsNode.set('literal', v.getLiteral())
            case v: MdHtmlInline => jsNode.set('literal', v.getLiteral())
            case v: MdImage =>
                jsNode.set('destination', v.getDestination())
                jsNode.set('title', v.getTitle())
            case v: MdCode => jsNode.set('literal', v.getLiteral())
            case v: MdLinkReferenceDefinition =>
                jsNode.set('label', v.getLabel())
                jsNode.set('destination', v.getDestination())
                jsNode.set('title', v.getTitle())
            case v: MdLink =>
                jsNode.set('destination', v.getDestination())
                jsNode.set('title', v.getTitle())
            case v: MdStrongEmphasis => jsNode.set('delimiter', v.getOpeningDelimiter())
            case v: MdEmphasis => jsNode.set('delimiter', v.getOpeningDelimiter())
            case v: MdHtmlBlock => jsNode.set('literal', v.getLiteral())
            case v: MdIndentedCodeBlock => jsNode.set('literal', v.getLiteral())
            case v: MdFencedCodeBlock =>
                jsNode.set('fenceChar', v.getFenceChar())
                jsNode.set('fenceLength', v.getFenceLength())
                jsNode.set('fenceIndent', v.getFenceIndent())
                jsNode.set('info', v.getInfo())
                jsNode.set('literal', v.getLiteral())
            case v: MdHeading => jsNode.set('level', v.getLevel())
            case v: MdBulletList =>
                jsNode.set('tight', v.isTight())
                jsNode.set('bulletMarker', v.getBulletMarker())
            case v: MdOrderedList =>
                jsNode.set('tight', v.isTight())
                jsNode.set('startNumber', v.getStartNumber())
                jsNode.set('delimiter', v.getDelimiter())
            case v: TableCell =>
                jsNode.set('header', v.isHeader())
                jsNode.set('alignment', v.getAlignment()?.toString())
            case _ => ()
        }
        jsNode
    }

    func buildNode(n: MdNode): JsonObject {
        let nodeProxy = buildJsNode(n)
        visitNode(n.getFirstChild(), nodeProxy)
        nodeProxy
    }

    func visitNode(node: ?MdNode, parentProxy: JsonObject): Unit {
        let current = node ?? return
        let next = current.getNext()
        let currentProxy = buildJsNode(current)
        parentProxy.appendChild(currentProxy)
        visitNode(current.getFirstChild(), currentProxy)
        visitNode(next, parentProxy)
    }
}

public func parse2Json(context: JSContext, callInfo: JSCallInfo): JSValue {
    //    let t0 = DateTime.now()
    let md = callInfo[0].toString(context)
    let jsNodeConstructor = callInfo[1].asClass()
    let markdownBuilder: MarkdownBuilder = Markdown
        .builder()
        // 任务列表插件
        .usePlugin(TaskListPlugin.create())
        // 删除线插件
        .usePlugin(StrikethroughPlugin.create())
        // 表格插件
        .usePlugin(TablePlugin.create())
        // 数学公式
        .usePlugin(LatexMathPluginV2.create())
        // 脚注
        .usePlugin(FootnotePlugin.create())
        // 自动网址链接
        .usePlugin(LinkifyPlugin.create())
        // TOC列表插件
        .usePlugin(TocPlugin.create())
    if (callInfo.count == 3) {
        let arr = callInfo[2].asArray()
        if (arr.size > 0) {
            let factories = Array<JsInlineContentParserFactory>(
                arr.size,
                {
                    i =>
                    let parser = arr[i].asObject()
                    JsInlineContentParserFactory(parser, context)
                }
            )
            markdownBuilder.usePlugin(JsPlugin(factories))
        }
    }
    let parser = markdownBuilder.build()

    //    let t1 = DateTime.now()
    let doc: MdNode = parser.parse(md)

    //    let t2 = DateTime.now()
    let builder = JsonNodeBuilder()
    let jo = builder.buildNode(doc)
    let jsonString = jo.toJsonString()
    let RET = context.string(jsonString).toJSValue(context)

    //    let t3 = DateTime.now()
    //    Hilog.error(0, 'mdebug', "pre:${t1-t0}, parse:${t2-t1}, build:${t3-t2}")
    return RET
}
