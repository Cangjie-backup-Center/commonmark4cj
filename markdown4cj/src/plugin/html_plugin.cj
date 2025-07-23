/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2025. All rights reserved.
 */
package markdown.plugin

public class HtmlPlugin <: AbstractMarkdownPlugin {
    public static func create(): HtmlPlugin {
        return HtmlPlugin()
    }

    public static let SCRIPT_DEF_TEXT_SIZE_RATIO = 0.75

    private let builder: MarkdownHtmlRendererImplBuilder

    private var htmlParser: ?MarkdownHtmlParserImpl = None
    private var htmlRenderer: ?MarkdownHtmlRenderer = None

    private var _emptyTagReplacement: HtmlEmptyTagReplacement = HtmlEmptyTagReplacement()

    init() {
        this.builder = MarkdownHtmlRendererImplBuilder()
    }

    /**
     * @param allowNonClosedTags whether or not non-closed tags should be closed
     *                           at the document end. By default `false`
     */
    public func allowNonClosedTags(allowNonClosedTags: Bool): HtmlPlugin {
        builder.allowNonClosedTagsMethod(allowNonClosedTags)
        return this
    }

    public func addHandler(tagHandler: TagHandler): HtmlPlugin {
        builder.addHandler(tagHandler)
        return this
    }

    public func getHandler(tagName: String): ?TagHandler {
        return builder.getHandler(tagName)
    }

    /**
     * Indicate if HtmlPlugin should register default HTML tag handlers. Pass `true` to <strong>not</strong>
     * include default handlers. By default default handlers are included. You can use
     * {@link TagHandlerNoOp} to no-op certain default tags.
     *
     * @see TagHandlerNoOp
     */
    public func excludeDefaults(excludeDefaults: Bool): HtmlPlugin {
        builder.excludeDefaultsMethod(excludeDefaults)
        return this
    }

    public func emptyTagReplacement(emptyTagReplacement: HtmlEmptyTagReplacement): HtmlPlugin {
        this._emptyTagReplacement = emptyTagReplacement
        return this
    }

    public override func configureParser(_: ParserBuilder): Unit {
        if (!builder.excludeDefaultsMethod()) {
            // builder.addDefaultTagHandler(SubScriptHandler())
            // builder.addDefaultTagHandler(SuperScriptHandler())
            // builder.addDefaultTagHandler(UnderlineHandler())
            builder.addDefaultTagHandler(ImageHandler())
            builder.addDefaultTagHandler(LinkHandler())
            builder.addDefaultTagHandler(StrongEmphasisHandler())
            builder.addDefaultTagHandler(EmphasisHandler())
            builder.addDefaultTagHandler(StrikeHandler())
            builder.addDefaultTagHandler(BlockquoteHandler())

            builder.addDefaultTagHandler(BulletListHandler())
            builder.addDefaultTagHandler(OrderedListHandler())
            builder.addDefaultTagHandler(ListItemHandler())

            builder.addDefaultTagHandler(HeadingHandler())
            builder.addDefaultTagHandler(BrHandler())
            builder.addDefaultTagHandler(ThematicBreakHandler())
            builder.addDefaultTagHandler(FontHandler())

            builder.addDefaultTagHandler(TableHandler())
            builder.addDefaultTagHandler(TableHeadHandler())
            builder.addDefaultTagHandler(TableBodyHandler())
            builder.addDefaultTagHandler(TableRowHandler())
            builder.addDefaultTagHandler(TableCellHandler())

            builder.addDefaultTagHandler(CodeHandler())
            builder.addDefaultTagHandler(IndentedCodeBlockHandler())
            builder.addDefaultTagHandler(TextHandler())

            builder.addDefaultTagHandler(ParagraphHandler())
        }
        htmlParser = MarkdownHtmlParserImpl.create(_emptyTagReplacement)
        htmlRenderer = builder.build()
    }

    public override func configureVisitor(builder: MarkdownVisitorBuilder): Unit {
        builder
            .on(
                "HtmlBlock",
                {
                    visitor, node =>
                    let htmlBlock = (node as HtmlBlock).getOrThrow()
                    visitHtml(visitor, node, htmlBlock.getLiteral())
                }
            )
            .on(
                "HtmlInline",
                {
                    visitor, node =>
                    let htmlInline = (node as HtmlInline).getOrThrow()
                    visitHtmlInline(visitor, htmlInline)
                }
            )
            .on(
                "ImageHtmlNode",
                {
                    visitor, node =>
                    buildView(node, true)
                    visitor.visitChildren(node)
                }
            )
            .on(
                "FontNode",
                {
                    visitor, node =>
                    let view = buildView(node, false, needProps: true)
                    view.props?.add("FontNode", node)
                    visitor.visitChildren(node)
                }
            )
            .on(
                "IgnoreNode",
                {
                    visitor, node =>
                    buildView(node, false)
                    visitor.visitChildren(node)
                }
            )
    }

    public func visitHtml(visitor: MarkdownVisitor, node: Node, html: String): Unit {
        let htmlParser = htmlParser.getOrThrow()
        var rootTag = BlockImpl.root()

        // htmlString -> HtmlTag
        htmlParser.processFragment(StringBuilder(), html, rootTag)
        // printTag(rootTag) // debug

        // rootTag.children分类
        rootTag = tagCategory(rootTag)

        // HtmlTag ---handler---> CommonMarkNode
        let tagNode = htmlRenderer.getOrThrow().render(visitor, htmlParser, rootTag)
        htmlParser.reset()

        // replace htmlNode with tagNode
        node.replaceWith(tagNode)

        // CommonMarkNode -> NodeView
        buildView(tagNode, false)

        // visit Children
        visitor.visitChildren(tagNode)
    }

    func tagCategory(rootTag: BlockImpl): BlockImpl {
        let newRoot = BlockImpl.root()
        var p: ?BlockImpl = None
        for (tag in rootTag.getChildren()) {
            if (tag.isBlock()) {
                newRoot.appendChild(tag)
                p = None
            } else if (tag.isInline()) {
                if (p.isNone()) {
                    p = BlockImpl.create("p", 0, HashMap<String, String>(), newRoot, newRoot)
                }
                p?.appendChild(tag)
            }
        }
        // printTag(newRoot) // debug
        newRoot
    }

    public func visitHtmlInline(visitor: MarkdownVisitor, htmlInline: HtmlInline): Unit {
        if (htmlInline.getParent().isNone() && htmlInline.getPrevious().isNone() && htmlInline.getNext().isNone()) {
            return
        }
        // 保存锚点
        let anchorNode = Paragraph1()
        htmlInline.insertBefore(anchorNode)

        visitHtmlInline(visitor, StringBuilder(), htmlInline, anchorNode)
        var resNode: ?Node = anchorNode.getFirstChild()

        htmlParser?.reset()

        // 保存解析结果
        anchorNode.flat()

        // 解析InlineHtml可能破坏后续兄弟节点结构
        // 手动遍历解析结果构建NodeView
        while (let Some(n) <- resNode) {
            n.accept(visitor)
            resNode = n.getNext()
        }
    }
    /*
     * html->HtmlTag->Node
     * 将开闭的tag组合起来
     */
    private func visitHtmlInline(visitor: MarkdownVisitor, appender: StringBuilder, node: Node, parent: Node): Unit {
        let htmlParser = htmlParser.getOrThrow()
        let htmlRenderer = htmlRenderer.getOrThrow()
        var parentNode = parent
        var nextNode: ?Node = node.getNext()
        // printNode(node) // debug
        match (node) {
            case htmlInline: HtmlInline =>
                let htmlString = htmlInline.getLiteral()
                let tag = htmlParser.processFragmentInline(appender, htmlString, None)
                // println("1.2 ${tag} ${tag is EndTag} ${tag.isClosed()} ${parentNode}") // debug
                if (let Some(end) <- (tag as EndTag)) {
                    // println("1.21 ${end.startTag.isSome()}") // debug
                    // end tag
                    if (end.startTag.isSome()) {
                        parentNode = parentNode.getParent().getOrThrow()
                    }
                } else if (tag.isClosed() == true) {
                    // println("1.22 ") // debug
                    // self close tag
                    let tagNode = htmlRenderer.render(visitor, htmlParser, tag)
                    parentNode.appendChild(tagNode)
                } else if (tag.isClosed() == false) {
                    // println("1.23 ") // debug
                    // start tag
                    let tagNode = htmlRenderer.render(visitor, htmlParser, tag)
                    parentNode.appendChild(tagNode)
                    parentNode = tagNode
                }
                node.unlink()
            case t: Text =>
                // println("1.24 ") // debug
                node.unlink()
                match (parentNode) {
                    case v: Code => v.setLiteral(t.getLiteral())
                    case _ => parentNode.appendChild(node)
                }
            case _ =>
                // println("1.25 ") // debug
                // 普通markdownNode
                node.unlink()
                parentNode.appendChild(node)
        }

        // printNode(parentNode) // debug
        // println("1.5 ${nextNode} ${parentNode}") // debug
        if (let Some(n) <- nextNode) {
            visitHtmlInline(visitor, appender, n, parentNode)
        }
    }

    public override func afterRender(doc: Node, _: MarkdownVisitor): Unit {
        let docView = doc.getView()
        for (i in 0..docView.children.size) {
            let nv = docView.children[i]
            if(nv.node is Block){
                continue
            }
            let pv = NodeView(Paragraph())
            pv.children.add(nv)
            docView.children[i] = pv
        }
    }

    public override func getClassType(): String {
        "HtmlPlugin"
    }
}

class Paragraph1 <: Paragraph {
    let hash = DateTime.now().hashCode().toString()
    protected override func toStringAttributes(): String {
        return hash
    }
    public override func getParent(): ?Node {
        parent
    }
}
