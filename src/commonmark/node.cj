package commonmark

public abstract class Node <: ToString & Equatable<Node> {
    private var parent: ?Node = None
    private var firstChild: ?Node = None
    private var lastChild: ?Node = None
    private var prev: ?Node = None
    private var next: ?Node = None

    public open func accept(visitor: Visitor): Unit

    public func getNext(): ?Node {
        return next
    }

    public func getPrevious(): ?Node {
        return prev
    }

    public func getFirstChild(): ?Node {
        return firstChild
    }

    public func getLastChild(): ?Node {
        return lastChild
    }

    public open func getParent(): ?Node {
        return parent
    }

    protected open func setParent(parent: Node): Unit {
        this.parent = parent
    }

    public func appendChild(child: Node): Unit {
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

    public func prependChild(child: Node): Unit {
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
        this.parent = Option<Node>.None
        this.next = Option<Node>.None
        this.prev = Option<Node>.None
    }

    public func insertAfter(sibling: Node): Unit {
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

    public func insertBefore(sibling: Node): Unit {
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

    public open func toString(): String {
        return TypeInfo.of(this).name + "{" + toStringAttributes() + "}"
    }

    protected open func toStringAttributes(): String {
        return ""
    }

    public operator func ==(other: Node): Bool {
        return refEq(this, other)
    }

    public operator func !=(other: Node): Bool {
        return !refEq(this, other)
    }
}

public class Text <: Node {
    private var literal: String

    public init(literal: String) {
        this.literal = literal
    }

    public override func accept(visitor: Visitor): Unit {
        visitor.visit(this)
    }

    public func getLiteral(): String {
        return literal
    }

    public func setLiteral(literal: String): Unit {
        this.literal = literal
    }

    protected func toStringAttributes(): String {
        return "literal=${literal}"
    }
}

public class HtmlInline <: Node {
    private var literal: String

    public init(literal: String) {
        this.literal = literal
    }

    public override func accept(visitor: Visitor): Unit {
        visitor.visit(this)
    }

    public func getLiteral(): String {
        return literal
    }

    public func setLiteral(literal: String): Unit {
        this.literal = literal
    }
}

public abstract class CustomNode <: Node {
    public override func accept(visitor: Visitor): Unit {
        visitor.visit(this)
    }
}

public class Image <: Node {
    private var destination: String
    private var title: String

    public init(destination: String, title: String) {
        this.destination = destination
        this.title = title
    }

    public override func accept(visitor: Visitor): Unit {
        visitor.visit(this)
    }

    public func getDestination(): String {
        return destination
    }

    public func setDestination(destination: String): Unit {
        this.destination = destination
    }

    public func getTitle(): String {
        return title
    }

    public func setTitle(title: String): Unit {
        this.title = title
    }

    protected override func toStringAttributes(): String {
        return "destination=${destination}, title=${title}"
    }
}

public class Code <: Node {
    private var literal: String

    public init(literal: String) {
        this.literal = literal
    }

    public override func accept(visitor: Visitor): Unit {
        visitor.visit(this)
    }

    public func getLiteral(): String {
        return literal
    }

    public func setLiteral(literal: String): Unit {
        this.literal = literal
    }
}

public class HardLineBreak <: Node {
    public override func accept(visitor: Visitor): Unit {
        visitor.visit(this)
    }
}

public class SoftLineBreak <: Node {
    public override func accept(visitor: Visitor): Unit {
        visitor.visit(this)
    }
}

public class LinkReferenceDefinition <: Node {
    private var label: ?String = None
    private var destination: ?String = None
    private var title: ?String = None

    public init() {}

    public init(label: String, destination: String, title: String) {
        this.label = label
        this.destination = destination
        this.title = title
    }

    public func getLabel(): ?String {
        return label
    }

    public func setLabel(label: String): Unit {
        this.label = label
    }

    public func getDestination(): ?String {
        return destination
    }

    public func setDestination(destination: String): Unit {
        this.destination = destination
    }

    public func getTitle(): ?String {
        return title
    }

    public func setTitle(title: String): Unit {
        this.title = title
    }

    public override func accept(visitor: Visitor): Unit {
        visitor.visit(this)
    }
}

public class Link <: Node {
    private var destination: String
    private var title: ?String

    public init(destination: String, title: ?String) {
        this.destination = destination
        this.title = title
    }

    public override func accept(visitor: Visitor): Unit {
        visitor.visit(this)
    }

    public func getDestination(): String {
        return destination
    }

    public func setDestination(destination: String): Unit {
        this.destination = destination
    }

    public func getTitle(): ?String {
        return title
    }

    public func setTitle(title: String): Unit {
        this.title = title
    }

    protected override func toStringAttributes(): String {
        return "destination=${destination}, title=${title}"
    }
}

/**
 * A node that uses delimiters in the source form bold.
 */
public interface Delimited {
    func getOpeningDelimiter(): ?String

    func getClosingDelimiter(): ?String
}

public class StrongEmphasis <: Node & Delimited {
    private var delimiter: ?String = None

    public init() {}

    public init(delimiter: String) {
        this.delimiter = delimiter
    }

    public func setDelimiter(delimiter: String): Unit {
        this.delimiter = delimiter
    }

    public func getOpeningDelimiter(): ?String {
        return delimiter
    }

    public func getClosingDelimiter(): ?String {
        return delimiter
    }

    public override func accept(visitor: Visitor): Unit {
        visitor.visit(this)
    }
}

public class Emphasis <: Node & Delimited {
    private var delimiter: ?String = None

    public init() {}

    public init(delimiter: String) {
        this.delimiter = delimiter
    }

    public func setDelimiter(delimiter: String): Unit {
        this.delimiter = delimiter
    }

    public func getOpeningDelimiter(): ?String {
        return delimiter
    }

    public func getClosingDelimiter(): ?String {
        return delimiter
    }

    public override func accept(visitor: Visitor): Unit {
        visitor.visit(this)
    }
}
