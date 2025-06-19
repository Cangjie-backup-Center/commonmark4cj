/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2025-2025. All rights reserved.
 */
package markdown.plugin

/**
 * 图片style
 */
public class ImageStylePlugin <: AbstractMarkdownPlugin {
    public static func create(): ImageStylePlugin {
        return ImageStylePlugin()
    }

    public func configureParser(builder: ParserBuilder): Unit {
        builder.customDelimiterProcessor(StyleDelimiterProcessor())
    }

    public func configureVisitor(_: MarkdownVisitorBuilder): Unit {}

    public func getClassType(): String {
        "ImageStylePlugin"
    }
}
