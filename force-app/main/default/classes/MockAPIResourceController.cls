public without sharing class MockAPIResourceController {
    
    @AuraEnabled
    public static Resource__c getResource(String appId){
        Resource__c resource;
        try {
            for (resource__c r : [SELECT ID, Name, AppID__c, Description__c, RequestURL__c, ContactEmail__c, ApiKey__c,
                    (SELECT Id, Name, Path__c, Method__c, ContentType__c, Body__c, 
                        StatusCode__c, Resource__c, Resource__r.RequestURL__c 
                        FROM Paths__r ORDER BY CreatedDate DESC)
                    FROM Resource__c WHERE AppID__c = :appId LIMIT 1]) {
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
            for (resource__c r : [SELECT ID, Name, AppID__c, Description__c, RequestURL__c, ContactEmail__c, ApiKey__c,
                    (SELECT Id, Name, Path__c, Method__c, ContentType__c, Body__c, 
                        StatusCode__c, Resource__c, Resource__r.RequestURL__c 
                        FROM Paths__r ORDER BY CreatedDate DESC)
                    FROM Resource__c WHERE Id = :resource.Id LIMIT 1]) {
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

    @AuraEnabled
    public static void deleteResource(Id resourceId){
        try {
            delete new Resource__c(Id = resourceId);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
}