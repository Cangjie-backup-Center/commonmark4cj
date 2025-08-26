/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2025. All rights reserved.
 */

package commonmark4cj.table

class TableBlockParser <: AbstractBlockParser {
    private var block: TableBlock = TableBlock()
    private var bodyLines: ArrayList<SourceLine> = ArrayList()
    private let columns: ArrayList<?Alignment>
    private let headerCells: ArrayList<SourceLine>

    var lineState: Int = 0 // 行状态 0:head 0:column 2:body

    init(columns: ArrayList<?Alignment>, headerCells: ArrayList<SourceLine>) {
        this.columns = columns
        this.headerCells = headerCells
    }

    public func canHaveLazyContinuationLines(): Bool {
        return true
    }

    public func getBlock(): TableBlock {
        return block
    }

    public func tryContinue(state: ParserState): ?BlockContinue {
        if (state.getLine().getContent().contains("|")) {
            return BlockContinue.atIndex(state.getIndex())
        } else {
            return BlockContinue.none()
        }
    }

    public func addLine(line: SourceLine): Unit {
        if (lineState != 2) {
            lineState++
        } else {
            bodyLines.add(line)
        }
    }

    public func parseInlines(inlineParser: InlineParser): Unit {
        let sourceSpans = block.getSourceSpans()

        let headerSourceSpan: ?SourceSpan = sourceSpans.get(0)
        var head: Node = TableHead()
        if (let Some(v) <- headerSourceSpan) {
            head.addSourceSpan(v)
        }
        block.appendChild(head)

        var headerRow: TableRow = TableRow()
        headerRow.setSourceSpans(head.getSourceSpans())
        head.appendChild(headerRow)

        let headerColumns = headerCells.size
        for (i in 0..headerColumns) {
            let cell = headerCells[i]
            var tableCell: TableCell = parseCell(cell, i, inlineParser)
            tableCell.setHeader(true)
            headerRow.appendChild(tableCell)
        }

        var body: ?Node = None
        for (i in 0..bodyLines.size) {
            let rowLine = bodyLines[i]
            let sourceSpan = sourceSpans.get(i + 2)
            var cells = split(rowLine)
            var row: TableRow = TableRow()
            if (let Some(v) <- sourceSpan) {
                row.addSourceSpan(v)
            }

            // Body can not have more columns than head
            for (i in 0..headerColumns) {
                let cell = if (i < cells.size) {
                    cells[i]
                } else {
                    SourceLine.of("", None)
                }
                var tableCell: TableCell = parseCell(cell, i, inlineParser)
                row.appendChild(tableCell)
            }

            if (body.isNone()) {
                // It's valid to have a table without body. In that case, don't add an empty TableBody node.
                body = TableBody()
                block.appendChild(body())
            }
            body?.appendChild(row)
            if (let Some(v) <- sourceSpan) {
                body?.addSourceSpan(v)
            }
        }
    }

    private func parseCell(cell: SourceLine, column: Int64, inlineParser: InlineParser): TableCell {
        var tableCell: TableCell = TableCell()

        if (column < columns.size) {
            if (let Some(v) <- columns.get(column).flatten()) {
                tableCell.setAlignment(v)
            }
        }
        let content = cell.getContent()
        let start = Characters.skipSpaceTab(content, 0, content.size)
        let end = Characters.skipSpaceTabBackwards(content, content.size - 1, start)
        inlineParser.parse(SourceLines.of(cell.substring(start, end + 1)), tableCell)

        return tableCell
    }

    static func split(line: SourceLine): ArrayList<SourceLine> {
        var row: String = line.getContent()
        var nonSpace = Characters.skipSpaceTab(row, 0, row.size)
        var cellStart = nonSpace
        var cellEnd = row.size
        if (row[nonSpace] == b'|') {
            // This row has leading/trailing pipes - skip the leading pipe
            cellStart = nonSpace + 1
            // Strip whitespace from the end but not the pipe or we could miss an empty ("||") cell
            var nonSpaceEnd = Characters.skipSpaceTabBackwards(row, row.size - 1, cellStart)
            cellEnd = nonSpaceEnd + 1
        }
        var cells: ArrayList<SourceLine> = ArrayList()
        var sb: ArrayList<Byte> = ArrayList()
        var i: Int64 = cellStart
        while (i < cellEnd) {
            let c = row[i]
            match (c) {
                case '\\' =>
                    if (i + 1 < row.size && row[i + 1] == b'|') {
                        // Pipe is special for table parsing. An escaped pipe doesn't result in a new cell, but is
                        // passed down to inline parsing as an unescaped pipe. Note that that applies even for the `\|`
                        // in an input like `\\|` - in other words, table parsing doesn't support escaping backslashes.
                        sb.add(b'|')
                        i++
                    } else {
                        // Preserve backslash before other characters or at end of line.
                        sb.add(b'\\')
                    }
                case '|' =>
                    let content = StringFromArrayListByte(sb)
                    cells.add(SourceLine.of(content, line.substring(cellStart, i).getSourceSpan()))
                    sb.clear()
                    cellStart = i + 1
                case _ => sb.add(c)
            }
            i++
        }
        if (sb.size > 0) {
            let content = StringFromArrayListByte(sb)
            cells.add(SourceLine.of(content, line.substring(cellStart, line.getContent().size).getSourceSpan()))
        }
        return cells
    }

    // Examples of valid separators:
    //
    // |-
    // -|
    // |-|
    // -|-
    // |-|-|
    // --- | ---
    public static func parseSeparator(s: String): ?ArrayList<?Alignment> {
        var columns: ArrayList<?Alignment> = ArrayList<?Alignment>()
        var pipes: Int64 = 0
        var valid: Bool = false
        var i: Int64 = 0
        while (i < s.size) {
            let c = s[i]
            match (c) {
                case '|' =>
                    i++
                    pipes++
                    if (pipes > 1) {
                        // More than one adjacent pipe not allowed
                        return None
                    }
                    // Need at lest one pipe, even for a one column table
                    valid = true
                case '-' | ':' =>
                    if (pipes == 0 && !columns.isEmpty()) {
                        // Need a pipe after the first column (first column doesn't need to start with one)
                        return None
                    }
                    var left: Bool = false
                    var right: Bool = false
                    if (c == b':') {
                        left = true
                        i++
                    }
                    var haveDash: Bool = false
                    while (i < s.size && s[i] == b'-') {
                        i++
                        haveDash = true
                    }
                    if (!haveDash) {
                        // Need at least one dash
                        return None
                    }
                    if (i < s.size && s[i] == b':') {
                        right = true
                        i++
                    }
                    columns.add(getAlignment(left, right))
                    // Next, need another pipe
                    pipes = 0
                case ' ' | '\t' =>
                    // White space is allowed between pipes and columns
                    i++
                case _ =>
                    // Any other character is invalid
                    return None
            }
        }
        if (!valid) {
            return None
        }
        return columns
    }

    private static func getAlignment(left: Bool, right: Bool): ?Alignment {
        if (left && right) {
            return Alignment.CENTER
        } else if (left) {
            return Alignment.LEFT
        } else if (right) {
            return Alignment.RIGHT
        } else {
            return None
        }
    }
}

class TableBlockFactory <: AbstractBlockParserFactory {
    public func tryStart(state: ParserState, matchedBlockParser: MatchedBlockParser): ?BlockStart {
        let lineSource = state.getLine()
        let line: String = lineSource.getContent()
        let nextLine = state.getNextLine()
        let plines = matchedBlockParser.getParagraphLines().getLines()

        if (line.contains("|")) {
            if (nextLine.contains("|")) {
                let headLine = lineSource.substring(state.getIndex(), line.size)
                let columnLine: String = nextLine[state.getIndex()..] // 考虑到列表中 每行前有固定缩进
                if (let Some(blockStart) <- col(headLine, columnLine, state, 0)) {
                    return blockStart
                }
            }
            if (plines.size == 1 && plines[0].getContent().contains("|")) {
                let headLine = plines[0]
                let columnLine: String = line[state.getIndex()..]
                return col(headLine, columnLine, state, 1)?.replaceActiveBlockParser()
            }
        }
        return BlockStart.none()
    }
    private func col(headLine: SourceLine, columnLine: String, state: ParserState, currentLineState: Int): ?BlockStart {
        let columns: ArrayList<?Alignment> = TableBlockParser.parseSeparator(columnLine) ?? return BlockStart.none()
        if (columns.size > 0) {
            let headerCells: ArrayList<SourceLine> = TableBlockParser.split(headLine)
            if (columns.size >= headerCells.size) {
                let parser = TableBlockParser(columns, headerCells)
                parser.lineState = currentLineState
                return BlockStart.of(parser).atIndex(state.getIndex())
            }
        }
        return BlockStart.none()
    }
}
