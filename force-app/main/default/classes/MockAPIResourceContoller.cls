public without sharing class MockAPIResourceContoller {
    
    @AuraEnabled
    public static Resource__c getResource(String appId){
        Resource__c resource = new Resource__c();
        try {
            for (resource__c r : [SELECT ID, Name, AppID__c, Description__c, RequestURL__c, ContactEmail__c, ApiKey__c FROM Resource__c WHERE AppID__c = :appId LIMIT 1]) {
                resource = r;
            }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        return resource;
    }
    
    @AuraEnabled
    public static Resource__c upsertResource(Resource__c resource){
        try {
            upsert resource;
            for (resource__c r : [SELECT ID, Name, AppID__c, Description__c, RequestURL__c, ContactEmail__c, APIKey__c FROM Resource__c WHERE Id = :resource.Id LIMIT 1]) {
                resource = r;
            }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        return resource;
    }

    @AuraEnabled(cacheable=true)
    public static List<Resource__c> getResourcesByEmail(String email){
        try {
            return [SELECT ID, Name, AppID__c, Description__c, RequestURL__c, ContactEmail__c, APIKey__c FROM Resource__c WHERE ContactEmail__c = :email ORDER BY CreatedDate DESC LIMIT 50];
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

}