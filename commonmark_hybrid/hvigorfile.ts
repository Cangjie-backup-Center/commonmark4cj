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
    // var pkgTask = node.getTaskByName(`${targetName}@PackageHar`)
    var artiTask = node.getTaskByName(`${targetName}@ProcessHarArtifacts`)
    // pkgTask.setEnable(false)
    // console.log(`ProcessHarArtifacts任务:\n${jsonStr(artiTask)}`)
    var dest = artiTask.task.taskTmpDir as string

    node.registerTask({
      // 任务名称
      name: `${targetName}@docCopy`,
      // 任务执行逻辑主体函数
      run() {
        var fs = require('fs');
        fs.copyFileSync('README.md', `${dest}/README.md`);
        fs.copyFileSync('README.OpenSource', `${dest}/README.OpenSource`);
        fs.copyFileSync('LICENSE', `${dest}/LICENSE`);
        fs.copyFileSync('CHANGELOG.md', `${dest}/CHANGELOG.md`);
      },
      // 配置前置任务依赖
      dependencies: [`${targetName}@ProcessHarArtifacts`],
      // 配置任务的后置任务依赖
      postDependencies: [`${targetName}@PackageHar`]
    });
  });
}

function jsonStr(obj) {
  const cache = new WeakSet(); // 存储已访问对象
  return JSON.stringify(obj, (key, value) => {
    if (typeof value === 'object' && value !== null) {
      if (cache.has(value)) return "[Circular]"; // 已访问则标记
      cache.add(value);
    }
    return key === 'parent' ? undefined : value; // 关键：清除parent属性
  })
}