import {
  requireCJLib,
  CustomLib,
  JsNode as Node,
  parseIntoJsNode,
  ParsedInline,
  Scanner,
  InlineContentParser
} from "library"
import { hilog } from "@kit.PerformanceAnalysisKit";
import { systemDateTime } from "@kit.BasicServicesKit";

const cjLib: CustomLib = requireCJLib("libohos_app_cangjie_library.so") as CustomLib

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
      Text('md -> sendable Node')
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
          md = '0123a56a89'
          const myParser: InlineContentParser = new MyParser()
          let t0 = systemDateTime.getTime()
          let node = await parseIntoJsNode(md, myParser)
          let t1 = systemDateTime.getTime() - t0
          this.message = `${t1} \n${printNode(node)}`;
        })
      Text(this.message)
    }
    .height('100%')
    .width('100%')
  }
}

function printNode(node: Node | undefined): string {
  if (node) {
    let current: Node | undefined = node
    while (current?.getParent()) {
      current = current.getParent()
    }
    let builder = Array<string>()
    printNodeDep(current, 0, builder)
    return builder.join('')
  }
  return ''
}

function printNodeDep(node: Node | undefined, dep: number, builder: Array<string>) {
  if (node) {
    let str = node.toString()
    builder.push(`${' '.repeat(dep)}${str}\n`)
    let child = node.getFirstChild()
    printNodeDep(child, dep + 4, builder)
    let next = node.getNext()
    printNodeDep(next, dep, builder)
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
    let i = scanner.index + 1
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
      index: i,
      lineIndex: scanner.lineIndex
    }
  }
}