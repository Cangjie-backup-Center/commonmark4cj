/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */
package markdown.plugin

public class TocPlugin <: AbstractMarkdownPlugin {
    public static func create(): TocPlugin {
        return TocPlugin()
    }
    public func configureParser(builder: ParserBuilder): Unit {
        builder.postProcessor(TocPostProcessor())
    }

    public func configureVisitor(builder: MarkdownVisitorBuilder): Unit {
        builder.on(
            HeadLink.typeInfo,
            {
                visitor, node => buildView(node, true)
            }
        )
    }

    public func getClassType(): String {
        "TocPlugin"
    }
}

class TocPostProcessor <: PostProcessor {
    let parser = Parser.builder().build()
    public func process(node: Node): Node {
        node.accept(TocVisitor())
        return node
    }
}

class TocVisitor <: AbstractVisitor {
    let needReplace = ArrayList<Paragraph>()

    public func visit(text: Text): Unit {
        let p = if (let Some(v: Paragraph) <- text.getParent()) {
            v
        } else {
            return
        }
        let str = text.getLiteral().trimAscii().toAsciiLower()
        if (str == "[toc]" || str.startsWith("[toc] ")) {
            if (text.getPrevious().isSome()) {
                let prePart = Paragraph()
                var n: ?Node = text.getPrevious()
                while (let Some(v) <- n) {
                    n = v.getPrevious()
                    prePart.prependChild(v)
                }
                p.insertBefore(prePart)
            }

            if (text.getNext().isSome()) {
                let nextPart = Paragraph()
                var n: ?Node = text.getNext()
                while (let Some(v) <- n) {
                    n = v.getNext()
                    nextPart.appendChild(v)
                }
                p.insertAfter(nextPart)
            }

            needReplace.append(p)
        }
    }

    public func visit(doc: Document): Unit {
        visitChildren(doc)
        let tocNode = buildToc(doc)
        for (p in needReplace) {
            p.insertAfter(deepClone(tocNode))
            p.unlink()
        }
    }

    func buildToc(root: Node): Node {
        let collector = HeadTextCollector()
        let builder = StringBuilder()

        let head0 = HeadTree(Heading(), "0", -1)
        var tree = head0
        var tmp: ?Node = root.getFirstChild()
        var index = -1
        while (let Some(v) <- tmp) {
            index++
            tmp = v.getNext()
            if (let Some(head) <- (v as Heading)) {
                head.accept(collector)
                let headText = collector.reset()
                let current = HeadTree(head, headText, index)
                let lastLevel = tree.head.getLevel()
                let thisLevel = head.getLevel()
                if (thisLevel > lastLevel) {
                    tree.appendChildTree(current)
                } else if (lastLevel == thisLevel) {
                    tree.insertAfterTree(current)
                } else if (thisLevel < lastLevel) {
                    while (let Some(v: HeadTree) <- tree.getParent()) {
                        if (thisLevel > v.head.getLevel()) {
                            v.appendChildTree(current)
                            break
                        }
                        tree = v
                    }
                }
                tree = current
            }
        }

        return head0.item_list
    }
}

class HeadTextCollector <: AbstractVisitor {
    let text = StringBuilder()
    public func visit(node: Text): Unit {
        text.append(node.getLiteral())
    }
    public func visit(node: Code): Unit {
        text.append(node.getLiteral())
    }
    func reset(): String {
        let str = text.toString()
        text.reset()
        return str
    }
}

public class HeadLink <: Link {
    static let typeInfo = "HeadLink"
    public let headIndex: Int
    init(headIndex: Int, dest: String, title: ?String) {
        super("#${dest}", title)
        this.headIndex = headIndex
    }

    protected func toStringAttributes(): String {
        return "headIndex=${headIndex},destination=${getDestination()},title=${getTitle()}"
    }

    public func getNodeType(): String {
        return typeInfo
    }
}

class HeadTree <: CustomNode {
    let item: ListItem = ListItem()
    let item_p = Paragraph()
    let item_list = OrderedList(1, r'.')
    HeadTree(let head: Heading, let text: String, let headIndex: Int) {
        let link = HeadLink(headIndex, text, text)
        item_p.appendChild(link)
        item.appendChild(item_p)
        item.appendChild(item_list)
    }
    func appendChildTree(n: HeadTree): Unit {
        item_list.appendChild(n.item)
        appendChild(n)
    }
    func insertAfterTree(n: HeadTree): Unit {
        item.insertAfter(n.item)
        insertAfter(n)
    }
    public func getNodeType(): String {
        "HeadTree"
    }
}

func deepClone(node: Node): Node {
    let clone: Node = match (node) {
        case v: OrderedList => OrderedList(v.getStartNumber(), v.getDelimiter())
        case v: ListItem => ListItem()
        case v: Paragraph => Paragraph()
        case v: HeadLink => HeadLink(v.headIndex, v.getDestination(), v.getTitle())
        case _ => throw Exception("unsupport")
    }
    for (n in node.iterateChildren()) {
        clone.appendChild(deepClone(n))
    }
    return clone
}
