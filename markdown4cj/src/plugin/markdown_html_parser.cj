/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2025. All rights reserved.
 */
package markdown.plugin

public interface FlushAction<T> {
    func apply(tags: Collection<T>): Unit
}

public type Appendable = StringBuilder

/**
 */
public abstract class MarkdownHtmlParser {
    /* T extends Appendable & CharSequence */
    public func processFragment(output: Appendable, htmlFragment: String, parent: HtmlTag): Unit

    /**
     * After this method exists a {@link MarkdownHtmlParser} will clear internal state for stored tags.
     * If you wish to process them further after this method exists create own copy of supplied
     * collection.
     *
     * @param documentLength known document length. This value is used to close all non-closed tags.
     *                       If you wish to keep them open (do not force close at the end of a
     *                       document pass here {@link HtmlTag#NO_END}. Later non-closed tags
     *                       can be detected by calling {@link HtmlTag#isClosed()}
     * @param action         {@link FlushAction} to be called with resulting tags ({@link InlineHtmlTag})
     */
    //    public func flushInlineTags(documentLength: Int, action: FlushAction<InlineHtmlTag>): Unit

    /**
     * After this method exists a {@link MarkdownHtmlParser} will clear internal state for stored tags.
     * If you wish to process them further after this method exists create own copy of supplied
     * collection.
     *
     * @param documentLength known document length. This value is used to close all non-closed tags.
     *                       If you wish to keep them open (do not force close at the end of a
     *                       document pass here {@link HtmlTag#NO_END}. Later non-closed tags
     *                       can be detected by calling {@link HtmlTag#isClosed()}
     * @param action         {@link FlushAction} to be called with resulting tags ({@link BlockHtmlTag})
     */
    //    public func flushBlockTags(
    //        documentLength: Int,
    //        action: FlushAction<BlockHtmlTag>
    //    ): Unit

    public func reset(): Unit
}

/**
 */
public class MarkdownHtmlParserImpl <: MarkdownHtmlParser {
    public static func create(): MarkdownHtmlParserImpl {
        return create(HtmlEmptyTagReplacement.create())
    }

    public static func create(inlineTagReplacement: HtmlEmptyTagReplacement): MarkdownHtmlParserImpl {
        return MarkdownHtmlParserImpl(inlineTagReplacement, TrimmingAppender.create())
    }

    private static let INLINE_TAGS: Set<String>

    private static let VOID_TAGS: Set<String>

    private static let BLOCK_TAGS: Set<String>

    private static let TAG_PARAGRAPH = "p"

    private static let TAG_LIST_ITEM = "li"

    static init() {
        INLINE_TAGS = HashSet<String>(
            ["a", "abbr", "acronym", "b", "bdo", "big", "br", "button", "cite", "code", "dfn", "em", "i", "img", "input",
                "kbd", "label", "map", "object", "q", "samp", "script", "select", "small", "span", "strong", "sub",
                "sup", "textarea", "time", "tt", "var", "font"])
        VOID_TAGS = HashSet<String>(
            ["area", "base", "br", "col", "embed", "hr", "img", "input", "keygen", "link", "meta", "param", "source",
                "track", "wbr"])
        BLOCK_TAGS = HashSet<String>(
            ["address", "article", "aside", "blockquote", "canvas", "dd", "div", "dl", "dt", "fieldset", "figcaption",
                "figure", "footer", "form", "h1", "h2", "h3", "h4", "h5", "h6", "header", "hgroup", "hr", "li", "main",
                "nav", "noscript", "ol", "output", "p", "pre", "section", "table", "tfoot", "ul", "video"])
    }

    private let emptyTagReplacement: HtmlEmptyTagReplacement

    private let trimmingAppender: TrimmingAppender

    private let inlineTags = ArrayList<InlineImpl>(0)

    private var currentBlock: ?BlockImpl = BlockImpl.root()

    private var isInsidePreTag: Bool = false

    private var previousIsBlock: Bool = false

    init(replacement: HtmlEmptyTagReplacement, trimmingAppender: TrimmingAppender) {
        this.emptyTagReplacement = replacement
        this.trimmingAppender = trimmingAppender
    }

    /**
     * html -> HtmlTag
     */
    public func processFragment(output: Appendable, htmlFragment: String, parent: HtmlTag): Unit {
        var parentTag = parent
        let tokeniser = Tokeniser(CharacterReader(htmlFragment), ParseErrorList.noTracking())
        while (true) {
            let token = tokeniser.read()
            let tokenType = token.typ
            if (TokenType.EOFType == tokenType) {
                break
            }
            match (tokenType) {
                case StartTagType =>
                    let startTag = (token as StartTagToken).getOrThrow()
                    let currentTag = if (isInlineTag(startTag.normalName())) {
                        processInlineTagStart(output, startTag, parentTag)
                    } else {
                        processBlockTagStart(output, startTag, parentTag)
                    }
                    if (!currentTag.isClosed()) {
                        parentTag = currentTag
                    }
                case EndTagType =>
                    let endTag = (token as EndTagToken).getOrThrow()
                    let currentTag = if (isInlineTag(endTag.normalName())) {
                        processInlineTagEnd(output, endTag)
                    } else {
                        processBlockTagEnd(output, endTag)
                    }
                    match (currentTag) {
                        case Some(t) => parentTag = t.parentTag.getOrThrow()
                        case _ => ()
                    }
                case CharacterType =>
                    let tag = processCharacter(output, (token as CharacterToken).getOrThrow())
                    if (let Some(tag) <- tag) {
                        parentTag.appendChild(tag)
                    }
                case _ => ()
            }
            token.reset()
        }
    }
    public func processFragmentInline(output: Appendable, htmlFragment: String, parent: ?HtmlTag): HtmlTag {
        var parentTag = parent
        let tokeniser = Tokeniser(CharacterReader(htmlFragment), ParseErrorList.noTracking())
        let token = tokeniser.read()
        let tokenType = token.typ
        match (tokenType) {
            case StartTagType =>
                let startTag = (token as StartTagToken).getOrThrow()
                let currentTag = if (isInlineTag(startTag.normalName())) {
                    processInlineTagStart(output, startTag, parentTag)
                } else {
                    processBlockTagStart(output, startTag, parentTag)
                }
                return currentTag
            case EndTagType =>
                let endTag = (token as EndTagToken).getOrThrow()
                if (isVoidTag(endTag.normalName())) {
                    return EndTag(endTag.normalName(), None)
                }
                let currentTag = if (isInlineTag(endTag.normalName())) {
                    processInlineTagEnd(output, endTag)
                } else {
                    processBlockTagEnd(output, endTag)
                }
                return EndTag(endTag.normalName(), currentTag)
            case _ => throw IllegalStateException()
        }
    }

    /* 
    public func flushInlineTags(documentLength: Int64, action: FlushAction<InlineHtmlTag>): Unit {
        if (inlineTags.size > 0) {
            if (documentLength > NO_END) {
                for (inline in inlineTags) {
                    inline.closeAt(documentLength)
                }
            }
            let list: Collection<InlineHtmlTag> = inlineTags |> map<InlineImpl, InlineHtmlTag> {v => v} |> collectArray
            action.apply(list)
            inlineTags.clear()
        } else {
            action.apply([])
        }
    }
    public func flushBlockTags(documentLength: Int64, action: FlushAction<BlockHtmlTag>): Unit {
        var block = currentBlock.getOrThrow()
        while (let Some(v) <- block._parent) {
            block = v
        }
        if (documentLength > NO_END) {
            block.closeAt(documentLength)
        }
        let children = block.children()
        if (children.size > 0) {
            action.apply(children)
        } else {
            action.apply([])
        }
        currentBlock = BlockImpl.root()
    }
     */
    public override func reset(): Unit {
        inlineTags.clear()
        currentBlock = BlockImpl.root()
    }

    protected func processInlineTagStart(output: Appendable, startTag: StartTagToken, parent: ?HtmlTag): HtmlTag {
        let name = startTag.normalName()
        let inline = InlineImpl(name, -1, extractAttributes(startTag))
        ensureNewLineIfPreviousWasBlock(output)
        if (isVoidTag(name) || startTag.selfClosing) {
            let replacement = emptyTagReplacement.replace(inline)
            if (replacement.isSome() && replacement().size > 0) {
                AppendableUtils.appendQuietly(output, replacement())
            }
            inline.closeAt(-1)
        }
        inlineTags.append(inline)
        parent?.appendChild(inline)
        inline
    }

    protected func processInlineTagEnd(output: Appendable, endTag: EndTagToken): ?HtmlTag {
        let openInline = findOpenInlineTag(endTag.normalName())
        if (let Some(openInline) <- openInline) {
            if (isEmpty(output, openInline)) {
                appendEmptyTagReplacement(output, openInline)
            }
            openInline.closeAt(output.size)
        }
        openInline ?? None
    }

    protected func processBlockTagStart(output: Appendable, startTag: StartTagToken, parent: ?HtmlTag): HtmlTag {
        let name = startTag.normalName()
        if (currentBlock?.name() == TAG_PARAGRAPH) {
            currentBlock?.closeAt(output.size)
            AppendableUtils.appendQuietly(output, r'\n')
            currentBlock = currentBlock?._parent ?? None
        } else {
            if (TAG_LIST_ITEM == name && currentBlock?.name() == TAG_LIST_ITEM) {
                currentBlock?.closeAt(output.size)
                currentBlock = currentBlock?._parent ?? None
            }
        }
        if (isBlockTag(name)) {
            isInsidePreTag = "pre" == name
            ensureNewLine(output)
        } else {
            ensureNewLineIfPreviousWasBlock(output)
        }
        let start = output.size
        let block = BlockImpl.create(name, start, extractAttributes(startTag), currentBlock, parent)
        let isVoid = isVoidTag(name) || startTag.selfClosing
        if (isVoid) {
            let replacement = emptyTagReplacement.replace(block)
            if (replacement.isSome() && replacement().size > 0) {
                AppendableUtils.appendQuietly(output, replacement())
            }
            block.closeAt(output.size)
        }
        appendBlockChild(block._parent.getOrThrow(), block)
        if (!isVoid) {
            this.currentBlock = block
        }
        block
    }

    protected func processBlockTagEnd(output: Appendable, endTag: EndTagToken): ?HtmlTag {
        let name = endTag.normalName()
        let block = findOpenBlockTag(endTag.normalName())
        if (let Some(block) <- block) {
            if ("pre" == name) {
                isInsidePreTag = false
            }
            if (isEmpty(output, block)) {
                appendEmptyTagReplacement(output, block)
            }
            block.closeAt(output.size)
            if (!block.isEmpty()) {
                previousIsBlock = isBlockTag(block.name())
            }
            if (TAG_PARAGRAPH == name) {
                AppendableUtils.appendQuietly(output, r'\n')
            }
            this.currentBlock = block._parent
        }
        block ?? None
    }

    protected func processCharacter(output: Appendable, character: CharacterToken): ?HtmlTag {
        /* 
        1. 判断是在Block还是Inline
            - Block -> TextTag
            - Inline -> set InlineTag.text
         */
        if (isInsidePreTag) {
            AppendableUtils.appendQuietly(output, character.getData())
        } else {
            ensureNewLineIfPreviousWasBlock(output)
            trimmingAppender.append(output, character.getData())
        }
        // 去掉前后换行 中间的换行符替换为软换行(空格) TODO:pre标签
        let str = character.getData().trimAscii()
        if (str.size > 0) {
            return TextTag(str.replace("\n", " "))
        }
        return None
    }

    protected func appendBlockChild(parent: BlockImpl, child: BlockImpl): Unit {
        var children = parent._children
        if (children.isNone()) {
            children = ArrayList<BlockImpl>(2)
            parent._children = children
        }
        children?.append(child)
    }

    protected func findOpenInlineTag(name: String): ?InlineImpl {
        var inline: InlineImpl
        for (i in inlineTags.size - 1..=0 : -1) {
            inline = inlineTags[i]
            if (name == inline.name() && inline._end < 0) {
                return inline
            }
        }
        return None
    }

    protected func findOpenBlockTag(name: String): ?BlockImpl {
        var blockTag = currentBlock
        while (blockTag.isSome() && !(blockTag().name() == name) && !blockTag().isClosed()) {
            blockTag = blockTag()._parent
        }
        return blockTag
    }

    protected func ensureNewLineIfPreviousWasBlock(output: Appendable): Unit {
        if (previousIsBlock) {
            ensureNewLine(output)
            previousIsBlock = false
        }
    }

    protected static func isInlineTag(name: String): Bool {
        return INLINE_TAGS.contains(name)
    }

    protected static func isVoidTag(name: String): Bool {
        return VOID_TAGS.contains(name)
    }

    protected static func isBlockTag(name: String): Bool {
        return BLOCK_TAGS.contains(name)
    }

    protected static func ensureNewLine(output: Appendable): Unit {
        let length = output.size
        if (length > 0 && b'\n' != output.toString()[length - 1]) {
            AppendableUtils.appendQuietly(output, r'\n')
        }
    }

    protected static func extractAttributes(startTag: StartTagToken): Map<String, String> {
        var map: Map<String, String>
        let attributes = startTag.attributes
        let size = attributes?.size ?? -1
        if (size > 0) {
            map = HashMap<String, String>(size)
            for (attribute in attributes()) {
                map.put(attribute.getKey().toAsciiLower(), attribute.getValue())
            }
        } else {
            map = HashMap<String, String>()
        }
        return map
    }

    protected static func isEmpty(output: Appendable, tag: HtmlTagImpl): Bool {
        return tag._start == output.size
    }

    protected func appendEmptyTagReplacement(output: Appendable, tag: HtmlTagImpl): Unit {
        let replacement = emptyTagReplacement.replace(tag)
        if (let Some(replacement) <- replacement) {
            AppendableUtils.appendQuietly(output, replacement)
        }
    }
}
