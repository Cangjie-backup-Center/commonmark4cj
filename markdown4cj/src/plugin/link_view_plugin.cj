/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2025-2025. All rights reserved.
 */
package markdown.plugin

/**
 * Link作为单独NodeView节点
 */
public class LinkViewPlugin <: AbstractMarkdownPlugin {
    public static func create(): LinkViewPlugin {
        return LinkViewPlugin()
    }

    public func configureVisitor(builder: MarkdownVisitorBuilder): Unit {
        builder.on(
            "Link",
            {
                visitor, node =>
                buildView(node, true)
                visitor.visitChildren(node)
            }
        )
    }

    public func getClassType(): String {
        "LinkViewPlugin"
    }
}
