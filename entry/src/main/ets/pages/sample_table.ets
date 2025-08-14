/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2025-2025. All rights reserved.
 */
import { parseIntoJsNode, printNode } from '@cangjie-tpc/commonmark_hybrid';
import { systemDateTime } from '@kit.BasicServicesKit';
import { hilog } from '@kit.PerformanceAnalysisKit';

export async function sample_table(): Promise<string> {
  try {
    let t0 = systemDateTime.getTime()
    let node = await parseIntoJsNode(md)
    let t1 = systemDateTime.getTime() - t0
    return `${t1} \n${printNode(node)}`
  } catch (e) {
    hilog.error(0, 'mdebug', `${e}`)
    return 'fail'
  }
}

const md = `留一个占位空文件，后续方便MarkdownDemoPage调试

当然可以，以下是拼音和汉字的对应表格：

| 序号 | 拼音          | 汉字   |
|------|---------------|--------|
| 1    | zhī chuán     | 纸船   |
| 2    | sōng guǒ      | 松果   |
| 3    | zhī tiáo      | 纸条   |
| 4    | kě shì        | 可是   |
| 5    | dān shì       | 但是   |
| 6    | wú dǐng       | 屋顶   |
| 7    | hé hǎo        | 和好   |
| 8    | jǐn zhāng     | 紧张   |
| 9    | bǎo zhǐ       | 报纸   |
| 10   | qǔ xià        | 取下   |
| 11   | zhù fú        | 祝福   |
| 12   | zhā shǒu      | 招手   |
| 13   | cuò zhé       | 挫折   |
| 14   | zhǎng tiē     | 张贴   |
| 15   | xìng fú       | 幸福   |
| 16   | bái zhǐ       | 白纸   |
| 17   | tòng kǔ       | 痛苦   |
| 18   | qīng zhú      | 青竹   |
| 19   | xiǎo xióng    | 小熊   |
| 20   | zhuā jù       | 抓住   |
| 21   | zhèng cháo    | 正朝   |
| 22   | zhà shì       | 驮石   |
| 23   | chāo jí       | 超级   |
| 24   | sōng shǔ      | 松鼠   |
| 25   | shān dǐng     | 山顶   |
| 26   | kū tī         | 哭啼   |
| 27   | zhé fù        | 折服   |
| 28   | zhé zhǐ       | 折纸   |
| 29   | bāng wǎn      | 傍晚   |
| 30   | zhuā huò      | 抓住   |
| 31   | kù qì         | 哭泣   |
| 32   | dǎn fán       | 但凡   |
| 33   | cǎo méi       | 草莓   |
| 34   | zhé duàn      | 折断   |
| 35   | nán guò       | 难过   |
| 36   | piāo liú      | 漂流   |
| 37   | zhēng zhǎ     | 挣扎   |
| 38   | zhuā zhù      | 抓住   |
| 39   | zhuā shǒu     | 折手   |
| 40   | zhé le        | 折了   |
| 41   | zhuā fàn      | 抓饭   |
| 42   | zhé mò       | 折磨   |
| 43   | zhǔ jiù       | 主救   |
| 44   | bú dǎn       | 不敢   |
| 45   | dān yuán      | 单元   |
| 46   | zhā duǐ       | 炸堆   |
| 47   | zhǐ jìn       | 只进   |
| 48   | cháo nào     | 吵闹   |
| 49   | kuà zhǎng     | 夸张   |
| 50   | tā men liǎ    | 他们俩 |
| 51   | yuǎn yì      | 愿意   |
| 52   | zhuā jìn      | 抓住   |
| 53   | zhǐ piàn      | 纸片   |
| 54   | zhǔ shǒu      | 猪手   |
| 55   | kū sù         | 哭诉   |
| 56   | kāi zhǎng     | 开张   |
| 57   | kǔ liàn       | 苦难   |
| 58   | zhā gēn       | 扎根   |
| 59   | fēng zhēng    | 风筝   |

希望这个表格对你有帮助！`