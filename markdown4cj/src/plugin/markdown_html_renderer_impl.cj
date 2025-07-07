/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */
package markdown.plugin

class MarkdownHtmlRendererImpl <: MarkdownHtmlRenderer {
    private let allowNonClosedTags: Bool

    private let tagHandlers: Map<String, TagHandler>

    init(allowNonClosedTags: Bool, tagHandlers: Map<String, TagHandler>) {
        super()
        this.allowNonClosedTags = allowNonClosedTags
        this.tagHandlers = tagHandlers
    }

    public override func render(visitor: ?MarkdownVisitor, _: MarkdownHtmlParser, tag: HtmlTag): Node {
        let node = TagHandler.visit(visitor, this, tag, None)
        return node
    }

    public override func tagHandler(tagName: String): ?TagHandler {
        return tagHandlers.get(tagName)
    }
}

public class MarkdownHtmlRendererImplBuilder {
    init() {}

    private let tagHandlers: Map<String, TagHandler> = HashMap<String, TagHandler>()

    private var allowNonClosedTags: Bool = false

    private var excludeDefaults: Bool = false

    private var isBuilt: Bool = false

    public func allowNonClosedTagsMethod(allowNonClosedTags: Bool): Unit {
        checkState()
        this.allowNonClosedTags = allowNonClosedTags
    }

    public func addHandler(tagHandler: TagHandler): Unit {
        checkState()
        for (tag in tagHandler.supportedTags()) {
            tagHandlers.add(tag, tagHandler)
        }
    }

    public func getHandler(tagName: String): ?TagHandler {
        checkState()
        return tagHandlers.get(tagName)
    }

    public func excludeDefaultsMethod(excludeDefaults: Bool): Unit {
        checkState()
        this.excludeDefaults = excludeDefaults
    }

    public func excludeDefaultsMethod(): Bool {
        return excludeDefaults
    }

    public func build(): MarkdownHtmlRenderer {
        checkState()
        isBuilt = true
        return if (tagHandlers.size > 0) {
            MarkdownHtmlRendererImpl(allowNonClosedTags, tagHandlers)
        } else {
            MarkdownHtmlRendererNoOp()
        }
    }

    private func checkState(): Unit {
        if (isBuilt) {
            throw IllegalStateException("Builder has been already built")
        }
    }

    public func addDefaultTagHandler(tagHandler: TagHandler): Unit {
        for (tag in tagHandler.supportedTags()) {
            if (!tagHandlers.contains(tag)) {
                tagHandlers.add(tag, tagHandler)
            }
        }
    }
}
