/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2025-2025. All rights reserved.
 */
package markdown.plugin

/**
 * 使用inline
 */
public class LatexMathPluginV2 <: AbstractMarkdownPlugin {
    public static func create(): LatexMathPluginV2 {
        return LatexMathPluginV2()
    }

    public func configureParser(builder: ParserBuilder): Unit {
        builder.customBlockParserFactory(LatexBlockParserFactory()) // 块解析
        builder.customInlineContentParserFactory(LatexInlineParserFactory()) // 行内解析
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
        "LatexMathPluginV2"
    }
}

public class LatexInlineParser <: InlineContentParser {
    public func tryParse(inlineParserState: InlineParserState): ParsedInline {
        let scanner: Scanner = inlineParserState.scanner()
        let p0: SourcePosition = scanner.position()

        if (scanner.next('$')) {
            let p1 = scanner.position()
            if (scanner.find(r'$') > 0) {
                let p2 = scanner.position()
                let content = scanner.getSource(p1, p2).getContent()
                scanner.next()
                return ParsedInline.of(LatexMathNode(content), scanner.position())
            }
        }
        if (scanner.next('\\(') || scanner.next('\\[')) {
            let p1 = scanner.position()
            var p2 = scanner.position()
            while (scanner.hasNext()) {
                if (scanner.next('\\)') || scanner.next('\\]')) {
                    let content = scanner.getSource(p1, p2).getContent()
                    return ParsedInline.of(LatexMathNode(content), scanner.position())
                } else {
                    scanner.next()
                    p2 = scanner.position()
                }
            }
        }

        scanner.setPosition(p0)
        return ParsedInline.none()
    }
}

public class LatexInlineParserFactory <: InlineContentParserFactory {
    // @Override
    public func getTriggerCharacters(): HashSet<Rune> {
        return HashSet([r'$', r'\\'])
    }

    // @Override
    public func create(): InlineContentParser {
        return LatexInlineParser()
    }
}
