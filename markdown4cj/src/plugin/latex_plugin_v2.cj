/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2025-2025. All rights reserved.
 */
package markdown.plugin

import ohos.hilog.Hilog

/**
 * 使用inline
 */
public class LatexMathPluginV2 <: AbstractMarkdownPlugin {
    public static func create(): LatexMathPluginV2 {
        return LatexMathPluginV2()
    }

    public func configureParser(builder: ParserBuilder): Unit {
        builder.customBlockParserFactory(LatexBlockParserFactory()) // 块解析: $$ \[\]
        builder.customInlineContentParserFactory(LatexInlineParserFactory()) // 行内解析:  \(\) \[\]
        builder.customDelimiterProcessor(LatexInlineDelimiterProcessor()) // 行内解析: $ $$
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
        let scanner: Scanner = inlineParserState.getScanner()
        let p0: SourcePosition = scanner.position()

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
        return HashSet([r'\\'])
    }

    // @Override
    public func create(): InlineContentParser {
        return LatexInlineParser()
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
    public override func process(openingRun: DelimiterRun, closingRun: DelimiterRun): Int {
        let opener = openingRun.getOpener()
        let closer = closingRun.getCloser()
        if (let Some(text: Text) <- opener.getNext()) {
            if (text.getNext() == closer) {
                text.replaceWith(LatexMathNode(text.getLiteral()))
                return if (openingRun.getLength() >= 2 && closingRun.getLength() >= 2) {
                    2
                } else {
                    1
                }
            }
        }
        return 0
    }
}
