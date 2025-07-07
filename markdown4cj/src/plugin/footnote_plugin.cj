/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2025-2025. All rights reserved.
 */
package markdown.plugin

public class FootnotePlugin <: AbstractMarkdownPlugin {
    public static func create(): FootnotePlugin {
        return FootnotePlugin()
    }

    public func configureParser(builder: ParserBuilder): Unit {
        builder.customBlockParserFactory(FootnoteBlockParserFactory())
        builder.postProcessor(FootnotePostProcessor())
    }

    public func configureVisitor(builder: MarkdownVisitorBuilder): Unit {
        builder.on(
            "Footnote",
            {
                visitor, node => let view = buildView(node, true)
            }
        )
    }

    public func getClassType(): String {
        "FootnotePlugin"
    }
}

public class Footnote <: CustomNode {
    Footnote(public let noteid: String) {}
    public var block: ?FootnoteBlock = None
    public func getNodeType(): String {
        "Footnote"
    }
    protected func toStringAttributes(): String {
        return "noteid=${noteid},blockIndex=${block?.blockIndex}"
    }
}

public class FootnoteBlock <: CustomBlock {
    FootnoteBlock(public let noteid: String) {}
    public var blockIndex = -1
    public func getNodeType(): String {
        "FootnoteBlock"
    }
    protected func toStringAttributes(): String {
        return "noteid=${noteid},blockIndex=${blockIndex}"
    }
}

class FootnoteBlockParser <: AbstractBlockParser {
    FootnoteBlockParser(let title: String, let line: String) {
        block = FootnoteBlock(title)
        block.appendChild(paragraph)
    }
    private let block: FootnoteBlock
    private let paragraph: Paragraph = Paragraph()

    public func getBlock(): Block {
        //        println("FootnoteBlockParser getBlock ")
        block
    }

    public func tryContinue(parserState: ParserState): ?BlockContinue {
        let line = parserState.getLine()
        //        println("FootnoteBlockParser tryContinue ${line}")
        None
    }

    public func addLine(line: String): Unit {
        //        println("FootnoteBlockParser addLine ${line}")
    }
    public func parseInlines(inlineParser: InlineParser): Unit {
        //        println("FootnoteBlockParser parseInlines ")
        inlineParser.parse(line, paragraph)
    }

    public func closeBlock(): Unit {
        //        println("FootnoteBlockParser closeBlock ")
    }
}

class FootnoteBlockParserFactory <: AbstractBlockParserFactory {
    static let FOOTNOTE_BLOCK = Regex(#"^\[\^.+?\]:"#)
    public func tryStart(state: ParserState, _: MatchedBlockParser): ?BlockStart {
        let line: String = state.getLine()
        if (let Some(pos) <- FOOTNOTE_BLOCK.matcher(line).find()?.matchPosition()) {
            return BlockStart
                .of4Cj(FootnoteBlockParser(line[2..pos.end - 2], line[pos.end..]))
                .atIndex(state.getIndex() + pos.end)
        }
        return BlockStart.none()
    }
}

class FootnotePostProcessor <: PostProcessor {
    public func process(node: Node): Node {
        node.accept(FootnoteVisitor())
        return node
    }
}

/* 生成Footnode 关联FootnodeBlock FootnodeBlock生成定位序号 */
class FootnoteVisitor <: AbstractVisitor {
    let notes = ArrayList<Footnote>()
    let blockMap = HashMap<String, FootnoteBlock>()
    static let FOOTNOTE = Regex(#"\[\^.+?\]"#)
    public func visit(n: Document): Unit {
        visitChildren(n)
        for (footnote in notes) {
            let block = blockMap.get(footnote.noteid) ?? continue
            footnote.block = block
        }
    }
    public func visit(n: CustomBlock): Unit {
        match (n) {
            case f: FootnoteBlock =>
                var preSize = 0
                var pnode: Node = f
                while (let Some(v) <- pnode.getPrevious()) {
                    preSize++
                    pnode = v
                }
                f.blockIndex = preSize
                blockMap.add(f.noteid, f)
            case _ => ()
        }
        visitChildren(n)
    }
    public func visit(n: Text): Unit {
        let line = n.getLiteral()
        var i = 0
        if (let Some(ds) <- FOOTNOTE.matcher(line).findAll()) {
            for (data in ds) {
                let pos = data.matchPosition()
                let text = Text(line[i..data.matchPosition().start])
                n.insertBefore(text)
                let footnote = Footnote(line[pos.start + 2..pos.end - 1])
                n.insertBefore(footnote)
                notes.add(footnote)
                i = pos.end
            }
            n.setLiteral(line[i..])
        }
    }
}
