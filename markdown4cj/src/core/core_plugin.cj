/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */
package markdown.core

/**
 * @see CoreProps
 */
public class CorePlugin <: AbstractMarkdownPlugin {
    public func getClassType(): String {
        "CorePlugin"
    }

    public static func create(): CorePlugin {
        return CorePlugin()
    }

    /**
     * @return a set with enabled by default block types
     * Set<Class<? <: Block>>
     */
    public static let enabledBlockTypes: HashSet<String> = HashSet<String>(
            [
                "BlockQuote",
                "Heading",
                "FencedCodeBlock",
                "HtmlBlock",
                "ThematicBreak",
                "ListBlock",
                "IndentedCodeBlock"
            ]
        )

    private let onTextAddedListeners: ArrayList<OnTextAddedListener> = ArrayList<OnTextAddedListener>(0)

    private var _hasExplicitMovementMethod: Bool = false

    protected init() {
    }

    public func hasExplicitMovementMethod(hasExplicitMovementMethod: Bool): CorePlugin {
        this._hasExplicitMovementMethod = hasExplicitMovementMethod
        return this
    }

    /**
     * Can be useful to post-process text added. For example for auto-linking capabilities.
     * @see OnTextAddedListener
     */
    public func addOnTextAddedListener(onTextAddedListener: OnTextAddedListener): CorePlugin {
        onTextAddedListeners.add(onTextAddedListener)
        return this
    }

    public override func configureVisitor(builder: MarkdownVisitorBuilder): Unit {
        blockQuote(builder)
        bulletList(builder)
        code(builder)
        emphasis(builder)
        fencedCodeBlock(builder)
        hardLineBreak(builder)
        heading(builder)
        image(builder)
        indentedCodeBlock(builder)
        link(builder)
        listItem(builder)
        orderedList(builder)
        paragraph(builder)
        softLineBreak(builder)
        strongEmphasis(builder)
        text(builder)
        thematicBreak(builder)
    }

    private func text(builder: MarkdownVisitorBuilder): Unit {
        builder.on(
            "Text",
            {
                visitor, text => buildView(text, true)
            }
        )
    }

    private static func strongEmphasis(builder: MarkdownVisitorBuilder): Unit {
        builder.on(
            "StrongEmphasis",
            {
                visitor, strongEmphasis =>
                buildView(strongEmphasis, false)
                visitor.visitChildren(strongEmphasis)
            }
        )
    }

    private static func emphasis(builder: MarkdownVisitorBuilder): Unit {
        builder.on(
            "Emphasis",
            {
                visitor, emphasis =>
                buildView(emphasis, false)
                visitor.visitChildren(emphasis)
            }
        )
    }

    private static func blockQuote(builder: MarkdownVisitorBuilder): Unit {
        builder.on(
            "BlockQuote",
            {
                visitor, blockQuote =>
                buildView(blockQuote, true)
                visitor.visitChildren(blockQuote)
            }
        )
    }

    private static func code(builder: MarkdownVisitorBuilder): Unit {
        builder.on(
            "Code",
            {
                visitor, code => buildView(code, true)
            }
        )
    }

    private static func fencedCodeBlock(builder: MarkdownVisitorBuilder): Unit {
        builder.on(
            "FencedCodeBlock",
            {
                visitor, node =>
                let fencedCodeBlock: FencedCodeBlock = (node as FencedCodeBlock)()
                buildView(fencedCodeBlock, true)
                visitCodeBlock(visitor, fencedCodeBlock.getInfo(), fencedCodeBlock.getLiteral(), fencedCodeBlock)
            }
        )
    }

    private static func indentedCodeBlock(builder: MarkdownVisitorBuilder): Unit {
        builder.on(
            "IndentedCodeBlock",
            {
                visitor, node =>
                let indentedCodeBlock: IndentedCodeBlock = (node as IndentedCodeBlock)()
                buildView(indentedCodeBlock, true)
                visitCodeBlock(visitor, Option<String>.None, indentedCodeBlock.getLiteral(), indentedCodeBlock)
            }
        )
    }

    // his method is moved from ImagesPlugin. Alternative implementations must set SpanFactory
    // for Image node in order for this visitor to function
    private static func image(builder: MarkdownVisitorBuilder): Unit {
        builder.on(
            "Image",
            {
                visitor, image =>
                buildView(image, true)
                visitor.visitChildren(image)
            }
        )
    }

    // @VisibleForTesting
    static func visitCodeBlock(_: MarkdownVisitor, _: ?String, _: String, _: Node): Unit {
        // visitor.blockStart(node)

        // let length: Int = visitor.length()

        // visitor.builder().appends('\u{a0}').appends('\n').appends(
        //     visitor.configuration().syntaxHighlight().highlight(info, code))

        // visitor.ensureNewLine()

        // visitor.builder().append('\u{a0}')

        // CoreProps.CODE_BLOCK_INFO.set(visitor.renderProps(), info)

        // visitor.blockEnd(node)
    }

    private static func bulletList(builder: MarkdownVisitorBuilder): Unit {
        builder.on("BulletList", SimpleBlockNodeVisitor)
    }

    private static func orderedList(builder: MarkdownVisitorBuilder): Unit {
        builder.on("OrderedList", SimpleBlockNodeVisitor)
    }

    private static func listItem(builder: MarkdownVisitorBuilder): Unit {
        builder.on(
            "ListItem",
            {
                visitor, listItem =>
                buildView(listItem, true)
                visitor.visitChildren(listItem)
            }
        )
    }

    private static func listLevel(node: Node): Int {
        var level: Int = 0
        var parent: ?Node = node.getParent()
        while (let Some(v) <- parent) {
            if (v is ListItem) {
                level += 1
            }
            parent = v.getParent()
        }
        return level
    }

    private static func thematicBreak(builder: MarkdownVisitorBuilder): Unit {
        builder.on(
            "ThematicBreak",
            {
                visitor, thematicBreak => buildView(thematicBreak, true)
            }
        )
    }

    private static func heading(builder: MarkdownVisitorBuilder): Unit {
        builder.on(
            "Heading",
            {
                visitor, heading =>
                buildView(heading, true)
                visitor.visitChildren(heading)
            }
        )
    }

    private static func softLineBreak(builder: MarkdownVisitorBuilder): Unit {
        builder.on(
            "SoftLineBreak",
            {
                visitor, softLineBreak => buildView(softLineBreak, true)
            }
        )
    }

    private static func hardLineBreak(builder: MarkdownVisitorBuilder): Unit {
        builder.on(
            "HardLineBreak",
            {
                visitor, hardLineBreak => buildView(hardLineBreak, true)
            }
        )
    }

    private static func paragraph(builder: MarkdownVisitorBuilder): Unit {
        builder.on(
            "Paragraph",
            {
                visitor, paragraph =>
                buildView(paragraph, true)
                visitor.visitChildren(paragraph)
            }
        )
    }

    private static func isInTightList(paragraph: Paragraph): Bool {
        if (let Some(Some(list: ListBlock)) <- paragraph.getParent()?.getParent()) {
            return list.isTight()
        }
        return false
    }

    private static func link(builder: MarkdownVisitorBuilder): Unit {
        builder.on(
            "Link",
            {
                visitor, link =>
                buildView(link, false)
                visitor.visitChildren(link)
            }
        )
    }
}

/**
 * @see #addOnTextAddedListener(OnTextAddedListener)
 */
public interface OnTextAddedListener {

    /**
     * Will be called when text is added to resulting {@link SpannableBuilder}.
     * Please note that only text represented by {@link Text} node will trigger this callback
     * (text inside code and code-blocks won\'t trigger it).
     * <p>
     * Please note that if you wish to append spans you must use {@code start} parameter
     * in order to place spans correctly ({@code start} represents the index at which {@code text}
     * was added). So, to set a span for the whole length of the text added one should use:
     * <p>
     * {@code
     * visitor.builder().setSpan(MySpan(), start, start + text.length(), 0)
     * }
     *
     * @param visitor {@link MarkdownVisitor}
     * @param text    literal that had been added
     * @param start   index in {@code visitor} as which text had been added
     * @see #addOnTextAddedListener(OnTextAddedListener)
     */
    func onTextAdded(visitor: MarkdownVisitor, text: String, start: Int): Unit
}

func SimpleBlockNodeVisitor(visitor: MarkdownVisitor, node: Node): Unit {
    buildView(node, true)
    visitor.visitChildren(node)
}
