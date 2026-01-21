import { hilog } from '@kit.PerformanceAnalysisKit';
import { describe, beforeAll, beforeEach, afterEach, afterAll, it, expect } from '@ohos/hypium';
import {
  JsNode,
  ParsedInline,
  InlineContentParser,
  Scanner,
  Options,
  parseIntoJsNode,
  cjLib,
  HybridParser,
  printNode,
  utf16Index2utf8Index,
  utf8Index2utf16Index,
  JsNodeImpl,
} from '@cangjie-tpc/commonmark_hybrid';

function opt(includeSourceSpans: number, cmInlineTags: string[]): Options {
  return {
    jsNodeFactory: () => new JsNodeImpl(),
    includeSourceSpans: includeSourceSpans,
    cmInlineTags: cmInlineTags,
    customParsers: undefined
  }
}

export default function aTest() {
  describe('aTest', () => {
    beforeAll(() => {
    })
    beforeEach(() => {
    })
    afterEach(() => {
    })
    afterAll(() => {
    })
    it('htmltag1', 0, async () => {
      let md = `asd<cmtag.inline.asd k1 k2=v2 k3='v3' k4="v4"/>markdown文本1</cmtag.inline.asd>markdown文本2`
      let doc = await parseIntoJsNode(md, opt(0, ['cmtag.inline.asd']))
      let str = printNode(doc)
      console.error(str)
      let p: JsNode = doc.getFirstChild()!
      let node0: JsNode = p.getFirstChild()!
      let node1: JsNode = node0.getNext()!
      let node2: JsNode = node1.getNext()!
      expect(node1.getNodeType()).assertEqual("CustomTag")
      expect(node2.getNodeType()).assertEqual("Text")
      expect(node2.getNext()).assertEqual(undefined)
      let props = node1.getProps()!
      expect(props.size).assertEqual(4)
      expect(props.get('k1')).assertEqual('')
      expect(props.get('k2')).assertEqual('v2')
      expect(props.get('k3')).assertEqual('v3')
      expect(props.get('k4')).assertEqual('v4')
    })
    it('htmltag2', 0, async () => {
      let md = `<cmtag.inline.asd k1 k2=v2 k3='v3' k4="v4">markdown文本1</cmtag.inline.asd>markdown文本2`
      let doc = await parseIntoJsNode(md, opt(0, ['cmtag.inline.asd']))
      let str = printNode(doc)
      console.error(str)
      let p: JsNode = doc.getFirstChild()!
      let node0: JsNode = p.getFirstChild()!
      let node1: JsNode = node0.getNext()!
      expect(node0.getNodeType()).assertEqual("CustomTag")
      expect(node1.getNodeType()).assertEqual("Text")
      expect(node1.getNext()).assertEqual(undefined)
      let props = node0.getProps()!
      expect(props.size).assertEqual(4)
      expect(props.get('k1')).assertEqual('')
      expect(props.get('k2')).assertEqual('v2')
      expect(props.get('k3')).assertEqual('v3')
      expect(props.get('k4')).assertEqual('v4')
    })
    it('htmltag3', 0, async () => {
      let md = `<INSERT_IMAGE/><^moonLoading^/><KIMI_REF/>`
      let doc = await parseIntoJsNode(md, opt(0, ['INSERT_IMAGE','^moonLoading^','KIMI_REF']))
      let str = printNode(doc)
      console.error(str)
      let p: JsNode = doc.getFirstChild()!
      let node0: JsNode = p.getFirstChild()!
      let node1: JsNode = node0.getNext()!
      let node2: JsNode = node1.getNext()!
      expect(node0.getNodeType()).assertEqual("CustomTag")
      expect(node1.getNodeType()).assertEqual("CustomTag")
      expect(node2.getNodeType()).assertEqual("CustomTag")
      expect(node0['tagName']).assertEqual("INSERT_IMAGE")
      expect(node1['tagName']).assertEqual("^moonLoading^")
      expect(node2['tagName']).assertEqual("KIMI_REF")
    })
  })
}
