import { JsNode } from './JsNode';
import { requireCJLib } from 'libark_interop_loader.so';
import { InlineContentParser } from './InlineContentParser'
import { Options } from './Options';

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
   * @returns Promise<JsNode>
   */
  parseIntoJsNode(md: string, options: Options): Promise<JsNode>

  HybridParser: {
    /**
     * HybridParser constructor
     * @returns HybridParser
     */
    new(options: Options): HybridParser
  }
}

export const cjLib: CustomLib = requireCJLib("libcommonmark_hybrid.so") as CustomLib