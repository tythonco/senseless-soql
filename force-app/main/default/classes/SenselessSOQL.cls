public with sharing class SenselessSOQL {

    private static PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'SenselessSOQL'];
    // Tab setting name will be an id in an Anonymous Apex context while it will be an SObject name in a LWC context
    private static PermissionSetTabSetting tabSetting = [SELECT Id, Name FROM PermissionSetTabSetting WHERE ParentId = :ps.Id AND Visibility = 'DefaultOn' LIMIT 1];
    private static String np = [SELECT NamespacePrefix FROM Organization].NamespacePrefix;

    @AuraEnabled
    public static String findTabDefinitionByDurableId() {
        // Best for LWC context
        String log = '~~~ Searching for tab definition by DurableId ~~~\n';
        log += 'Searching for tab definition where TabDefinition.DurableId = PermissionSetTabSetting.Name (' + tabSetting.Name + ')\n';
        List<TabDefinition> tabDefs = [SELECT Id, SObjectName, DurableId, Label FROM TabDefinition WHERE DurableId = :tabSetting.Name LIMIT 1];
        if (!tabDefs.isEmpty()) {
            log += 'Found tab definition by matching TabDefinition.DurableId (' + tabDefs[0].DurableId + ') to PermissionSetTabSetting.Name (' + tabSetting.Name + ') even though ' + tabDefs[0].DurableId + ' != ' + tabSetting.Name + ' ¯\\_(ツ)_/¯\n';
            log += 'Searching for permission set tab setting where PermissionSetTabSetting.Name = ' + tabDefs[0].DurableId + '\n';
            PermissionSetTabSetting tabSetting2 = findPermissionSetTabSettingByDurableId(tabDefs[0].DurableId);
            if (tabSetting2 == null) {
                log += 'No permission set tab setting found where PermissionSetTabSetting.Name = ' + tabDefs[0].DurableId + ' so it seems the automagic only works one way... ¯\\_(ツ)_/¯\n';
                String customTabDefinitionPrefix = '01r'; // SObjectType CANNOT be queried within standard SOQL statement in Apex
                String tabDefinitionPrefix = '0KD'; // SObjectType CAN be queried within standard SOQL statement in Apex
                String customTabDefinitionIdFromTabDefId = tabDefs[0].DurableId.replace(tabDefinitionPrefix,customTabDefinitionPrefix).substring(0,15);
                log += 'Swapping the tab definition key prefix (' + tabDefinitionPrefix + ') in TabDefinition.DurableId (' + tabDefs[0].DurableId + ') with the key prefix for CustomTabDefinition (' + customTabDefinitionPrefix + ') to create a value of ' + customTabDefinitionIdFromTabDefId + '\n';
                log += 'Searching for permission set tab setting where PermissionSetTabSetting.Name = ' + customTabDefinitionIdFromTabDefId + '\n';
                List<PermissionSetTabSetting> tabSettingFromCustomTabDefId = [SELECT Id, Name FROM PermissionSetTabSetting WHERE Name = :customTabDefinitionIdFromTabDefId LIMIT 1];
                if (tabSettingFromCustomTabDefId.size() == 1) {
                    log += 'Found permission set tab setting by matching PermissionSetTabSetting.Name (' + tabSettingFromCustomTabDefId[0].Name + ') to ' + customTabDefinitionIdFromTabDefId + ' meaning swapping key prefixes works... (ツ)\n';
                }
            }
        } else {
            log +='No tab definition found where TabDefinition.DurableId = PermissionSetTabSetting.Name (' + tabSetting.Name + ')\n';
        }
        System.debug(log);
        return log + '\n';
    }

    @AuraEnabled
    public static String findTabDefinitionBySObjectName() {
        // Best for Anonymous Apex Context
        String log = '~~~ Searching for tab definition by SObjectName ~~~\n';
        log += 'Searching for tab definition where TabDefinition.SObjectName = PermissionSetTabSetting.Name (' + tabSetting.Name + ')\n';
        String tabSettingNameWithWildcardForNS = '%' + tabSetting.Name; // Ignore org namespace
        List<TabDefinition> tabDefs = [SELECT Id, SObjectName, DurableId, Label FROM TabDefinition WHERE SobjectName LIKE :tabSettingNameWithWildcardForNS LIMIT 1];
        if (!tabDefs.isEmpty()) {
            String tabDefSObjectName = np != null ? tabDefs[0].SObjectName.replace(np + '__','') : tabDefs[0].SObjectName;
            log += 'Found tab definition by matching TabDefinition.SObjectName (' + tabDefSObjectName + ') to PermissionSetTabSetting.Name (' + tabSetting.Name + ')\n';
            log += 'Now running inverse search by matching PermissionSetTabSetting.Name to TabDefinition.SObjectName (' + tabDefSObjectName + ')\n';
            PermissionSetTabSetting tabSetting2 = findPermissionSetTabSettingBySObjectName(tabDefSObjectName);
            if (tabSetting2 == null) {
                log += 'No permission set tab setting found where PermissionSetTabSetting.Name = TabDefinition.SObjectName (' + tabDefSObjectName + ')\n';
            } else {
                log += 'Found permission set tab setting by matching PermissionSetTabSetting.Name (' + tabSetting2.Name + ') to TabDefinition.SObjectName (' + tabDefSObjectName + ') meaning matching is bidirectional ✔\n';
            }
        }
        else {
            log += 'No tab definition found where TabDefinition.SObjectName = PermissionSetTabSetting.Name (' + tabSetting.Name + ')\n';
        }
        System.debug(log);
        return log + '\n';
    }

    private static PermissionSetTabSetting findPermissionSetTabSettingBySObjectName(String sObjectName) {
        List<PermissionSetTabSetting> tabSettings = [SELECT Id, Name FROM PermissionSetTabSetting WHERE Name = :sObjectName LIMIT 1];
        if (!tabSettings.isEmpty()) {
            return tabSettings[0];
        } else {
            return null;
        }
    }

    private static PermissionSetTabSetting findPermissionSetTabSettingByDurableId(String durableId) {
        List<PermissionSetTabSetting> tabSettings = [SELECT Id, Name FROM PermissionSetTabSetting WHERE Name = :durableId LIMIT 1];
        if (!tabSettings.isEmpty()) {
            return tabSettings[0];
        } else {
            return null;
        }
    }

}
