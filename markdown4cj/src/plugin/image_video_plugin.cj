/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2025-2025. All rights reserved.
 */
package markdown.plugin

/**
 * 图片视频
 */
public class ImageVideoPlugin <: AbstractMarkdownPlugin {
    public static func create(): ImageVideoPlugin {
        return ImageVideoPlugin()
    }

    public func configureParser(builder: ParserBuilder): Unit {
        builder.postProcessor(ImageVideoPostProcessor())
    }

    public func configureVisitor(_: MarkdownVisitorBuilder): Unit {}

    public func getClassType(): String {
        "ImageVideoPlugin"
    }
}

class ImageVideoPostProcessor <: PostProcessor {
    public func process(node: Node): Node {
        node.accept(ImageVideoVisitor())
        return node
    }
}

class ImageVideoVisitor <: AbstractVisitor {
    public func visit(img: Image): Unit {
        if (ImgVideo.isImgVideo(img.getDestination())) {
            let text = if (let Some(v: Text) <- img.getFirstChild()) {
                v.getLiteral()
            } else {
                ""
            }
            let imgvideo = ImgVideo(text, img.getDestination(), img.getTitle())
            img.replaceWith(imgvideo)
        }
    }
}
