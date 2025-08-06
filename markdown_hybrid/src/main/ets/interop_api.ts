import { requireCJLib } from 'libark_interop_loader.so';
import { InlineContentParser } from './InlineContentParser'

// import { JsNode } from './JsNode'

/**
 * 可复用的MarkdownParser
 */
export interface HybridParser {
  /**
   * parse markdown
   * @param md
   * @returns Promise<JsNode>
   */
  parse(md: string): Promise<object>
}

export declare interface CustomLib {
  /**
   * parseIntoJsNode
   * @param md
   * @param jsNodeFactory: () => JsNode
   * @param customParsers: Array<InlineContentParser>
   * @returns Promise<JsNode>
   */
  parseIntoJsNode(md: string, jsNodeFactory: () => object,
    ...customParsers: Array<InlineContentParser>): Promise<object>

  HybridParser: {
    /**
     * HybridParser constructor
     * @param jsNodeFactory: () => JsNode
     * @param customParsers: Array<InlineContentParser>
     * @returns HybridParser
     */
    new(jsNodeFactory: () => object /*JsNode*/, ...customParsers: Array<InlineContentParser>): HybridParser
  }
}

export const cjLib: CustomLib = requireCJLib("libmarkdown_hybrid.so") as CustomLib