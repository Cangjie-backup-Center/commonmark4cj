package commonmark

public abstract class Block <: Node {
    public func getParent(): ?Node {
        let parent: ?Node = super.getParent()
        return match (parent) {
            case Some(v: Block) => v
            case _ => None
        }
    }

    protected override func setParent(parent: Node): Unit {
        if (!(parent is Block)) {
            throw IllegalArgumentException("Parent of block must also be block (can not be inline)")
        }
        super.setParent(parent)
    }
}

public class BlockQuote <: Block {
    public func accept(visitor: Visitor): Unit {
        visitor.visit(this)
    }
}

public class HtmlBlock <: Block {
    private var literal: String = EMPTY_STRING

    public func accept(visitor: Visitor): Unit {
        visitor.visit(this)
    }

    public func getLiteral(): String {
        return literal
    }

    public func setLiteral(literal: String): Unit {
        this.literal = literal
    }
}

public abstract class CustomBlock <: Block {
    public func accept(visitor: Visitor): Unit {
        visitor.visit(this)
    }
}

public class ThematicBreak <: Block {
    public func accept(visitor: Visitor): Unit {
        visitor.visit(this)
    }
}

public class Document <: Block {
    public func accept(visitor: Visitor): Unit {
        visitor.visit(this)
    }
}

public class Paragraph <: Block {
    public func accept(visitor: Visitor): Unit {
        visitor.visit(this)
    }
}

public class IndentedCodeBlock <: Block {
    private var literal: String = EMPTY_STRING

    public func accept(visitor: Visitor): Unit {
        visitor.visit(this)
    }

    public func getLiteral(): String {
        return literal
    }

    public func setLiteral(literal: String): Unit {
        this.literal = literal
    }
}

public class FencedCodeBlock <: Block {
    private var fenceChar: Char = NULL_CHAR
    private var fenceLength: Int64 = 0
    private var fenceIndent: Int64 = 0

    private var info: String = EMPTY_STRING
    private var literal: String = EMPTY_STRING

    public func accept(visitor: Visitor): Unit {
        visitor.visit(this)
    }

    public func getFenceChar(): Char {
        return fenceChar
    }

    public func setFenceChar(fenceChar: Char): Unit {
        this.fenceChar = fenceChar
    }

    public func getFenceLength(): Int64 {
        return fenceLength
    }

    public func setFenceLength(fenceLength: Int64): Unit {
        this.fenceLength = fenceLength
    }

    public func getFenceIndent(): Int64 {
        return fenceIndent
    }

    public func setFenceIndent(fenceIndent: Int64): Unit {
        this.fenceIndent = fenceIndent
    }

    public func getInfo(): String {
        return info
    }

    public func setInfo(info: String): Unit {
        this.info = info
    }

    public func getLiteral(): String {
        return literal
    }

    public func setLiteral(literal: String): Unit {
        this.literal = literal
    }
}

public class ListItem <: Block {
    public func accept(visitor: Visitor): Unit {
        visitor.visit(this)
    }
}

public class Heading <: Block {
    private var level: Int64 = 0

    public func accept(visitor: Visitor): Unit {
        visitor.visit(this)
    }

    public func getLevel(): Int64 {
        return level
    }

    public func setLevel(level: Int64): Unit {
        this.level = level
    }
}

public abstract class ListBlock <: Block {
    private var tight: Bool = false

    public func isTight(): Bool {
        return tight
    }

    public func setTight(tight: Bool) {
        this.tight = tight
    }
}

public class BulletList <: ListBlock {
    private var bulletMarker: Char

    public init(bulletMarker: Char) {
        this.bulletMarker = bulletMarker
    }

    public func accept(visitor: Visitor): Unit {
        visitor.visit(this)
    }

    public func getBulletMarker(): Char {
        return bulletMarker
    }

    public func setBulletMarker(bulletMarker: Char): Unit {
        this.bulletMarker = bulletMarker
    }
}

public class OrderedList <: ListBlock {
    private var startNumber: Int64
    private var delimiter: Char

    public init(startNumber: Int64, delimiter: Char) {
        this.startNumber = startNumber
        this.delimiter = delimiter
    }

    public func accept(visitor: Visitor): Unit {
        visitor.visit(this)
    }

    public func getStartNumber(): Int64 {
        return startNumber
    }

    public func setStartNumber(startNumber: Int64): Unit {
        this.startNumber = startNumber
    }

    public func getDelimiter(): Char {
        return delimiter
    }

    public func setDelimiter(delimiter: Char): Unit {
        this.delimiter = delimiter
    }
}
