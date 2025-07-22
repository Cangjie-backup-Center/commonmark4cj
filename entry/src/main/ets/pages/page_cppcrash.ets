/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2025-2025. All rights reserved.
 */
import { hilog } from "@kit.PerformanceAnalysisKit";
import { util } from "@kit.ArkTS";
import { parseToJsNode } from "./sample_cppcrash";

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
          cppcrash(this.cppcrash)
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

async function cppcrash(markdownString: string): Promise<void> {
  // 间隔10ms 解析100次 无限
  let tid = setInterval(async () => {
    for (let i = 0; i < 100; i++) {
      await parseToJsNode(markdownString)
    }
  }, 10)
}