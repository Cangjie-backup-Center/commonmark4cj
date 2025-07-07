/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */
package markdown.plugin

public class LinkifyPlugin <: AbstractMarkdownPlugin {
    static let urlreg = Regex(#"https?://\S+"#)
    public static func create(): LinkifyPlugin {
        return LinkifyPlugin()
    }

    public func configureVisitor(builder: MarkdownVisitorBuilder): Unit {
        builder.on(
            "Text",
            {
                visitor, node =>
                if (let Some(_: Link) <- node.getParent()) {
                    buildView(node, true)
                    return
                }

                let originTextNode = (node as Text)()
                let fulltext = originTextNode.getLiteral()
                let matcher = urlreg.matcher(fulltext)

                if (let Some(arr) <- matcher.findAll()) {
                    var i = 0
                    for (data in arr) {
                        if (i < data.matchPosition().start) {
                            let snippet = fulltext[i..data.matchPosition().start]
                            if (snippet.size > 0) {
                                let text = Text(snippet)
                                originTextNode.insertBefore(text)
                                buildView(text, true)
                            }
                        }
                        i = data.matchPosition().end
                        if (i <= fulltext.size) {
                            let snippet = data.matchString()
                            let link = Link(snippet, snippet)
                            link.appendChild(Text(snippet))
                            if (i == fulltext.size) {
                                originTextNode.replaceWith(link)
                            } else {
                                originTextNode.insertBefore(link)
                            }
                            visitor.visit(link)
                        } else {
                            let snippet = fulltext[i..]
                            if (snippet.size > 0) {
                                originTextNode.setLiteral(snippet)
                                buildView(originTextNode, true)
                            }
                        }
                    }
                } else {
                    buildView(node, true)
                }
            }
        )
    }

    public func getClassType(): String {
        "LinkifyPlugin"
    }
}
