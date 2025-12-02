/**
 * Created on 002 25/12/2
 */
package commonmark_hybrid
import ohos.hilog.Hilog

public func printNode(node: ?Node): Unit {
    if (let Some(v) <- node) {
        var current = v
        while (let Some(p) <- (current.getParent())) {
            current = p
        }
        let builder = StringBuilder()
        printNode(current, 0, builder)
        Hilog.error(0, '', builder.toString())
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

public func printNode(list: NodeView): Unit {
    let builder = StringBuilder()
    printNode(list, 0, builder)
    Hilog.error(0, '', builder.toString())
}

public func printNode(list: NodeView, dep: Int, builder: StringBuilder): Unit {
    builder.append("${"    "*dep}${list}\n")
    for (block in list.children) {
        printNode(block, dep + 1, builder)
    }
}