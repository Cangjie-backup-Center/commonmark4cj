/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2025-2025. All rights reserved.
 */
import { sample_label } from "./sample_label";
import { util } from "@kit.ArkTS";
import { sample_spec } from "./sample_spec";
import { sample_custom_inline_parser } from "./sample_custom_inline_parser";
import { sample_parse2Json } from "./sample_parse2Json";
import { sample_parse2Json_bench } from "./sample_parse2Json_bench";
import { sample_oom } from "./sample_oom";
import { resourceManager } from "@kit.LocalizationKit";

let textDecoder = new util.TextDecoder();

@Entry
@Component
struct Index {
  @State message: string = 'Hello World';
  manager = resourceManager.getSystemResourceManager()
  spec: string = textDecoder.decodeToString(this.manager.getRawFileContentSync('spec.md'))
  testmd: string = textDecoder.decodeToString(this.manager.getRawFileContentSync('test.md'))

  msg(msg: string) {
    this.message = msg
  }

  build() {
    Scroll() {
      Column() {
        Button("sample:spec").fontSize($r('app.float.page_text_font_size')).onClick(async () => {
          this.message = await sample_spec(this.spec)
        })
        Button('sample:custom inline parser').fontSize($r('app.float.page_text_font_size')).onClick(async () => {
          this.message = await sample_custom_inline_parser()
        })
        Button('sample:label').fontSize($r('app.float.page_text_font_size')).onClick(async () => {
          this.message = await sample_label()
        })
        Button('sample:parse2Json').fontSize($r('app.float.page_text_font_size')).onClick(async () => {
          this.message = await sample_parse2Json(this.spec)
        })
        Button('sample: parse2Json bench').fontSize($r('app.float.page_text_font_size')).onClick(async () => {
          sample_parse2Json_bench(this.spec, this.msg)
        })
        Button('sample:oom').fontSize($r('app.float.page_text_font_size')).onClick(async () => {
          sample_oom(this.spec, this.msg)
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
