/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2025-2025. All rights reserved.
 */
package commonmark_hybrid

import ohos.base.Main
import ohos.concurrency.launch
import std.collection.concurrent.ArrayBlockingQueue

class JsInlineContentParser <: InlineContentParser {
    JsInlineContentParser(let parser: JSObject, let context: JSContext) {}

    @OverflowWrapping
    public func tryParse(inlineParserState: InlineParserState): ParsedInline {
        let scanner = inlineParserState.getScanner()
        let position = scanner.position()
        let box = ArrayBlockingQueue<ParsedInline>(1)
        launch {
            let jsScanner = context.object()
            jsScanner.set<Int>('lineIndex', scanner.lineIndex, context)
            jsScanner['lines'] = JSArrayEx<String>(scanner.lines |> map {v => v.getContent()} |> collectArray)
                .toJSValue(context)
            jsScanner.set<Int>('index', scanner.index, context)

            let res = parser.callMethod('tryParse', jsScanner.toJSValue())
            let stat = if (res.isUndefined()) {
                ParsedInline.none()
            } else {
                let resObj = res.asObject()
                let jsnode = resObj.getProperty('node')
                let nodeType = jsnode.getProperty('nodeType').asString().toString()
                let props = JSHashMapEx<String, String>.fromJSValue(context, jsnode.getProperty('props')).toHashMap()
                let node = JsInlineNode(nodeType, props)
                let lineIndex = Int64(resObj.getProperty('lineIndex').asNumber().toFloat64())
                let index = Int64(resObj.getProperty('index').asNumber().toFloat64())
                let position = SourcePosition(lineIndex, index)
                ParsedInline.of(node, position)
            }
            box.add(stat)
        }
        return box.remove()
    }
}

class JsInlineContentParserFactory <: InlineContentParserFactory {
    let triggerChars: HashSet<Rune>
    let parser: JSObject
    let context: JSContext
    JsInlineContentParserFactory(parser: JSObject, context: JSContext) {
        let arr = JSArrayEx<String>.fromJSValue(context, parser.callMethod('getTriggerCharacters', [])).toArray()
        this.triggerChars = arr |> map {s => s.runes().next().getOrThrow()} |> collectHashSet
        this.parser = parser
        this.context = context
    }
    public func getTriggerCharacters(): HashSet<Rune> {
        triggerChars
    }
    public func create(): InlineContentParser {
        JsInlineContentParser(parser, context)
    }
}

class JsInlineNode <: CustomNode {
    JsInlineNode(public let nodeType: String, public let props: HashMap<String, String>) {}
    public func getNodeType(): String {
        nodeType
    }
    protected func toStringAttributes(): String {
        return props.toString()
    }
}

class JsPlugin <: AbstractMarkdownPlugin {
    JsPlugin(let jsInlineContentParserFactories: Collection<JsInlineContentParserFactory>) {}
    public func configureParser(parserBuilder: ParserBuilder): Unit {
        for (f in jsInlineContentParserFactories) {
            parserBuilder.customInlineContentParserFactory(f)
        }
    }
    public func getClassType(): String {
        'JsPlugin'
    }
}
