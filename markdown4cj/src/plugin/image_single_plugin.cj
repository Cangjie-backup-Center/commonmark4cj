/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2025-2025. All rights reserved.
 */
package markdown.plugin

/**
 * 单独的图片提到block级别
 */
public class ImageSinglePlugin <: AbstractMarkdownPlugin {
    public static func create(): ImageSinglePlugin {
        return ImageSinglePlugin()
    }

    public func configureParser(builder: ParserBuilder): Unit {
        builder.postProcessor(ImageSinglePostProcessor())
    }

    public func configureVisitor(_: MarkdownVisitorBuilder): Unit {}

    public func getClassType(): String {
        "ImageSinglePlugin"
    }
}

class ImageSinglePostProcessor <: PostProcessor {
    public func process(node: Node): Node {
        node.accept(ImageSingleVisitor())
        return node
    }
}

class ImageSingleVisitor <: AbstractVisitor {
    private let collector = ArrayList<Node>()
    public func visit(p: Paragraph): Unit {
        // 单独的图片提到block级别
        match ((p.getFirstChild(), p.getLastChild())) {
            case (Some(a: Image), Some(b: Image)) where refEq(a, b) =>
                p.replaceWith(a)
                return
            case _ => ()
        }
    }
}
