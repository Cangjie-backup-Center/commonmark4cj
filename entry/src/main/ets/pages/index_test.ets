/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2025-2025. All rights reserved.
 */
import { Scanner, utf8Index2utf16Index } from '@cangjie-tpc/commonmark';
import { hilog } from '@kit.PerformanceAnalysisKit';

export function index_test(): string {
  try {
    let scanner = { lines: ['我a'], lineIndex: 0, index: 3 } as Scanner
    return utf8Index2utf16Index(scanner.lines[scanner.lineIndex], scanner.index).toString()
  } catch (e) {
    hilog.error(0, 'mdebug', `${e}`)
    return 'fail'
  }
}