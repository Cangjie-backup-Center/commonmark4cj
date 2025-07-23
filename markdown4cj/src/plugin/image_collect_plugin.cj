/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2025. All rights reserved.
 */
package markdown.plugin

public class ImageCollectPlugin <: AbstractMarkdownPlugin {
    public func getClassType(): String {
        "ImageCollectPlugin"
    }

    public override func afterRender(doc: Node, _: MarkdownVisitor): Unit {
        let docview = doc.getView()
        let props = docview.props ?? {
            =>
            let m = HashMap<String, Any>()
            docview.props = m
            m
        }()
        let visitor = ImageCollectVisitor()
        doc.accept(visitor)
        props.add("links", visitor.links)
    }
}

class ImageCollectVisitor <: AbstractVisitor {
    let links = ArrayList<String>()
    public func visit(n: Image): Unit {
        links.add(n.getDestination())
    }
    public func visit(b: CustomBlock): Unit {
        if (b is BlockAudio) {
            return
        }
        visitChildren(b)
    }
}
