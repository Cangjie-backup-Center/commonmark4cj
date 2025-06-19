/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */
package markdown.plugin

public class ImagePlugin <: AbstractMarkdownPlugin {
    public static func create(): ImagePlugin {
        return ImagePlugin()
    }

    public func configureParser(builder: ParserBuilder): Unit {
        builder.customDelimiterProcessor(StyleDelimiterProcessor())
        builder.postProcessor(ImagePostProcessor())
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
            .on(
                "Style",
                {
                    visitor, style => buildView(style, true)
                }
            )
    }

    public func getClassType(): String {
        "ImagePlugin"
    }
}

class Style <: CustomNode {
    Style(let style: String) {}
    public func getNodeType(): String {
        "Style"
    }
    protected func toStringAttributes(): String {
        return "style=${style}"
    }
}

class StyleDelimiterProcessor <: DelimiterProcessor {
    public func getOpeningCharacter(): Rune {
        return r'{'
    }
    public func getClosingCharacter(): Rune {
        return r'}'
    }
    public func getMinLength(): Int {
        return 1
    }
    public func getDelimiterUse(_: DelimiterRun, _: DelimiterRun): Int {
        return 1
    }
    let reg = Regex("^:(style|align|width|height|border-radius)=")
    public func process(opener: Text, closer: Text, _: Int): Unit {
        if (!process(opener, closer)) {
            if (let Some(n: Text) <- opener.getNext()) {
                n.setLiteral("{" + n.getLiteral())
            }
            if (let Some(p: Text) <- closer.getPrevious()) {
                p.setLiteral(p.getLiteral() + "}")
            }
        }
    }

    /*
     * 处理style
     * @return true 合法的style转换为Style节点
     *        false 非法的style降级为Text节点
     */
    func process(opener: Text, closer: Text): Bool {
        // 处理style
        if (let Some(style: Text) <- opener.getNext()) {
            if (style.getNext() != closer) {
                return false
            }
            let str = style.getLiteral()
            if (reg.matcher(str).find().isSome()) {
                // 处理style前的Image
                if (let Some(image: Image) <- opener.getPrevious()) {
                    match (image) {
                        case v: StyleImage => v.styles.append(str)
                        case _ =>
                            let styleImage = StyleImage(str, image)
                            image.replaceWith(styleImage)
                    }
                }

                style.unlink()
                return true
            }
        }
        return false
    }
}

class ImageDelimiterVisitor <: AbstractVisitor {
    public func visit(p: Paragraph): Unit {
        visitChildren(p)
        let node = match (p.getFirstChild()) {
            case Some(t: Text) where t.getLiteral() == "<" => t.getNext()
            case _ => return
        }
    }
}

class ImagePostProcessor <: PostProcessor {
    public func process(node: Node): Node {
        node.accept(ImageVisitor())
        return node
    }
}

class ImageVisitor <: AbstractVisitor {
    private let collector = ArrayList<Node>()
    public func visit(p: Paragraph): Unit {
        // 单独的图片提到block级别
        match ((p.getFirstChild(), p.getLastChild())) {
            case (Some(a: Image), Some(b: Image)) where refEq(a, b) =>
                p.replaceWith(a)
                return
            case _ => ()
        }

        // for ImageVideo
        visitChildren(p)

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
                    collector.append(n)
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

public class SlideBlock <: CustomBlock {
    public func getNodeType(): String {
        "SlideBlock"
    }
}

public class StyleImage <: Image {
    static let typeInfo = "StyleImage"
    public let styles: ArrayList<String> = ArrayList<String>()
    init(style: String, img: Image) {
        super(img.getDestination(), img.getTitle())
        this.styles.append(style)
    }
    protected func toStringAttributes(): String {
        return "${super.toStringAttributes()}, styles=${styles}"
    }
    public func getNodeType(): String {
        typeInfo
    }
}

public class ImgVideo <: Image {
    public var text: String
    init(text: String, dest: String, title: ?String) {
        super(dest, title)
        this.text = text
    }
    protected func toStringAttributes(): String {
        return "text=${text},dest=${getDestination()},title=${getTitle()}"
    }
    public func getNodeType(): String {
        typeinfo
    }
    static let typeinfo = "ImgVideo"
    static let reg = Regex("[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}")
    static func isImgVideo(dest: String): Bool {
        reg.matches(dest).isSome()
    }
}
