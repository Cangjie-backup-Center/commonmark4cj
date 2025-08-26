import { JsNode } from './JsNode';
import { requireCJLib } from 'libark_interop_loader.so';
import { InlineContentParser } from './InlineContentParser'

/**
 * 可复用的MarkdownParser
 */
export interface HybridParser {
  /**
   * parse markdown
   * @param md
   * @returns Promise<JsNode>
   */
  parse(md: string): Promise<JsNode>
}

export declare interface CustomLib {
  /**
   * parseIntoJsNode
   * @param md
   * @param jsNodeFactory: () => JsNode
   * @param includeSourceSpans: 是否包含SourceSpan信息 0:不包含(默认) 1:仅Block节点 2:全部节点
   * @param customParsers: Array<InlineContentParser>
   * @returns Promise<JsNode>
   */
  parseIntoJsNode(
    md: string,
    jsNodeFactory: () => JsNode,
    includeSourceSpans: number,
    ...customParsers: Array<InlineContentParser>
  ): Promise<JsNode>

  HybridParser: {
    /**
     * HybridParser constructor
     * @param jsNodeFactory: () => JsNode
     * @param includeSourceSpans: 是否包含SourceSpan信息 0:不包含(默认) 1:仅Block节点 2:全部节点
     * @param customParsers: Array<InlineContentParser>
     * @returns HybridParser
     */
    new(
      jsNodeFactory: () => JsNode,
      includeSourceSpans: number,
      ...customParsers: Array<InlineContentParser>
    ): HybridParser
  }
}

export const cjLib: CustomLib = requireCJLib("libcommonmark_hybrid.so") as CustomLib