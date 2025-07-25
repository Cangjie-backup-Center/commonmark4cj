/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2025-2025. All rights reserved.
 */
package markdown_hybrid

func calcNodeTreeId(n: MdNode): String {
    let id = StringBuilder()
    visitNode(n.getFirstChild(), id)
    return id.toString()
}

func visitNode(node: ?MdNode, id: StringBuilder): Unit {
    let current = node ?? return
    let next = current.getNext()
    let currentId = caclNodeId(current)
    id.append(currentId)
    visitNode(current.getFirstChild(), id)
    visitNode(next, id)
}

func caclNodeId(instance: MdNode): StringBuilder {
    let nodeid = StringBuilder()
    nodeid.set('nodeType', instance.getNodeType())
    nodeid.set('toStr', instance.toString())
    match (instance) {
        case v: JsInlineNode => nodeid.set('props', v.props)
        case v: TaskListItem => nodeid.set('isdone', v.isDone())
        case v: LatexMathBlock =>
            nodeid.set('latex', v.latex)
            nodeid.set('isClosed', v.isClosed)
        case v: LatexMathNode => nodeid.set('latex', v.latex)
        case v: Footnote =>
            nodeid.set('noteid', v.noteid)
            nodeid.set('blockIndex', v.block?.blockIndex ?? -1)
        case v: FootnoteBlock =>
            nodeid.set('noteid', v.noteid)
            nodeid.set('blockIndex', v.blockIndex)
        case v: HeadLink => nodeid.set('headIndex', v.headIndex)
        case v: MdText => nodeid.set('literal', v.getLiteral())
        case v: MdHtmlInline => nodeid.set('literal', v.getLiteral())
        case v: MdImage =>
            nodeid.set('destination', v.getDestination())
            nodeid.set('title', v.getTitle())
        case v: MdCode => nodeid.set('literal', v.getLiteral())
        case v: MdLinkReferenceDefinition =>
            nodeid.set('label', v.getLabel())
            nodeid.set('destination', v.getDestination())
            nodeid.set('title', v.getTitle())
        case v: MdLink =>
            nodeid.set('destination', v.getDestination())
            nodeid.set('title', v.getTitle())
        case v: MdStrongEmphasis => nodeid.set('delimiter', v.getOpeningDelimiter())
        case v: MdEmphasis => nodeid.set('delimiter', v.getOpeningDelimiter())
        case v: MdHtmlBlock => nodeid.set('literal', v.getLiteral())
        case v: MdIndentedCodeBlock => nodeid.set('literal', v.getLiteral())
        case v: MdFencedCodeBlock =>
            nodeid.set('fenceChar', v.getFenceChar())
            nodeid.set('fenceLength', v.getFenceLength())
            nodeid.set('fenceIndent', v.getFenceIndent())
            nodeid.set('info', v.getInfo())
            nodeid.set('literal', v.getLiteral())
        case v: MdHeading => nodeid.set('level', v.getLevel())
        case v: MdBulletList =>
            nodeid.set('tight', v.isTight())
            nodeid.set('bulletMarker', v.getBulletMarker())
        case v: MdOrderedList =>
            nodeid.set('tight', v.isTight())
            nodeid.set('startNumber', v.getStartNumber())
            nodeid.set('delimiter', v.getDelimiter())
        case v: TableCell =>
            nodeid.set('header', v.isHeader())
            nodeid.set('alignment', v.getAlignment()?.toString())
        case _ => ()
    }
    nodeid
}

extend StringBuilder {
    func set(k: String, v: ToString): Unit {
        this.append(k)
        this.append(v)
    }
}
