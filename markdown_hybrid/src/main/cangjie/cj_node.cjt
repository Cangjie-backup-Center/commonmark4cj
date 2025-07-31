/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2025-2025. All rights reserved.
 */
package markdown_hybrid

import ohos.ark_interop_macro.*

@Interop[ArkTS]
public class CjNode {
    @Interop[ArkTS, Invisible]
    init(instance: MdNode) {
        this.nodeType = instance.getNodeType()
        this.toStr = instance.toString()
        match (instance) {
            case v: MdText => this.literal = v.getLiteral()
            case v: MdHtmlInline => this.literal = v.getLiteral()
            case v: MdImage =>
                this.destination = v.getDestination()
                this.title = v.getTitle()
            case v: MdCode => this.literal = v.getLiteral()
            case v: MdLinkReferenceDefinition =>
                this.label = v.getLabel()
                this.destination = v.getDestination()
                this.title = v.getTitle()
            case v: MdLink =>
                this.destination = v.getDestination()
                this.title = v.getTitle()
            case v: MdStrongEmphasis => this.delimiter = v.getOpeningDelimiter()
            case v: MdEmphasis => this.delimiter = v.getOpeningDelimiter()
            case v: MdHtmlBlock => this.literal = v.getLiteral()
            case v: MdIndentedCodeBlock => this.literal = v.getLiteral()
            case v: MdFencedCodeBlock =>
                this.fenceChar = v.getFenceChar().toString()
                this.fenceLength = v.getFenceLength()
                this.fenceIndent = v.getFenceIndent()
                this.info = v.getInfo()
                this.literal = v.getLiteral()
            case v: MdHeading => this.level = v.getLevel()
            case v: MdBulletList =>
                this.tight = v.isTight()
                this.bulletMarker = v.getBulletMarker().toString()
            case v: MdOrderedList =>
                this.tight = v.isTight()
                this.startNumber = v.getStartNumber()
                this.delimiter = v.getDelimiter().toString()
            case v: TableCell =>
                this.header = v.isHeader()
                this.alignment = v.getAlignment()?.toString()
            case _ => ()
        }
    }
    public init() {
    }

    /* node info */
    var nodeType: String = ""
    var toStr: String = ""
    /* node tree */
    var parent: ?CjNode = None
    var firstChild: ?CjNode = None
    var lastChild: ?CjNode = None
    var prev: ?CjNode = None
    var next: ?CjNode = None
    /* node attr */
    var literal: ?String = None
    var destination: ?String = None
    var title: ?String = None
    var label: ?String = None
    var delimiter: ?String = None
    var fenceChar: ?String = None
    var fenceLength: ?Int64 = None
    var fenceIndent: ?Int64 = None
    var level: ?Int64 = None
    var bulletMarker: ?String = None
    var startNumber: ?Int64 = None
    var info: ?String = None
    var tight: ?Bool = None
    var header: ?Bool = None
    var alignment: ?String = None

    public func getNext(): Option<CjNode> {
        return next
    }

    public func getPrevious(): Option<CjNode> {
        return prev
    }

    public func getFirstChild(): Option<CjNode> {
        return firstChild
    }

    public func getLastChild(): Option<CjNode> {
        return lastChild
    }

    public func getParent(): Option<CjNode> {
        return parent
    }

    protected func setParent(parent: Option<CjNode>): Unit {
        this.parent = parent
    }

    protected func setPrevious(prev: Option<CjNode>): Unit {
        this.prev = prev
    }

    protected func setNext(next: Option<CjNode>): Unit {
        this.next = next
    }

    protected func setFirstChild(firstChild: Option<CjNode>): Unit {
        this.firstChild = firstChild
    }

    protected func setLastChild(lastChild: Option<CjNode>): Unit {
        this.lastChild = lastChild
    }

    public func appendChild(child: CjNode): Unit {
        child.unlink()
        child.setParent(this)
        if (this.lastChild.isSome()) {
            this.lastChild.getOrThrow().next = child
            child.prev = this.lastChild
            this.lastChild = child
        } else {
            this.firstChild = child
            this.lastChild = child
        }
    }

    public func prependChild(child: CjNode): Unit {
        child.unlink()
        child.setParent(this)
        if (this.firstChild.isSome()) {
            this.firstChild.getOrThrow().prev = child
            child.next = this.firstChild
            this.firstChild = child
        } else {
            this.firstChild = child
            this.lastChild = child
        }
    }

    public func unlink(): Unit {
        if (this.prev.isSome()) {
            this.prev.getOrThrow().next = this.next
        } else if (this.parent.isSome()) {
            this.parent.getOrThrow().firstChild = this.next
        }
        if (this.next.isSome()) {
            this.next.getOrThrow().prev = this.prev
        } else if (this.parent.isSome()) {
            this.parent.getOrThrow().lastChild = this.prev
        }
        this.parent = Option<CjNode>.None
        this.next = Option<CjNode>.None
        this.prev = Option<CjNode>.None
    }

    public func insertAfter(sibling: CjNode): Unit {
        sibling.unlink()
        sibling.next = this.next
        if (sibling.next.isSome()) {
            sibling.next.getOrThrow().prev = sibling
        }
        sibling.prev = this
        this.next = sibling
        sibling.parent = this.parent
        if (sibling.next.isNone()) {
            sibling.parent.getOrThrow().lastChild = sibling
        }
    }

    public func insertBefore(sibling: CjNode): Unit {
        sibling.unlink()
        sibling.prev = this.prev
        if (sibling.prev.isSome()) {
            sibling.prev.getOrThrow().next = sibling
        }
        sibling.next = this
        this.prev = sibling
        sibling.parent = this.parent
        if (sibling.prev.isNone()) {
            sibling.parent.getOrThrow().firstChild = sibling
        }
    }

    public func toString(): String {
        return toStr
    }

    public func getNodeType(): String {
        nodeType
    }

    public func getLiteral(): Option<String> {
        return literal
    }
    public func getDestination(): Option<String> {
        return destination
    }
    public func getTitle(): Option<String> {
        return title
    }
    public func getLabel(): Option<String> {
        return label
    }
    public func getOpeningDelimiter(): Option<String> {
        return delimiter
    }
    public func getClosingDelimiter(): Option<String> {
        return delimiter
    }
    public func getFenceChar(): Option<String> {
        return fenceChar
    }
    public func getFenceLength(): Option<Int64> {
        return fenceLength
    }
    public func getFenceIndent(): Option<Int64> {
        return fenceIndent
    }
    public func getInfo(): Option<String> {
        return info
    }
    public func isTight(): Option<Bool> {
        return tight
    }
    public func getBulletMarker(): Option<String> {
        return bulletMarker
    }
    public func getStartNumber(): Option<Int64> {
        return startNumber
    }
    public func getDelimiter(): Option<String> {
        return delimiter
    }
}


@Interop[ArkTS]
public func printNode(node: Option<CjNode>): Unit {
    if (let Some(v) <- node) {
        var current = v
        while (let Some(p) <- (current.getParent())) {
            current = p
        }
        let builder = StringBuilder()
        printNode(current, 0, builder)
        Hilog.error(0, 'md', builder.toString())
    }
}

public func printNode(node: ?CjNode, dep: Int, builder: StringBuilder): Unit {
    if (let Some(v) <- node) {
        let str = v.toString()
        builder.append("${" "*dep}${str}\n")
        let child = v.getFirstChild()
        printNode(child, dep + 4, builder)
        let next = v.getNext()
        printNode(next, dep, builder)
    }
}