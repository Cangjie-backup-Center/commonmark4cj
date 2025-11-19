import { hilog } from '@kit.PerformanceAnalysisKit';
import { describe, beforeAll, beforeEach, afterEach, afterAll, it, expect } from '@ohos/hypium';
import {
  InlineContentParser,
  ParsedInline,
  parseIntoJsNode,
  utf16Index2utf8Index,
  Scanner,
  utf8Index2utf16Index,
  printNode,
  JsNode
} from '@cangjie-tpc/commonmark_hybrid';
import { errjson } from './md1';
import { err2 } from './md2';

export default function bugTest() {
  describe('bugTest', () => {
    // Defines a test suite. Two parameters are supported: test suite name and test suite function.
    beforeAll(() => {
      // Presets an action, which is performed only once before all test cases of the test suite start.
      // This API supports only one parameter: preset action function.
    })
    beforeEach(() => {
      // Presets an action, which is performed before each unit test case starts.
      // The number of execution times is the same as the number of test cases defined by **it**.
      // This API supports only one parameter: preset action function.
    })
    afterEach(() => {
      // Presets a clear action, which is performed after each unit test case ends.
      // The number of execution times is the same as the number of test cases defined by **it**.
      // This API supports only one parameter: clear action function.
    })
    afterAll(() => {
      // Presets a clear action, which is performed after all test cases of the test suite end.
      // This API supports only one parameter: clear action function.
    })
    it('bug1', 0, async () => {
      let doc = await parseIntoJsNode(errjson, 2)
      let str = printNode(doc)
      console.error(str)
    })
    it('bug2', 0, async () => {
      let doc = await parseIntoJsNode(err2, 2)
      let str = printNode(doc)
      console.error(str)
    })
    it('bugLatex1', 0, async () => {
      let md = `\\[
asd
\\]`
      let doc = await parseIntoJsNode(md, 2)
      let str = printNode(doc)
      console.error(md)
      console.error(str)
      let latex: JsNode = doc.getFirstChild()!
      expect(latex.getNodeType()).assertEqual("LatexMathBlock")
      expect(latex['latex']).assertEqual("asd")
    })
    it('bugLatex2', 0, async () => {
      let md = `$$
asd
$$`
      let doc = await parseIntoJsNode(md, 2)
      let str = printNode(doc)
      console.error(str)
      let latex: JsNode = doc.getFirstChild()!
      expect(latex.getNodeType()).assertEqual("LatexMathBlock")
      expect(latex['latex']).assertEqual("asd")
    })
    it('bugLatex3', 0, async () => {
      let md = `4. $$a$$ 应该渲染成 $b$`
      let doc = await parseIntoJsNode(md, 2)
      let str = printNode(doc)
      console.error(str)
      let p = doc.getFirstChild()?.getFirstChild()?.getFirstChild()
      let latexa: JsNode = p?.getFirstChild()!
      expect(latexa.getNodeType()).assertEqual("LatexMathNode")
      let latexb: JsNode = p?.getLastChild()!
      expect(latexb['latex']).assertEqual("b")
    })
    it('table1', 0, async () => {
      let md = `| h1 | h2 | h3 | h4 |
|:---|---:|:---:|
| a | b | c | d |`
      let doc = await parseIntoJsNode(md, 2)
      let str = printNode(doc)
      console.error(str)
      let table: JsNode = doc.getFirstChild()!
      let head: JsNode = doc.getFirstChild()?.getFirstChild()?.getFirstChild()!
      let body1: JsNode = doc.getFirstChild()?.getLastChild()?.getFirstChild()!
      expect(table.getNodeType()).assertEqual("TableBlock")
      expect(head.getFirstChild()!['alignment']).assertEqual("LEFT")
      expect(head.getFirstChild()!['width']).assertEqual(4)
      expect(head.getLastChild()!['alignment']).assertEqual(undefined)
      expect(head.getLastChild()!['width']).assertEqual(0)
      expect(head.getLastChild()?.getPrevious()!['alignment']).assertEqual("CENTER")
      expect(head.getLastChild()?.getPrevious()!['width']).assertEqual(5)
      expect(body1.getFirstChild()!['alignment']).assertEqual("LEFT")
      expect(body1.getFirstChild()!['width']).assertEqual(4)
      expect(body1.getLastChild()!['alignment']).assertEqual(undefined)
      expect(body1.getLastChild()!['width']).assertEqual(0)
      expect(body1.getLastChild()?.getPrevious()!['alignment']).assertEqual("CENTER")
      expect(body1.getLastChild()?.getPrevious()!['width']).assertEqual(5)
    })
    it('auto_link1', 0, async () => {
      let md = `在：https://biso6df2x4pkw.ok.kimi.link 啊在：https://biso6df2x4pkw.ok.kimi.link 啊`
      let doc = await parseIntoJsNode(md, 2)
      let str = printNode(doc)
      console.error(str)
      let p: JsNode = doc.getFirstChild()!
      let text0: JsNode = p.getFirstChild()!
      let link1: JsNode = text0.getNext()!
      let text2: JsNode = link1.getNext()!
      let link3: JsNode = text2.getNext()!
      let text4: JsNode = p.getLastChild()!
      expect(text0.getNodeType()).assertEqual("Text")
      expect(link1.getNodeType()).assertEqual("Link")
      expect(text2.getNodeType()).assertEqual("Text")
      expect(link3.getNodeType()).assertEqual("Link")
      expect(text4.getNodeType()).assertEqual("Text")
    })
    it('auto_link2', 0, async () => {
      let md = `已部署至https://7sncmf6ezkojw.ok.kimi.link，可直接访问查看完`
      let doc = await parseIntoJsNode(md, 2)
      let str = printNode(doc)
      console.error(str)
      let p: JsNode = doc.getFirstChild()!
      let text0: JsNode = p.getFirstChild()!
      let link1: JsNode = text0.getNext()!
      let text2: JsNode = link1.getNext()!
      expect(text0.getNodeType()).assertEqual("Text")
      expect(link1.getNodeType()).assertEqual("Link")
      expect(text2.getNodeType()).assertEqual("Text")
    })
  })
}
