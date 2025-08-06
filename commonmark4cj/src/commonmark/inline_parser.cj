/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2025. All rights reserved.
 */

package commonmark4cj.commonmark

/**
 * Parser for inline content (text, links, emphasized text, etc).
 */
public interface InlineParser {

    /**
     * @param input the content to parse as inline
     * @param node the node to append resulting nodes to (as children)
     */
    func parse(input: String, node: Node): Unit
}

/**
 * Context for inline parsing.
 */
public interface InlineParserContext {

    /**
     * @return custom delimiter processors that have been configured with {@link Parser.Builder#customDelimiterProcessor(DelimiterProcessor)}
     */
    func getCustomDelimiterProcessors(): ArrayList<DelimiterProcessor>

    /**
     * Look up a {@link LinkReferenceDefinition} for a given label.
     *
     * @param label the link label to look up
     * @return the definition if one exists, {@code null} otherwise
     */
    func getLinkReferenceDefinition(label: String): ?LinkReferenceDefinition

    /**
     * @return custom inline content parsers that have been configured with
     * {@link Parser.Builder#customInlineContentParserFactory(InlineContentParserFactory)}
     */
    func getCustomInlineContentParserFactories(): ArrayList<InlineContentParserFactory>

    /**
     * @return custom link processors that have been configured with {@link Parser.Builder#linkProcessor}.
     */
    func getCustomLinkProcessors(): ArrayList<LinkProcessor>

    /**
     * @return custom link markers that have been configured with {@link Parser.Builder#linkMarker}.
     */
    func getCustomLinkMarkers(): HashSet<Rune>
}

public interface InlineParserFactory {
    func create(inlineParserContext: InlineParserContext): InlineParser
}

class InlineParserContextImpl <: InlineParserContext {
    private var delimiterProcessors: ArrayList<DelimiterProcessor>
    var linkReferenceDefinitions: HashMap<String, LinkReferenceDefinition>
    private let inlineContentParserFactories: ArrayList<InlineContentParserFactory>
    private let linkProcessors: ArrayList<LinkProcessor>
    private let linkMarkers: HashSet<Rune>

    public init(
        inlineContentParserFactories: ArrayList<InlineContentParserFactory>,
        delimiterProcessors: ArrayList<DelimiterProcessor>,
        linkReferenceDefinitions: HashMap<String, LinkReferenceDefinition>,
        linkProcessors: ArrayList<LinkProcessor>,
        linkMarkers: HashSet<Rune>
    ) {
        this.inlineContentParserFactories = inlineContentParserFactories
        this.delimiterProcessors = delimiterProcessors
        this.linkReferenceDefinitions = linkReferenceDefinitions
        this.linkProcessors = linkProcessors
        this.linkMarkers = linkMarkers
    }

    public override func getCustomDelimiterProcessors(): ArrayList<DelimiterProcessor> {
        return delimiterProcessors
    }

    public override func getLinkReferenceDefinition(label: String): ?LinkReferenceDefinition {
        return linkReferenceDefinitions.get(Escaping.normalizeLabelContent(label))
    }

    public func getCustomInlineContentParserFactories(): ArrayList<InlineContentParserFactory> {
        return inlineContentParserFactories
    }

    public func getCustomLinkProcessors(): ArrayList<LinkProcessor> {
        return linkProcessors
    }

    public func getCustomLinkMarkers(): HashSet<Rune> {
        return linkMarkers
    }

    var ctxCalc: ?InlineParserContextCalc = None
    func calc(): Unit {
        if (ctxCalc.isNone()) {
            ctxCalc = InlineParserContextCalc(this)
        }
    }
}

class DelimiterData {
    let count: Int64
    let canClose: Bool
    let canOpen: Bool

    init(count: Int64, canOpen: Bool, canClose: Bool) {
        this.count = count
        this.canOpen = canOpen
        this.canClose = canClose
    }
}
