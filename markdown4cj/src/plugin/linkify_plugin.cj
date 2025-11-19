/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */
package markdown.plugin

import ohos.hilog.Hilog

public class LinkifyPlugin <: AbstractMarkdownPlugin {
    public static func create(): LinkifyPlugin {
        return LinkifyPlugin()
    }

    public func configureParser(parser: ParserBuilder): Unit {
        parser.postProcessor(LinkifyPostProcessor())
    }

    public func getClassType(): String {
        "LinkifyPlugin"
    }
}

class LinkifyPostProcessor <: PostProcessor {
    public func process(node: Node): Node {
        let visitor = LinkifyVisitor()
        node.accept(visitor)
        return node
    }
}

class LinkifyVisitor <: AbstractVisitor {
    static let urlreg = Regex(#"https?://[!*'();:@&=+$,/?#[\]a-zA-Z0-9-_.~]+"#)
    public func visit(node: Text): Unit {
        if (let Some(_: Link) <- node.getParent()) {
            buildView(node, true)
            return
        }

        let originTextNode = (node as Text)()
        let fulltext = originTextNode.getLiteral()
        var i = 0
        for (data in urlreg.lazyFindAll(fulltext)) {
            if (i < data.matchPosition().start) {
                let snippet = fulltext[i..data.matchPosition().start]
                if (snippet.size > 0) {
                    let text = Text(snippet)
                    originTextNode.insertBefore(text)
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
            } else {
                let snippet = fulltext[i..]
                if (snippet.size > 0) {
                    originTextNode.setLiteral(snippet)
                }
            }
        }
    }
}
