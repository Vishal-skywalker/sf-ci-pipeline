public with sharing class ScratchOrgConfigService {
    public static Scratch_Org_Config__mdt getActiveConfig() {
        List<Scratch_Org_Config__mdt> configs = [
            SELECT
                GitHub_Owner__c,
                GitHub_Repo__c,
                GitHub_Token__c,
                GitHub_Ref__c,
                Is_Active__c
            FROM Scratch_Org_Config__mdt
            WHERE Is_Active__c = TRUE
            LIMIT 1
        ];

        return configs.isEmpty() ? null : configs[0];
    }
}
