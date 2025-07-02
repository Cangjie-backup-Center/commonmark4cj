/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */
import {
  requireCJLib,
  CustomLib,
  JsNode as Node,
  parseIntoJsNode,
  ParsedInline,
  Scanner,
  InlineContentParser,
  printNode
} from "@cangjie-tpc/markdown_hybrid"
import { hilog } from "@kit.PerformanceAnalysisKit";
import { systemDateTime } from "@kit.BasicServicesKit";
import { sample_label } from "./sample_label";

const cjLib: CustomLib = requireCJLib("libmarkdown_hybrid.so") as CustomLib

@Entry
@Component
struct Index {
  @State message: string = 'Hello World';

  build() {
    Column() {
      // Text(this.message)
      //   .id('HelloWorld')
      //   .fontSize($r('app.float.page_text_font_size'))
      //   .fontWeight(FontWeight.Bold)
      //   .alignRules({
      //     center: { anchor: '__container__', align: VerticalAlign.Center },
      //     middle: { anchor: '__container__', align: HorizontalAlign.Center }
      //   })
      //   .onClick(async () => {
      //     let context = getContext(this)
      //     let manager = context.resourceManager
      //     let content = manager.getRawFileContentSync('spec.md')
      //     let md = utf8arr2string(content)
      //     console.error(md.length.toString())
      //     let node = await cjLib.parseIntoCjNode(md)
      //     printNode(node)
      //     this.message = 'Welcome' + node.toString();
      //   })
      Text('sample:custom inline parser')
        .fontSize($r('app.float.page_text_font_size'))
        .fontWeight(FontWeight.Bold)
        .alignRules({
          center: { anchor: '__container__', align: VerticalAlign.Center },
          middle: { anchor: '__container__', align: HorizontalAlign.Center }
        })
        .onClick(async () => {
          let context = getContext(this)
          let manager = context.resourceManager
          let content = manager.getRawFileContentSync('spec.md')
          let md = utf8arr2string(content)
          md = '我0123a56a89'
          const myParser: InlineContentParser = new MyParser()
          let t0 = systemDateTime.getTime()
          parseIntoJsNode(md, myParser).then(node => {
            let t1 = systemDateTime.getTime() - t0
            let nodeTreeStr = printNode(node)
            hilog.error(0, '', nodeTreeStr)
            this.message = `${t1} \n${nodeTreeStr}`;
          })
        })
      Text('sample:label')
        .fontSize($r('app.float.page_text_font_size'))
        .fontWeight(FontWeight.Bold)
        .alignRules({
          center: { anchor: '__container__', align: VerticalAlign.Center },
          middle: { anchor: '__container__', align: HorizontalAlign.Center }
        })
        .onClick(async () => {
          setTimeout(() => {
            sample_label().then(str => {
              this.message = `${str}`;
            })
          })
        })
      Text(this.message)
    }
    .height('100%')
    .width('100%')
  }
}

function utf8arr2string(arr: Uint8Array): string {
  let str = '';
  for (let i = 0; i < arr.length; i++) {
    str += String.fromCharCode(arr[i]);
  }
  return str
}

class MyParser implements InlineContentParser {
  getTriggerCharacters(): Array<string> {
    return ['a']
  }

  tryParse(scanner: Scanner): undefined | ParsedInline {
    // hilog.error(0, 'mod', 'MyParser.tryParse')
    let str = ''
    let line = scanner.lines[scanner.lineIndex]
    let i = scanner.runeIndex + 1
    for (; i < line.length; i++) {
      if (line[i] == 'a') {
        i++
        break
      }
      str += line[i]
    }
    let props = new Map<string, string>()
    props.set('str', str)
    return {
      node: {
        nodeType: 'anode',
        props: props
      },
      runeIndex: i,
      lineIndex: scanner.lineIndex
    }
  }
}