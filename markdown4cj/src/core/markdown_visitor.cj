/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */
/**
 * Created on 028 24/2/28
 */
package markdown.core

/**
 * Configurable visitor of parsed markdown. Allows visiting certain (registered) nodes without
 * need to create own instance of this class.
 *
 * @see Builder#on(Class, NodeVisitor)
 * @see MarkdownPlugin#configureVisitor(Builder)
 */
public interface MarkdownVisitor <: Visitor {
    func renderProps(): RenderProps

    /**
     * Visits all children of supplied node.
     *
     * @param node to visit
     */
    func visitChildren(node: Node): Unit

    /**
     * Executes a check if there is further content available.
     *
     * @param node to check
     * @return Bool indicating if there are more nodes after supplied one
     */
    func hasNext(node: Node): Bool

    /**
     * Clears state of visitor (both {@link RenderProps} and {@link SpannableBuilder} will be cleared
     */
    func clear(): Unit

    func blockStart(node: Node): Unit

    func blockEnd(node: Node): Unit
}

/**
 * @see Builder#on(Class, NodeVisitor)
 * N <: Node
 */
public type NodeVisitor = (visitor: MarkdownVisitor, n: Node) -> Unit

/**
 */
class MarkdownVisitorImpl <: MarkdownVisitor {
    private let props: RenderProps

    private let nodes: Map<String, NodeVisitor>

    private let blockHandler: BlockHandler

    init(
        props: RenderProps,
        nodes: Map<String, NodeVisitor>,
        blockHandler: BlockHandler
    ) {
        this.props = props
        this.nodes = nodes
        this.blockHandler = blockHandler
    }

    public override func visit(document: Document): Unit {
        visitNode(document)
    }

    public override func visit(paragraph: Paragraph): Unit {
        visitNode(paragraph)
    }

    public override func visit(fencedCodeBlock: FencedCodeBlock): Unit {
        visitNode(fencedCodeBlock)
    }

    public override func visit(thematicBreak: ThematicBreak): Unit {
        visitNode(thematicBreak)
    }

    public override func visit(htmlInline: HtmlInline): Unit {
        visitNode(htmlInline)
    }

    public override func visit(htmlBlock: HtmlBlock): Unit {
        visitNode(htmlBlock)
    }

    public override func visit(indentedCodeBlock: IndentedCodeBlock): Unit {
        visitNode(indentedCodeBlock)
    }

    public override func visit(heading: Heading): Unit {
        visitNode(heading)
    }

    public override func visit(blockQuote: BlockQuote): Unit {
        visitNode(blockQuote)
    }

    public override func visit(orderedList: OrderedList): Unit {
        visitNode(orderedList)
    }

    public override func visit(bulletList: BulletList): Unit {
        visitNode(bulletList)
    }

    public override func visit(listItem: ListItem): Unit {
        visitNode(listItem)
    }

    public override func visit(emphasis: Emphasis): Unit {
        visitNode(emphasis)
    }

    public override func visit(strongEmphasis: StrongEmphasis): Unit {
        visitNode(strongEmphasis)
    }

    public override func visit(link: Link): Unit {
        visitNode(link)
    }

    public override func visit(text: Text): Unit {
        visitNode(text)
    }

    public override func visit(code: Code): Unit {
        visitNode(code)
    }

    public override func visit(image: Image): Unit {
        visitNode(image)
    }

    public override func visit(hardLineBreak: HardLineBreak): Unit {
        visitNode(hardLineBreak)
    }

    public override func visit(softLineBreak: SoftLineBreak): Unit {
        visitNode(softLineBreak)
    }

    public override func visit(linkReferenceDefinition: LinkReferenceDefinition): Unit {
        visitNode(linkReferenceDefinition)
    }

    public override func visit(customBlock: CustomBlock): Unit {
        visitNode(customBlock)
    }

    public override func visit(customNode: CustomNode): Unit {
        visitNode(customNode, needCollect: false)
    }

    private func visitNode(node: Node, needCollect!: Bool = true): Unit {
        let nodeVisitor: ?NodeVisitor = nodes.get(node.getNodeType())
        if (let Some(f) <- nodeVisitor) {
            f(this, node)
        } else {
            buildView(node, needCollect)
            visitChildren(node)
        }
    }

    public override func renderProps(): RenderProps {
        return props
    }

    public override func visitChildren(parent: Node): Unit {
        var node: ?Node = parent.getFirstChild()
        while (let Some(v) <- node) {
            // A subclass of this visitor might modify the node, 
            // resulting in getNext returning a different node or no node after visiting it.
            // So get the next node before visiting.
            let next = v.getNext()
            v.accept(this)
            node = next
        }
    }

    public override func hasNext(node: Node): Bool {
        return node.getNext().isSome()
    }

    public override func clear(): Unit {
        props.clearAll()
    }

    public override func blockStart(node: Node): Unit {
        blockHandler.blockStart(this, node)
    }

    public override func blockEnd(node: Node): Unit {
        blockHandler.blockEnd(this, node)
    }
}

public interface MarkdownVisitorBuilder {
    /**
     * @param node        to register
     * @param nodeVisitor {@link NodeVisitor} to be used or None to ignore previously registered
     *                    visitor for this node
     * N <: Node
     */
    func on(node: String, nodeVisitor: ?NodeVisitor): MarkdownVisitorBuilder

    /**
     * @param blockHandler to handle block start/end
     * @see BlockHandler
     * @see BlockHandlerDef
     */
    func blockHandler(blockHandler: BlockHandler): MarkdownVisitorBuilder

    func build(props: RenderProps): MarkdownVisitor
}

class MarkdownVisitorBuilderImpl <: MarkdownVisitorBuilder {
    private let nodes: Map<String, NodeVisitor> = HashMap<String, NodeVisitor>()
    private var _blockHandler: ?BlockHandler = None

    public override func on(node: String, nodeVisitor: ?NodeVisitor): MarkdownVisitorBuilder {
        // we should allow `None` to exclude node from being visited (for example to disable
        // some functionality)
        if (let Some(v) <- nodeVisitor) {
            nodes.put(node, v)
        } else {
            nodes.remove(node)
        }
        return this
    }

    public override func blockHandler(blockHandler: BlockHandler): MarkdownVisitorBuilder {
        this._blockHandler = blockHandler
        return this
    }

    public override func build(props: RenderProps): MarkdownVisitor {
        let blockHandler: BlockHandler = this._blockHandler ?? BlockHandlerDef()

        return MarkdownVisitorImpl(
            props,
            nodes,
            blockHandler
        )
    }
}

type MarkdownVisitorFactory = () -> MarkdownVisitor

func createMarkdownVisitorFactory(builder: MarkdownVisitorBuilder): MarkdownVisitorFactory {
    return {
        => builder.build(RenderProps())
    }
}
