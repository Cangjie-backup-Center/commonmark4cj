/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2025. All rights reserved.
 */
package markdown.plugin

public abstract class TagHandler {
    public func handle(visitor: ?MarkdownVisitor, renderer: MarkdownHtmlRenderer, tag: HtmlTag): Node

    public func supportedTags(): Collection<String>

    protected static func visitChildren(visitor: ?MarkdownVisitor, renderer: MarkdownHtmlRenderer, tag: HtmlTag,
        nodeParent: Node): Unit {
        var handler: ?TagHandler
        for (child in tag.getChildren()) {
            visit(visitor, renderer, child, nodeParent)
        }
    }

    protected static func visit(visitor: ?MarkdownVisitor, renderer: MarkdownHtmlRenderer, tag: HtmlTag,
        nodeParent: ?Node): Node {
        var handler: ?TagHandler
        handler = renderer.tagHandler(tag.name())
        return if (let Some(v) <- handler) {
            let node = v.handle(visitor, renderer, tag)
            nodeParent?.appendChild(node)
            node
        } else {
            let node: Node = IgnoreNode()
            nodeParent?.appendChild(node)
            visitChildren(visitor, renderer, tag, node)
            node
        }
    }

    protected static func visitChildrenText(block: HtmlTag, stringBuilder: StringBuilder): Unit {
        match (block) {
            case v: TextTag => stringBuilder.append(v.text)
            case _ => for (child in block.getChildren()) {
                visitChildrenText(child, stringBuilder)
            }
        }
    }
}

public class BrHandler <: TagHandler {
    public init() {
    }

    public override func handle(_: ?MarkdownVisitor, _: MarkdownHtmlRenderer, _: HtmlTag): Node {
        return HardLineBreak()
    }

    public override func supportedTags(): Collection<String> {
        return ["br"]
    }
}

public class ThematicBreakHandler <: TagHandler {
    public init() {
    }

    public override func handle(_: ?MarkdownVisitor, _: MarkdownHtmlRenderer, _: HtmlTag): Node {
        return ThematicBreak()
    }

    public override func supportedTags(): Collection<String> {
        return ["hr"]
    }
}

public class FontHandler <: TagHandler {
    public init() {
    }

    public override func handle(visitor: ?MarkdownVisitor, renderer: MarkdownHtmlRenderer, tag: HtmlTag): Node {
        let attributes: Map<String, String> = tag.attributes()
        let color: ?String = attributes.get("color")
        let size: ?String = attributes.get("size")
        let fontNode: FontNode = FontNode(color, size)
        visitChildren(visitor, renderer, tag, fontNode)
        return fontNode
    }

    public override func supportedTags(): Collection<String> {
        return ["font"]
    }
}

public class HeadingHandler <: TagHandler {
    public init() {
    }

    public override func handle(visitor: ?MarkdownVisitor, renderer: MarkdownHtmlRenderer, tag: HtmlTag): Node {
        var level: Int64
        try {
            level = Int64.parse(tag.name()[1..=1])
        } catch (e: Exception) {
            level = 0
        }
        if (level < 1 || level > 6) {
            return IgnoreNode()
        }
        let heading: Heading = Heading()
        heading.setLevel(level)
        visitChildren(visitor, renderer, tag, heading)
        return heading
    }

    public override func supportedTags(): Collection<String> {
        return ["h1", "h2", "h3", "h4", "h5", "h6"]
    }
}

public class ImageHandler <: TagHandler {
    public init() {
    }

    public override func handle(visitor: ?MarkdownVisitor, renderer: MarkdownHtmlRenderer, tag: HtmlTag): Node {
        let attributes: Map<String, String> = tag.attributes()
        let src: ?String = attributes.get("src")
        let width: ?String = attributes.get("width")
        let height: ?String = attributes.get("height")

        if (let Some(v) <- src) {
            let imageHtmlNode: ImageHtmlNode = ImageHtmlNode(v, width, height)
            visitChildren(visitor, renderer, tag, imageHtmlNode)
            return imageHtmlNode
        } else {
            let ignoreNode: IgnoreNode = IgnoreNode()
            visitChildren(visitor, renderer, tag, ignoreNode)
            return ignoreNode
        }
    }

    public override func supportedTags(): Collection<String> {
        return ["img"]
    }
}

public class LinkHandler <: TagHandler {
    public init() {
    }

    public override func handle(visitor: ?MarkdownVisitor, renderer: MarkdownHtmlRenderer, tag: HtmlTag): Node {
        let attributes: Map<String, String> = tag.attributes()
        let destination: ?String = attributes.get("href")
        let title: ?String = attributes.get("title")
        if (let Some(v) <- destination) {
            let link: Link = Link(v, title)
            visitChildren(visitor, renderer, tag, link)
            return link
        } else {
            let ignoreNode: IgnoreNode = IgnoreNode()
            visitChildren(visitor, renderer, tag, ignoreNode)
            return ignoreNode
        }
    }

    public override func supportedTags(): Collection<String> {
        return ["a"]
    }
}

public class StrongEmphasisHandler <: TagHandler {
    public init() {
    }

    public override func handle(visitor: ?MarkdownVisitor, renderer: MarkdownHtmlRenderer, tag: HtmlTag): Node {
        let strongEmphasis: StrongEmphasis = StrongEmphasis()
        visitChildren(visitor, renderer, tag, strongEmphasis)
        return strongEmphasis
    }

    public override func supportedTags(): Collection<String> {
        return ["b", "strong"]
    }
}

public class EmphasisHandler <: TagHandler {
    public init() {
    }

    public override func handle(visitor: ?MarkdownVisitor, renderer: MarkdownHtmlRenderer, tag: HtmlTag): Node {
        let emphasis: Emphasis = Emphasis()
        visitChildren(visitor, renderer, tag, emphasis)
        return emphasis
    }

    public override func supportedTags(): Collection<String> {
        return ["i", "em", "cite", "dfn"]
    }
}

public class StrikeHandler <: TagHandler {
    public init() {
    }

    public override func handle(visitor: ?MarkdownVisitor, renderer: MarkdownHtmlRenderer, tag: HtmlTag): Node {
        let strikethrough: Strikethrough = Strikethrough()
        visitChildren(visitor, renderer, tag, strikethrough)
        return strikethrough
    }

    public override func supportedTags(): Collection<String> {
        return ["s", "del"]
    }
}

public class BlockquoteHandler <: TagHandler {
    public init() {
    }

    public override func handle(visitor: ?MarkdownVisitor, renderer: MarkdownHtmlRenderer, tag: HtmlTag): Node {
        let blockQuoteTmp: BlockQuote = BlockQuote()
        visitChildren(visitor, renderer, tag, blockQuoteTmp)
        // 添加paragraph层
        let blockQuote = BlockQuote()
        nodeCategory(blockQuoteTmp, blockQuote)
        return blockQuote
    }

    public override func supportedTags(): Collection<String> {
        return ["blockquote"]
    }
}

public class BulletListHandler <: TagHandler {
    public init() {
    }

    public override func handle(visitor: ?MarkdownVisitor, renderer: MarkdownHtmlRenderer, tag: HtmlTag): Node {
        let bulletList: BulletList = BulletList(r'-')
        visitChildren(visitor, renderer, tag, bulletList)
        return bulletList
    }

    public override func supportedTags(): Collection<String> {
        return ["ul"]
    }
}

public class OrderedListHandler <: TagHandler {
    public init() {
    }

    public override func handle(visitor: ?MarkdownVisitor, renderer: MarkdownHtmlRenderer, tag: HtmlTag): Node {
        let attributes: Map<String, String> = tag.attributes()
        let start: ?String = attributes.get("start")
        if (let Some(v) <- start) {
            let orderedList: OrderedList = OrderedList(Int64.parse(v), r'-')
            visitChildren(visitor, renderer, tag, orderedList)
            return orderedList
        } else {
            let orderedList: OrderedList = OrderedList(0, r'-')
            visitChildren(visitor, renderer, tag, orderedList)
            return orderedList
        }
    }

    public override func supportedTags(): Collection<String> {
        return ["ol"]
    }
}

public class ListItemHandler <: TagHandler {
    public init() {
    }

    public override func handle(visitor: ?MarkdownVisitor, renderer: MarkdownHtmlRenderer, tag: HtmlTag): Node {
        let listItemTmp: ListItem = ListItem()
        visitChildren(visitor, renderer, tag, listItemTmp)
        // 添加paragraph层
        let listItem = ListItem()
        nodeCategory(listItemTmp, listItem)
        return listItem
    }

    public override func supportedTags(): Collection<String> {
        return ["li"]
    }
}

public class TableHandler <: TagHandler {
    public init() {
    }

    public override func handle(visitor: ?MarkdownVisitor, renderer: MarkdownHtmlRenderer, tag: HtmlTag): Node {
        let tableBlock: TableBlock = TableBlock()
        visitChildren(visitor, renderer, tag, tableBlock)
        return tableBlock
    }

    public override func supportedTags(): Collection<String> {
        return ["table"]
    }
}

public class TableHeadHandler <: TagHandler {
    public init() {
    }

    public override func handle(visitor: ?MarkdownVisitor, renderer: MarkdownHtmlRenderer, tag: HtmlTag): Node {
        let tableHead: TableHead = TableHead()
        visitChildren(visitor, renderer, tag, tableHead)
        return tableHead
    }

    public override func supportedTags(): Collection<String> {
        return ["thead"]
    }
}

public class TableBodyHandler <: TagHandler {
    public init() {
    }

    public override func handle(visitor: ?MarkdownVisitor, renderer: MarkdownHtmlRenderer, tag: HtmlTag): Node {
        let tableBody: TableBody = TableBody()
        visitChildren(visitor, renderer, tag, tableBody)
        return tableBody
    }

    public override func supportedTags(): Collection<String> {
        return ["tbody", "tfoot"]
    }
}

public class TableRowHandler <: TagHandler {
    public init() {
    }

    public override func handle(visitor: ?MarkdownVisitor, renderer: MarkdownHtmlRenderer, tag: HtmlTag): Node {
        let tableRow: TableRow = TableRow()
        visitChildren(visitor, renderer, tag, tableRow)
        return tableRow
    }

    public override func supportedTags(): Collection<String> {
        return ["tr"]
    }
}

public class TableCellHandler <: TagHandler {
    public init() {
    }

    public override func handle(visitor: ?MarkdownVisitor, renderer: MarkdownHtmlRenderer, tag: HtmlTag): Node {
        let tableCell: TableCell = TableCell()
        visitChildren(visitor, renderer, tag, tableCell)
        return tableCell
    }

    public override func supportedTags(): Collection<String> {
        return ["th", "td"]
    }
}

public class CodeHandler <: TagHandler {
    public init() {
    }

    public override func handle(_: ?MarkdownVisitor, _: MarkdownHtmlRenderer, tag: HtmlTag): Node {
        let sb: StringBuilder = StringBuilder()
        visitChildrenText(tag, sb)
        let code: Code = Code(sb.toString())
        return code
    }

    public override func supportedTags(): Collection<String> {
        return ["code", "samp", "var", "kbd"]
    }
}

public class IndentedCodeBlockHandler <: TagHandler {
    public init() {
    }

    public override func handle(_: ?MarkdownVisitor, _: MarkdownHtmlRenderer, tag: HtmlTag): Node {
        let sb: StringBuilder = StringBuilder()
        visitChildrenText(tag, sb)
        let indentedCodeBlock: IndentedCodeBlock = IndentedCodeBlock()
        indentedCodeBlock.setLiteral(sb.toString())
        return indentedCodeBlock
    }

    public override func supportedTags(): Collection<String> {
        return ["pre"]
    }
}

public class TextHandler <: TagHandler {
    public init() {
    }

    public override func handle(_: ?MarkdownVisitor, _: MarkdownHtmlRenderer, tag: HtmlTag): Node {
        let textTag: TextTag = (tag as TextTag).getOrThrow()
        let text: Text = Text(textTag.text)
        return text
    }

    public override func supportedTags(): Collection<String> {
        return [""]
    }
}

public class ParagraphHandler <: TagHandler {
    public init() {
    }

    public override func handle(visitor: ?MarkdownVisitor, renderer: MarkdownHtmlRenderer, tag: HtmlTag): Node {
        let p = Paragraph()
        visitChildren(visitor, renderer, tag, p)
        return p
    }

    public override func supportedTags(): Collection<String> {
        return ["p"]
    }
}

func nodeCategory(rootNode: Node, newRoot: Node): Node {
    var p: ?Paragraph = None
    for (n in rootNode.iterateChildren()) {
        if (n is Block) {
            newRoot.appendChild(n)
            p = None
        } else {
            if (p.isNone()) {
                let pt = Paragraph()
                p = pt
                newRoot.appendChild(pt)
            }
            p?.appendChild(n)
        }
    }
    newRoot
}
