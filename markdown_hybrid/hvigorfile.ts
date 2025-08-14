import { harTasks } from '@ohos/hvigor-ohos-plugin';
import { hvigor, HvigorNode, HvigorPlugin } from '@ohos/hvigor';
import { OhosHarContext, OhosPluginId, Target } from '@ohos/hvigor-ohos-plugin';

export default {
  system: harTasks, /* Built-in plugin of Hvigor. It cannot be modified. */
  plugins: [customPlugin()]       /* Custom plugin to extend the functionality of Hvigor. */
}

// 实现自定义插件
export function customPlugin(): HvigorPlugin {
  return {
    pluginId: 'customPlugin',
    context() {
      return {
        data: 'customPlugin'
      };
    },
    async apply(currentNode: HvigorNode): Promise<void> {
      hvigor.nodesEvaluated(async () => {
        // 注册doc任务
        docCopyTask(currentNode);
      });
    }
  };
}

function docCopyTask(currentNode: HvigorNode) {
  var node = currentNode
  // 获取har模块上下文信息
  const harContext = node.getContext(OhosPluginId.OHOS_HAR_PLUGIN) as OhosHarContext;
  const moduleName = harContext?.getModuleName();
  harContext?.targets((target: Target) => {
    const targetName = target.getTargetName();
    const outputPath = target.getBuildTargetOutputPath();
    node.registerTask({
      // 任务名称
      name: `${targetName}@docCopy`,
      // 任务执行逻辑主体函数
      run() {
        var fs = require('fs');
        fs.copyFileSync('README.md', `${moduleName}/README.md`);
        fs.copyFileSync('README.OpenSource', `${moduleName}/README.OpenSource`);
        fs.copyFileSync('LICENSE', `${moduleName}/LICENSE`);
        fs.copyFileSync('CHANGELOG.md', `${moduleName}/CHANGELOG.md`);
      },
      // 配置任务的后置任务依赖
      postDependencies: [`${targetName}@PackageHar`]
    });
  });
}