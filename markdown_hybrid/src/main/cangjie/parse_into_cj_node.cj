/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */
package markdown_hybrid

import ohos.ark_interop_macro.*

func buildNode(n: MdNode): CjNode {
    let nodeProxy = CjNode(n)
    visitNode(n.getFirstChild(), nodeProxy)
    nodeProxy
}

func visitNode(node: ?MdNode, parentProxy: CjNode): Unit {
    let current = node ?? return
    let next = current.getNext()
    let currentProxy = CjNode(current)
    parentProxy.appendChild(currentProxy)
    visitNode(current.getFirstChild(), currentProxy)
    visitNode(next, parentProxy)
}

@Interop[ArkTS, Async]
public func parseIntoCjNode(md: String): CjNode {
    let doc: MdNode = PARSER.parse(md)
    buildNode(doc)
}
