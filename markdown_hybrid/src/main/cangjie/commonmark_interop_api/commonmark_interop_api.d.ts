export declare class CjNode {
    getNext(): CjNode | undefined
    getPrevious(): CjNode | undefined
    getFirstChild(): CjNode | undefined
    getLastChild(): CjNode | undefined
    getParent(): CjNode | undefined
    appendChild(child: CjNode): void
    prependChild(child: CjNode): void
    unlink(): void
    insertAfter(sibling: CjNode): void
    insertBefore(sibling: CjNode): void
    toString(): string
    getNodeType(): string
    getLiteral(): string | undefined
    getDestination(): string | undefined
    getTitle(): string | undefined
    getLabel(): string | undefined
    getOpeningDelimiter(): string | undefined
    getClosingDelimiter(): string | undefined
    getFenceChar(): string | undefined
    getFenceLength(): number | undefined
    getFenceIndent(): number | undefined
    getInfo(): string | undefined
    isTight(): boolean | undefined
    getBulletMarker(): string | undefined
    getStartNumber(): number | undefined
    getDelimiter(): string | undefined
}


export declare interface CustomLib {
    parseIntoJsNode(md: string, JsNode: new () => object, ...customParsers: Array<object>): object
    parse2Json(md: string, JsNode: new () => object, ...customParsers: Array<object>): string
    CjNode: {new (): CjNode}
    printNode(node: CjNode | undefined): void
    parseIntoCjNode(md: string): Promise<CjNode>
}