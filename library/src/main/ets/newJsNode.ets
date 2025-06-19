import { JsNode } from './JsNode'

@Concurrent
export function newJsNode():JsNode {
  return new JsNode()
}