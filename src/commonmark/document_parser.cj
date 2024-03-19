package commonmark

class DocumentParser <: ParserState {
    private static var CORE_FACTORY_TYPES: HashSet<TypeInfo> = HashSet<TypeInfo>(
        [
            TypeInfo.of<BlockQuote>(),
            TypeInfo.of<Heading>(),
            TypeInfo.of<FencedCodeBlock>(),
            TypeInfo.of<HtmlBlock>(),
            TypeInfo.of<ThematicBreak>(),
            TypeInfo.of<ListBlock>(),
            TypeInfo.of<IndentedCodeBlock>()
        ]
    )

    private static var NODES_TO_CORE_FACTORIES: HashMap<TypeInfo, BlockParserFactory> = HashMap<TypeInfo, BlockParserFactory>(
        [
            (TypeInfo.of<BlockQuote>(), BlockQuoteParserFactory()),
            (TypeInfo.of<Heading>(), HeadingParserFactory()),
            (TypeInfo.of<FencedCodeBlock>(), FencedCodeBlockParserFactory()),
            (TypeInfo.of<HtmlBlock>(), HtmlBlockParserFactory()),
            (TypeInfo.of<ThematicBreak>(), ThematicBreakParserFactory()),
            (TypeInfo.of<ListBlock>(), ListBlockParserFactory()),
            (TypeInfo.of<IndentedCodeBlock>(), IndentedCodeBlockParserFactory())
        ]
    )

    private var line: CharSequence = []

    /**
     * current index (offset) in input line (0-based)
     */
    private var index: Int64 = 0

    /**
     * current column of input line (tab causes column to go to next 4-space tab stop) (0-based)
     */
    private var column: Int64 = 0

    /**
     * if the current column is within a tab character (partially consumed tab)
     */
    private var columnIsInTab: Bool = false

    private var nextNonSpace: Int64 = 0
    private var nextNonSpaceColumn: Int64 = 0
    private var indent: Int64 = 0
    private var blank: Bool = false

    private var blockParserFactories: ArrayList<BlockParserFactory>
    private var inlineParserFactory: InlineParserFactory
    private var delimiterProcessors: ArrayList<DelimiterProcessor>
    private var documentBlockParser: DocumentBlockParser
    private var definitions: HashMap<String, LinkReferenceDefinition> = HashMap<String, LinkReferenceDefinition>()

    private var activeBlockParsers: ArrayList<AbstractBlockParser> = ArrayList<AbstractBlockParser>()
    // LinkedHashSet to have a deterministic order
    private var allBlockParsers: ArrayList<AbstractBlockParser> = ArrayList<AbstractBlockParser>()
    // private var allBlockParsers: HashSet<AbstractBlockParser> = HashSet<AbstractBlockParser>()

    public init(
        blockParserFactories: ArrayList<BlockParserFactory>,
        inlineParserFactory: InlineParserFactory,
        delimiterProcessors: ArrayList<DelimiterProcessor>
    ) {
        this.blockParserFactories = blockParserFactories
        this.inlineParserFactory = inlineParserFactory
        this.delimiterProcessors = delimiterProcessors

        this.documentBlockParser = DocumentBlockParser()
        activateBlockParser(this.documentBlockParser)
    }

    public static func getDefaultBlockParserTypes(): HashSet<TypeInfo> {
        return CORE_FACTORY_TYPES
    }

    public static func calculateBlockParserFactories(
        customBlockParserFactories: ArrayList<BlockParserFactory>,
        enabledBlockTypes: HashSet<TypeInfo>
    ): ArrayList<BlockParserFactory> {
        var list: ArrayList<BlockParserFactory> = ArrayList<BlockParserFactory>()
        // By having the custom factories come first, extensions are able to change behavior of core syntax.
        list.appendAll(customBlockParserFactories)
        for (blockType in enabledBlockTypes) {
            list.append(NODES_TO_CORE_FACTORIES.get(blockType).getOrThrow())
        }
        return list
    }

    /**
     * The main parsing function. Returns a parsed document AST.
     */
    public func parse(inputStr: String): Document {
        let input = inputStr.toRuneArray()
        var lineStart: Int64 = 0
        var lineBreak: Int64 = Parsing.findLineBreak(input, lineStart)
        while (lineBreak != -1) {
            var line = input[lineStart..lineBreak]
            incorporateLine(line)
            if (lineBreak + 1 < input.size && input[lineBreak] == '\r' && input[lineBreak + 1] == '\n') {
                lineStart = lineBreak + 2
            } else {
                lineStart = lineBreak + 1
            }
            lineBreak = Parsing.findLineBreak(input, lineStart)
        }
        if (input.size > 0 && (lineStart == 0 || lineStart < input.size)) {
            var line = input[lineStart..input.size]
            incorporateLine(line)
        }

        return finalizeAndProcess()
    }

    public func parse(input: StringReader<InputStream>): Document { // throws IOException
        var bufferedReader: StringReader<InputStream> = input
        while (true) {
            if (let Some(line) <- bufferedReader.readln()?.toRuneArray()) {
                incorporateLine(line)
            } else {
                break
            }
        }

        return finalizeAndProcess()
    }

    public func getLine(): CharSequence {
        return line
    }

    public func getIndex(): Int64 {
        return index
    }

    public func getNextNonSpaceIndex(): Int64 {
        return nextNonSpace
    }

    public func getColumn(): Int64 {
        return column
    }

    public func getIndent(): Int64 {
        return indent
    }

    public func isBlank(): Bool {
        return blank
    }

    public func getActiveBlockParser(): AbstractBlockParser {
        return activeBlockParsers[activeBlockParsers.size - 1]
    }

    /**
     * Analyze a line of text and update the document appropriately. We parse markdown text by calling this on each
     * line of input, then finalizing the document.
     */
    private func incorporateLine(ln: CharSequence): Unit {
        line = Parsing.prepareLine(ln)
        index = 0
        column = 0
        columnIsInTab = false

        // For each containing block, try to parse the associated line start.
        // Bail out on failure: container will poInt64 to the last matching block.
        // Set all_matched to false if not all containers match.
        // The document will always match, can be skipped
        var matches: Int64 = 1
        if (activeBlockParsers.size > 1) {
            for (blockParser in activeBlockParsers[1..activeBlockParsers.size]) {
                findNextNonSpace()

                var result: ?BlockContinue = blockParser.tryContinue(this)
                if (result.isSome() && result() is BlockContinueImpl) {
                    var blockContinueImpl: BlockContinueImpl = (result() as BlockContinueImpl).getOrThrow()
                    if (blockContinueImpl.isFinalize()) {
                        finalize(blockParser)
                        return
                    } else {
                        if (blockContinueImpl.getNewIndex() != -1) {
                            setNewIndex(blockContinueImpl.getNewIndex())
                        } else if (blockContinueImpl.getNewColumn() != -1) {
                            setNewColumn(blockContinueImpl.getNewColumn())
                        }
                        matches++
                    }
                } else {
                    break
                }
            }
        }

        var unmatchedBlockParser: ArrayList<AbstractBlockParser> = ArrayList<AbstractBlockParser>()
        if (matches < activeBlockParsers.size) {
            unmatchedBlockParser = activeBlockParsers[matches..activeBlockParsers.size]
        }
        var lastMatchedBlockParser: AbstractBlockParser = activeBlockParsers[matches - 1]
        var blockParser: AbstractBlockParser = lastMatchedBlockParser
        var allClosed: Bool = unmatchedBlockParser.isEmpty()

        // Unless last matched container is a code block, try container starts,
        // adding children to the last matched container:
        var tryBlockStarts: Bool = blockParser.getBlock() is Paragraph || blockParser.isContainer()
        while (tryBlockStarts) {
            findNextNonSpace()

            // this is a little performance optimization:
            if (isBlank() || (indent < Parsing.CODE_BLOCK_INDENT && Parsing.isLetter(line, nextNonSpace))) {
                setNewIndex(nextNonSpace)
                break
            }

            var blockStartOption: ?BlockStart = findBlockStart(blockParser)
            if (blockStartOption.isNone()) {
                setNewIndex(nextNonSpace)
                break
            }

            if (!allClosed) {
                finalizeBlocks(unmatchedBlockParser)
                allClosed = true
            }
            var blockStart = (blockStartOption.getOrThrow() as BlockStartImpl).getOrThrow()
            if (blockStart.getNewIndex() != -1) {
                setNewIndex(blockStart.getNewIndex())
            } else if (blockStart.getNewColumn() != -1) {
                setNewColumn(blockStart.getNewColumn())
            }

            if (blockStart.isReplaceActiveBlockParser()) {
                prepareActiveBlockParserForReplacement()
            }

            for (newBlockParser in blockStart.getBlockParsers()) {
                blockParser = addChild(newBlockParser)
                tryBlockStarts = newBlockParser.isContainer()
            }
        }

        // What remains at the offset is a text line. Add the text to the
        // appropriate block.

        // First check for a lazy paragraph continuation:
        if (!allClosed && !isBlank() && getActiveBlockParser().canHaveLazyContinuationLines()) {
            // lazy paragraph continuation
            addLine()
        } else {

            // finalize any blocks not matched
            if (!allClosed) {
                finalizeBlocks(unmatchedBlockParser)
            }

            if (!blockParser.isContainer()) {
                addLine()
            } else if (!isBlank()) {
                // create paragraph container for line
                addChild(ParagraphParser())
                addLine()
            }
        }
    }

    private func findNextNonSpace(): Unit {
        var i: Int64 = index
        var colsNum: Int64 = column

        blank = true
        var length: Int64 = line.size
        while (i < length) {
            var c = line[i]
            if (c == ' ') {
                i++
                colsNum++
                continue
            } else if (c == '\t') {
                i++
                colsNum += (4 - (colsNum % 4))
                continue
            }
            blank = false
            break
        }

        nextNonSpace = i
        nextNonSpaceColumn = colsNum
        indent = nextNonSpaceColumn - column
    }

    private func setNewIndex(newIndex: Int64): Unit {
        if (newIndex >= nextNonSpace) {
            // We can start from here, no need to calculate tab stops again
            index = nextNonSpace
            column = nextNonSpaceColumn
        }
        var length: Int64 = line.size
        while (index < newIndex && index != length) {
            advance()
        }
        // If we're going to an index as opposed to a column, we're never within a tab
        columnIsInTab = false
    }

    private func setNewColumn(newColumnNum: Int64): Unit {
        if (newColumnNum >= nextNonSpaceColumn) {
            // We can start from here, no need to calculate tab stops again
            index = nextNonSpace
            column = nextNonSpaceColumn
        }
        var length: Int64 = line.size
        while (column < newColumnNum && index != length) {
            advance()
        }
        if (column > newColumnNum) {
            // Last character was a tab and we overshot our target
            index--
            column = newColumnNum
            columnIsInTab = true
        } else {
            columnIsInTab = false
        }
    }

    private func advance(): Unit {
        var char = line[index]
        if (char == '\t') {
            index++
            column += Parsing.columnsToNextTabStop(column)
        } else {
            index++
            column++
        }
    }

    /**
     * Add line content to the active block parser. We assume it can accept lines -- that check should be done before
     * calling this.
     */
    private func addLine(): Unit {
        var content: CharSequence
        if (columnIsInTab) {
            // Our column is in a partially consumed tab. Expand the remaining columns (to the next tab stop) to spaces.
            var afterTab: Int64 = index + 1
            var rest = line[afterTab..line.size]
            var spaces: Int64 = Parsing.columnsToNextTabStop(column)
            var sb: StringBuilder = StringBuilder(spaces + rest.size)
            sb.append(" " * spaces)
            sb.append(rest)
            content = sb.toString().toRuneArray()
        } else {
            content = line[index..line.size]
        }
        getActiveBlockParser().addLine(content)
    }

    private func findBlockStart(blockParser: AbstractBlockParser): Option<BlockStart> {
        var matchedBlockParser: MatchedBlockParser = MatchedBlockParserImpl(blockParser)
        for (blockParserFactory in blockParserFactories) {
            var result: ?BlockStart = blockParserFactory.tryStart(this, matchedBlockParser)
            if (result.isSome() && result.getOrThrow() is BlockStartImpl) {
                return result
            }
        }
        return None
    }

    /**
     * Finalize a block. Close it and do any necessary postprocessing, e.g. creating string_content from strings,
     * setting the 'tight' or 'loose' status of a list, and parsing the beginnings of paragraphs for reference
     * definitions.
     */
    private func finalize(blockParser: AbstractBlockParser): Unit {
        if (refEq(getActiveBlockParser(), blockParser)) {
            deactivateBlockParser()
        }

        if (blockParser is ParagraphParser) {
            addDefinitionsFrom((blockParser as ParagraphParser).getOrThrow())
        }

        blockParser.closeBlock()
    }

    private func addDefinitionsFrom(paragraphParser: ParagraphParser): Unit {
        for (definition in paragraphParser.getDefinitions()) {
            // Add nodes into document before paragraph.
            paragraphParser.getBlock().insertBefore(definition)

            var label: String = definition.getLabel().getOrThrow()
            // spec: When there are multiple matching link reference definitions, the first is used
            if (!definitions.contains(label)) {
                definitions.put(label, definition)
            }
        }
    }

    /**
     * Walk through a block & children recursively, parsing string content into inline content where appropriate.
     */
    private func processInlines(): Unit {
        var context: InlineParserContextImpl = InlineParserContextImpl(delimiterProcessors, definitions)
        var inlineParser: InlineParser = inlineParserFactory.create(context)

        for (blockParser in allBlockParsers) {
            blockParser.parseInlines(inlineParser)
        }
    }

    /**
     * Add block of type tag as a child of the tip. If the tip can't  accept children, close and finalize it and try
     * its parent, and so on til we find a block that can accept children.
     */
    private func addChild(blockParser: AbstractBlockParser): AbstractBlockParser {
        while (!getActiveBlockParser().canContain(blockParser.getBlock())) {
            finalize(getActiveBlockParser())
        }

        getActiveBlockParser().getBlock().appendChild(blockParser.getBlock())
        activateBlockParser(blockParser)

        return blockParser
    }

    private func activateBlockParser(blockParser: AbstractBlockParser): Unit {
        activeBlockParsers.append(blockParser)
        allBlockParsers.append(blockParser)
    }

    private func deactivateBlockParser(): Unit {
        activeBlockParsers.remove(activeBlockParsers.size - 1)
    }

    private func prepareActiveBlockParserForReplacement(): Unit {
        let old: AbstractBlockParser = getActiveBlockParser()
        deactivateBlockParser()
        for (i in 0..allBlockParsers.size) {
            if (refEq(allBlockParsers[i], old)) {
                allBlockParsers.remove(i)
            }
        }

        if (old is ParagraphParser) {
            var paragraphParser: ParagraphParser = (old as ParagraphParser).getOrThrow()
            // Collect any link reference definitions. Note that replacing the active block parser is done after a
            // block parser got the current paragraph content using MatchedBlockParser#getContentString. In case the
            // paragraph started with link reference definitions, we parse and strip them before the block parser gets
            // the content. We want to keep them.
            // If no replacement happens, we collect the definitions as part of finalizing paragraph blocks.
            addDefinitionsFrom(paragraphParser)
        }

        old.getBlock().unlink()
    }

    /**
     * Finalize blocks of previous line. Returns true.
     */
    private func finalizeBlocks(blockParsers: ArrayList<AbstractBlockParser>): Unit {
        // for (Int64 i = blockParsers.size() - 1; i >= 0; i--) {
        for (i in blockParsers.size - 1..=0 : -1) {
            var blockParser: AbstractBlockParser = blockParsers[i]
            finalize(blockParser)
        }
    }

    private func finalizeAndProcess(): Document {
        finalizeBlocks(this.activeBlockParsers)
        this.processInlines()
        return this.documentBlockParser.getBlock()
    }
}

class MatchedBlockParserImpl <: MatchedBlockParser {
    private var matchedBlockParser: AbstractBlockParser

    public MatchedBlockParserImpl(matchedBlockParser: AbstractBlockParser) {
        this.matchedBlockParser = matchedBlockParser
    }

    public func getMatchedBlockParser(): AbstractBlockParser {
        return matchedBlockParser
    }

    public func getParagraphContent(): ?String {
        if (matchedBlockParser is ParagraphParser) {
            var paragraphParser: ParagraphParser = (matchedBlockParser as ParagraphParser).getOrThrow()
            var content: String = paragraphParser.getContentString()
            if (content.size == 0) {
                return None
            }

            return content
        }
        return None
    }
}
