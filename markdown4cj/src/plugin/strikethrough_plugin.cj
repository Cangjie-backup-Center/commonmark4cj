/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */
package markdown.plugin

/**
 * Plugin to add strikethrough markdown feature.
 * This plugin will extend commonmark.Parser with strikethrough extension,
 * add SpanFactory and register commonmark.Strikethrough node visitor
 */
public class StrikethroughPlugin <: AbstractMarkdownPlugin {
    public static func create(): StrikethroughPlugin {
        return StrikethroughPlugin()
    }

    public func configureParser(builder: ParserBuilder): Unit {
        builder.extensions([StrikethroughExtension.create()])
    }

    public func configureVisitor(builder: MarkdownVisitorBuilder): Unit {
        builder.on(
            "Strikethrough",
            {
                visitor, strikethrough =>
                let view = buildView(strikethrough, false, needProps: true)
                view.props?.add("strikethrough", true)
                visitor.visitChildren(strikethrough)
                strikethrough.flat()
            }
        )
    }

    public func getClassType(): String {
        "StrikethroughPlugin"
    }
}
