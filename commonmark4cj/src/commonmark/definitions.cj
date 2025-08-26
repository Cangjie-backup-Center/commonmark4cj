/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2025-2025. All rights resvered.
 */
package commonmark4cj.commonmark

public class Definitions {
    private let definitionsByType: Map<String, DefinitionMap> = HashMap()

    public func addDefinitions(definitionMap: DefinitionMap) {
        var existingMap = getMap(definitionMap.getType())
        if (let Some(v) <- existingMap) {
            v.addAll(definitionMap)
        } else {
            definitionsByType.add(definitionMap.getType(), definitionMap)
        }
    }

    public func getDefinition(typ: String, label: String): ?LinkReferenceDefinition {
        var definitionMap = getMap(typ) ?? return None
        return definitionMap.get(label)
    }

    private func getMap(typ: String): ?DefinitionMap {
        //noinspection unchecked
        return definitionsByType.get(typ)
    }
}
