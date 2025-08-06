/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2025-2025. All rights reserved.
 */
import { hilog } from "@kit.PerformanceAnalysisKit";
import { taskpool, util } from "@kit.ArkTS";
import { parseToJsNode } from "./sample_cppcrash";
import { JsNode, printNode } from "@cangjie-tpc/commonmark";

let textDecoder = new util.TextDecoder();

@Entry
@Component
struct PageCppcrash {
  @State message: string = 'Hello World';
  manager = getContext(this).resourceManager
  cppcrash: string = textDecoder.decodeToString(this.manager.getRawFileContentSync('cppcrash.md'))

  msg(msg: string) {
    this.message = msg
  }

  build() {
    Scroll() {
      Column() {
        Button('sample:cppcrash').fontSize($r('app.float.page_text_font_size')).onClick(async () => {
          let markdownString = this.cppcrash
          let i = 0
          let tid = setInterval(async () => {
            let str = markdownString.slice(0, i)
            let mdnode = await typerr(str)
            let mdstr = printNode(mdnode)
            this.message = mdstr
            i++
            if (i >= markdownString.length) {
              clearInterval(tid)
            }
          }, 10)
        })
        Text(this.message)
      }
    }
    // 设置滚动方法
    .scrollable(ScrollDirection.Vertical)
    // 设置滚动条状态
    .scrollBar(BarState.Off)
  }
}

@Concurrent
async function parseToJsNodeConcurrent(markdownString: string): Promise<JsNode> {
  return await parseToJsNode(markdownString)
}

async function typerr(markdownString: string): Promise<JsNode> {
  return taskpool.execute(parseToJsNodeConcurrent, markdownString) as Promise<JsNode>
}

