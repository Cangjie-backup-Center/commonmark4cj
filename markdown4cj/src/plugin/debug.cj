/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2025. All rights reserved.
 */
package markdown.plugin

/* public class Debuger {
    static var _logger: ?Logger = None
    mut static prop logger: Logger {
        get() {
            _logger ?? {
                =>
                let logger = getGlobalLogger([("name", "main")])
                _logger = logger
                logger
            }()
        }
        set(v) {
            _logger = v
        }
    }
} */
public func printTag(tag: HtmlTag): Unit {
    let appender = StringBuilder()
    var root: HtmlTag = tag
    while (let Some(p) <- root.parentTag) {
        root = p
    }
    printTag(root, 0, appender)
    println(appender)
}

public func printTag(tag: HtmlTag, dep: Int, appender: StringBuilder): Unit {
    appender.append("${" "*dep}${tag} ${tag.isClosed()}\n")
    for (child in tag.getChildren()) {
        printTag(child, dep + 1, appender)
    }
}

public func printNode(node: ?Node): Unit {
    if (let Some(v) <- node) {
        var current = v
        while (let Some(p) <- (current.getParent())) {
            current = p
        }
        let builder = StringBuilder()
        printNode(current, 0, builder)
        println(builder)
    }
}

public func printNode(node: ?Node, dep: Int, builder: StringBuilder): Unit {
    if (let Some(v) <- node) {
        let str = if (v.custom is NodeView) {
            v.toViewString()
        } else {
            v.toString()
        }.replace("\n", "\\n")
        builder.append("${" "*dep}${str}\n")
        let child = v.getFirstChild()
        printNode(child, dep + 4, builder)
        let next = v.getNext()
        printNode(next, dep, builder)
    }
}
