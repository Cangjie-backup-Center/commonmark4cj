/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */
package markdown.plugin

public class CodeListPlugin <: AbstractMarkdownPlugin {
    public static func create(): CodeListPlugin {
        return CodeListPlugin()
    }

    public func configureParser(builder: ParserBuilder): Unit {
        builder.postProcessor(CodePostProcessor())
    }

    public func configureVisitor(builder: MarkdownVisitorBuilder): Unit {
        builder.on(
            "FencedCodeBlockListBlock",
            {
                visitor, node =>
                buildView(node, true)
                visitor.visitChildren(node)
            }
        )
    }

    public func getClassType(): String {
        "CodeListPlugin"
    }
}

class CodePostProcessor <: PostProcessor {
    let visitor = CodeListVisitor()
    public func process(node: Node): Node {
        node.accept(visitor)
        return node
    }
}

class CodeListVisitor <: AbstractVisitor {
    public func visit(node: Document): Unit {
        process(node)
        visitChildren(node)
    }
    public func visit(node: ListItem): Unit {
        process(node)
        visitChildren(node)
    }
    public func visit(node: BlockQuote): Unit {
        process(node)
        visitChildren(node)
    }
    func process(node: Node): Unit {
        var codeList: ?FencedCodeBlockListBlock = None
        var codeListName: String = ""
        var block: ?Node = node.getFirstChild()
        while (let Some(b) <- block) {
            block = b.getNext()
            match (b) {
                case code: FencedCodeBlock =>
                    let (isCodeList, lang, listName, tabName) = matches(code.getInfo())
                    if (!isCodeList) {
                        codeList = None
                        continue
                    }
                    let list = match (codeList) {
                        case Some(v) where v.name == listName => v
                        case _ =>
                            let v = FencedCodeBlockListBlock(listName)
                            code.insertBefore(v)
                            codeList = v
                            v
                    }
                    code.setInfo(lang)
                    code.unlink()
                    list.tabs.add(tabName)
                    list.appendChild(code)
                case _ => codeList = None
            }
        }
    }

    /*
     * @return (isCodeList, Lang, ListName, TabName)
     */
    private static func matches(info: String): (Bool, String, String, String) {
        let a = if (let Some(v) <- info.indexOf('[')) {
            v
        } else {
            return (false, info, "", "")
        }
        let b = if (let Some(v) <- info.lastIndexOf(']')) {
            v
        } else {
            return (false, info, "", "")
        }
        if (a > b) {
            return (false, info, "", "")
        }

        let lang = info[..a].trimAscii()
        let listInfo = info[a + 1..b]

        return if (let Some(c) <- listInfo.indexOf('-')) {
            let tabname = if (c + 1 < listInfo.size) {
                listInfo[c + 1..]
            } else {
                lang
            }
            (true, lang, listInfo[..c], tabname)
        } else {
            (true, lang, listInfo.trimAscii(), lang)
        }
    }
}

public class FencedCodeBlockListBlock <: CustomBlock {
    public let tabs: ArrayList<String> = ArrayList<String>()
    FencedCodeBlockListBlock(let name: String) {}
    protected func toStringAttributes(): String {
        return "name:${name}, tabs=${tabs}"
    }
    public func getNodeType(): String {
        "FencedCodeBlockListBlock"
    }
}
