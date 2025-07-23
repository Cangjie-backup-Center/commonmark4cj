/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */
package markdown.plugin

class MarkdownHtmlRendererNoOp <: MarkdownHtmlRenderer {
    init() {
        super()
    }

    public override func render(_: ?MarkdownVisitor, _: MarkdownHtmlParser, _: HtmlTag): Node {
        let ignoreNode: IgnoreNode = IgnoreNode()
        return ignoreNode
    }

    public override func tagHandler(_: String): ?TagHandler {
        return None
    }
}
