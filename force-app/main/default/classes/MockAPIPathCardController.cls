public without sharing class MockAPIPathCardController {
    
    @AuraEnabled
    public static Path__c upsertPath(Path__c path){
        try {
            upsert path;
            for (Path__c p : [SELECT Id, Name, Path__c, Method__c, ContentType__c, 
                Body__c, StatusCode__c, Resource__c, Resource__r.RequestURL__c 
                FROM Path__c WHERE Id =: path.Id LIMIT 1]) {
                return p;
            }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        return null;
    }
    
    @AuraEnabled
    public static void deletePath(Id pathId){
        try {
            delete new Path__c(Id = pathId);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}