/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */

package commonmark4cj.table

let TableBlockType: NodeType = "TableBlock"
let TableBodyType: NodeType = "TableBody"
let TableCellType: NodeType = "TableCell"
let TableHeadType: NodeType = "TableHead"
let TableRowType: NodeType = "TableRow"

public abstract class TableNodeRenderer <: NodeRenderer {
    public override func getNodeTypes(): HashSet<NodeType> {
        return HashSet<NodeType>([TableBlockType, TableHeadType, TableBodyType, TableRowType, TableCellType])
    }

    public override func render(node: Node): Unit {
        if (node is TableBlock) {
            renderBlock((node as TableBlock)())
        } else if (node is TableHead) {
            renderHead((node as TableHead)())
        } else if (node is TableBody) {
            renderBody((node as TableBody)())
        } else if (node is TableRow) {
            renderRow((node as TableRow)())
        } else if (node is TableCell) {
            renderCell((node as TableCell)())
        }
    }

    protected func renderBlock(node: TableBlock): Unit

    protected func renderHead(node: TableHead): Unit

    protected func renderBody(node: TableBody): Unit

    protected func renderRow(node: TableRow): Unit

    protected func renderCell(node: TableCell): Unit
}

public class TableBlock <: CustomBlock {
    public override func getNodeType(): NodeType {
        return TableBlockType
    }
}

public class TableBody <: CustomNode {
    public override func getNodeType(): NodeType {
        return TableBodyType
    }
}

public class TableCell <: CustomNode {
    private var header: Bool = false
    private var alignment: ?Alignment = None

    /**
     * @return whether the cell is a header or not
     */
    public func isHeader(): Bool {
        return header
    }

    public func setHeader(header: Bool): Unit {
        this.header = header
    }

    /**
     * @return the cell alignment
     */
    public func getAlignment(): ?Alignment {
        return alignment
    }

    public func setAlignment(alignment: Alignment): Unit {
        this.alignment = alignment
    }
    public override func getNodeType(): NodeType {
        return TableCellType
    }
}

/**
 * How the cell is aligned horizontally.
 */
public enum Alignment {
    | LEFT
    | CENTER
    | RIGHT
}

public class TableHead <: CustomNode {
    public override func getNodeType(): NodeType {
        return TableHeadType
    }
}

public class TableRow <: CustomNode {
    public override func getNodeType(): NodeType {
        return TableRowType
    }
}

public class TablesExtension <: ParserExtension {
    private init() {
    }

    public static func create(): Extension {
        return TablesExtension()
    }

    public func ext(parserBuilder: ParserBuilder): Unit {
        parserBuilder.customBlockParserFactory(tableBlockFactory())
    }

}
