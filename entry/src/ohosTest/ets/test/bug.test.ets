import { hilog } from '@kit.PerformanceAnalysisKit';
import { describe, beforeAll, beforeEach, afterEach, afterAll, it, expect } from '@ohos/hypium';
import {
  InlineContentParser,
  ParsedInline,
  parseIntoJsNode,
  utf16Index2utf8Index,
  Scanner,
  utf8Index2utf16Index,
  printNode
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
  })
}
