/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2025-2025. All rights reserved.
 */
import { hilog } from "@kit.PerformanceAnalysisKit";
import { systemDateTime } from "@kit.BasicServicesKit";
import { sample_label } from "./sample_label";
import { router } from "@kit.ArkUI";
import { util } from "@kit.ArkTS";
import { sample_spec } from "./sample_spec";
import { sample_custom_inline_parser } from "./sample_custom_inline_parser";
import { sample_parse2Json } from "./sample_parse2Json";
import { sample_parse2Json_bench } from "./sample_parse2Json_bench";
import { OutOfMemoryError, SharedHeap_OOM } from "./sample_oom";
import { index_test } from "./index_test";
import { sample_footnote } from "./sample_footnote";
import { sample_cppcrash } from "./sample_cppcrash";
import { sample_table } from "./sample_table";
import { sample_moon } from "./sample_moon";
import { inc_cached } from "./sample_inc_cached";
import { sample_latex } from "./sample_latex";
import { sample_test2 } from "./sample_test2";
import { kimi, kimi_bench0, kimi_bench1 } from "./sample_kimi";

let textDecoder = new util.TextDecoder();

@Entry
@ComponentV2
struct Index {
  @Local message: string = 'Hello World';
  manager = getContext(this).resourceManager
  spec: string = textDecoder.decodeToString(this.manager.getRawFileContentSync('spec.md'))
  testmd: string = textDecoder.decodeToString(this.manager.getRawFileContentSync('test.md'))
  test2md: string = textDecoder.decodeToString(this.manager.getRawFileContentSync('test2.md'))
  cppcrash: string = textDecoder.decodeToString(this.manager.getRawFileContentSync('cppcrash.md'))
  parseerr: string = textDecoder.decodeToString(this.manager.getRawFileContentSync('parseerr.md'))
  latex: string = textDecoder.decodeToString(this.manager.getRawFileContentSync('latex.md'))

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
        Button('sample:OOM1').fontSize($r('app.float.page_text_font_size')).onClick(async () => {
          OutOfMemoryError(this)
        })
        Button('sample:OOM2').fontSize($r('app.float.page_text_font_size')).onClick(async () => {
          SharedHeap_OOM(this)
        })
        Button('sample:index_test').fontSize($r('app.float.page_text_font_size')).onClick(async () => {
          this.message = index_test()
        })
        Button('sample:footnote').fontSize($r('app.float.page_text_font_size')).onClick(async () => {
          this.message = await sample_footnote()
        })
        Button('sample:cppcrash').fontSize($r('app.float.page_text_font_size')).onClick(async () => {
          sample_cppcrash(this.cppcrash)
        })
        Button('goto cppcrash page').fontSize($r('app.float.page_text_font_size')).onClick(async () => {
          router.push({ url: 'pages/page_cppcrash' })
        })
        Button('goto typerr page').fontSize($r('app.float.page_text_font_size')).onClick(async () => {
          router.push({ url: 'pages/page_typerr' })
        })
        Button('sample: table').fontSize($r('app.float.page_text_font_size')).onClick(async () => {
          this.message = await sample_table()
        })
        Button('sample: moon').fontSize($r('app.float.page_text_font_size')).onClick(async () => {
          this.message = await sample_moon()
        })
        Button('sample: inc_cached').fontSize($r('app.float.page_text_font_size')).onClick(() => {
          let mdstr = 'aaa[^1^][^2^][^3^][^4^]\n[^1]:111\n[^]:\n[^2^]:'
          inc_cached(this.parseerr, this)
        })
        Button('sample: sample_latex').fontSize($r('app.float.page_text_font_size')).onClick(() => {
          sample_latex(this)
        })
        Button('sample: test2').fontSize($r('app.float.page_text_font_size')).onClick(() => {
          sample_test2(this)
        })
        Button('sample: kimi').fontSize($r('app.float.page_text_font_size')).onClick(() => {
          kimi(this)
        })
        Button('bench parse0').fontSize($r('app.float.page_text_font_size')).onClick(() => {
          kimi_bench0(this)
        })
        Button('bench HybridParser').fontSize($r('app.float.page_text_font_size')).onClick(() => {
          kimi_bench1(this)
        })
        Text(this.message)
      }
    }
    // 设置滚动方法
    .scrollable(ScrollDirection.Vertical)
    // 设置滚动条状态
    .scrollBar(BarState.Auto)
  }
}