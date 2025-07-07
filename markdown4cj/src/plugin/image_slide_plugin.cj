/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2025-2025. All rights reserved.
 */
package markdown.plugin

/**
 * 图片幻灯片
 */
public class ImageSlidePlugin <: AbstractMarkdownPlugin {
    public static func create(): ImageSlidePlugin {
        return ImageSlidePlugin()
    }

    public func configureParser(builder: ParserBuilder): Unit {
        builder.postProcessor(ImageSlidePostProcessor())
    }

    public func configureVisitor(builder: MarkdownVisitorBuilder): Unit {
        builder
            .on(
                "SlideBlock",
                {
                    visitor, slide =>
                    buildView(slide, true)
                    visitor.visitChildren(slide)
                }
            )
    }

    public func getClassType(): String {
        "ImageSlidePlugin"
    }
}

class ImageSlidePostProcessor <: PostProcessor {
    public func process(node: Node): Node {
        node.accept(ImageSlideVisitor())
        return node
    }
}

class ImageSlideVisitor <: AbstractVisitor {
    private let collector = ArrayList<Node>()
    public func visit(p: Paragraph): Unit {
        var node: ?Node = match (p.getFirstChild()) {
            case Some(t: Text) where t.getLiteral() == "<" => match (t.getNext()) {
                case Some(_: SoftLineBreak) => return // 如果<后换行 不支持
                case Some(v) => v
                case _ => return
            }
            case _ => return
        }
        let end = match (p.getLastChild()) {
            case Some(t: Text) where t.getLiteral() == ">" => t
            case _ => return
        }

        collector.clear()
        var wantImg = true
        while (let Some(n) <- node) {
            if (n == end) {
                if (wantImg) {
                    return // 如果是逗号结尾 不支持
                } else {
                    break
                }
            }
            node = n.getNext()
            if (n is SoftLineBreak) {
                continue
            }
            if (wantImg) {
                // Image node
                if (n is Image) {
                    collector.add(n)
                    wantImg = !wantImg
                } else {
                    return
                }
            } else {
                // Text{,} node
                match (n) {
                    case t: Text where t.getLiteral().trimAscii() == "," => wantImg = !wantImg
                    case _ => return
                }
            }
        }

        let slide = SlideBlock()
        for (n in collector) {
            slide.appendChild(n)
        }
        p.insertBefore(slide)
        p.unlink()
    }
}
