/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */
package markdown.plugin

public class LatexMathBlock <: CustomBlock {
    private var _latex: String = ""
    public mut prop latex: String {
        get() {
            _latex
        }
        set(v) {
            _latex = v
        }
    }
    public var isClosed = false
    public var isBroken = false
    protected func toStringAttributes(): String {
        return "latex=${latex},isClosed=${isClosed},isBroken=${isBroken}"
    }
    public func getNodeType(): String {
        "LatexMathBlock"
    }
}

public class LatexMathNode <: CustomNode {
    public LatexMathNode(public var latex: String) {}
    protected func toStringAttributes(): String {
        return "latex=${latex}"
    }
    public func getNodeType(): String {
        "LatexMathNode"
    }
}

public class LatexMathPlugin <: AbstractMarkdownPlugin {
    public static func create(): LatexMathPlugin {
        return LatexMathPlugin()
    }

    public func configureParser(builder: ParserBuilder): Unit {
        builder.customBlockParserFactory(LatexBlockParserFactory())
        builder.customDelimiterProcessor(LatexInlineDelimiterProcessor())
        builder.postProcessor(LatexInlineProcessor())
        needLatexInlineParse[0] = true
    }

    public func configureVisitor(builder: MarkdownVisitorBuilder): Unit {
        addBlockVisitor(builder)
        addInlineVisitor(builder)
    }

    private func addBlockVisitor(builder: MarkdownVisitorBuilder): Unit {
        builder.on(
            "LatexMathBlock",
            {
                visitor, node => buildView(node, true)
            }
        )
    }

    private func addInlineVisitor(builder: MarkdownVisitorBuilder): Unit {
        builder.on(
            "LatexMathNode",
            {
                visitor, node => buildView(node, true)
            }
        )
    }

    // @VisibleForTesting
    static func prepareLatexTextPlaceholder(latex: String): String {
        return latex.replace("\n", " ").trimAscii()
    }

    public func getClassType(): String {
        "LatexMathPlugin"
    }
}

class LatexInlineDelimiterProcessor <: DelimiterProcessor {
    public func getOpeningCharacter(): Rune {
        return r'$'
    }
    public func getClosingCharacter(): Rune {
        return r'$'
    }
    public func getMinLength(): Int {
        return 1
    }
    public func getDelimiterUse(_: DelimiterRun, _: DelimiterRun): Int {
        return 1
    }
    let reg = Regex(#"^[\s\S]+"#)
    public func process(opener: Text, _: Text, _: Int): Unit {
        if (let Some(latexTextNode: Text) <- opener.getNext()) {
            if (reg.matches(latexTextNode.getLiteral())) {
                latexTextNode.unlink()
                opener.insertBefore(LatexMathNode(latexTextNode.getLiteral()))
            }
        }
    }
}

class LatexInlineProcessor <: PostProcessor {
    let visitor = LatexInlineVisitor()
    public func process(node: Node): Node {
        node.accept(visitor)
        node
    }
}

class LatexInlineVisitor <: AbstractVisitor {
    // let reg = Regex(#"\\\(.+?\\\)"#)
    public func visit(text: CustomNode): Unit {
        if (let Some(text) <- (text as LatexInlineText)) {
            let n = LatexMathNode(text.getLiteral())
            text.replaceWith(n)
        } else {
            visitChildren(text)
        }
    }
}
