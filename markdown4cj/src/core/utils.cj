/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */
package markdown.core

public abstract class ParserUtils {
    public static func moveChildren(to: Node, froms: Node): Unit {
        var next: ?Node = froms.getNext()
        var temp: ?Node
        while (let Some(n) <- next) {
            // appendChild would unlink passed node (thus making next info un-available)
            temp = n.getNext()
            to.appendChild(n)
            next = temp
        }
    }
}
