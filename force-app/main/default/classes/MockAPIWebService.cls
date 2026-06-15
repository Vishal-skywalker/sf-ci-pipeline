@RestResource (urlMapping='/api/*/*')
global without sharing class MockAPIWebService {
    
    @HttpGet
    global static void doGet() {
        respond();
    }
    
    @HttpPost
    global static void doPost() {
        respond();
    }
    
    @HttpPut
    global static void doPut() {
        respond();
    }
    
    @HttpDelete
    global static void doDelete() {
        respond();
    }
    
    @HttpPatch
    global static void doPatch() {
        respond();
    }
    
    private static void respond() {
        try {
            new MockResource(RestContext.request, RestContext.response).respond();
        } catch (Exception e) {
            if (e instanceOf GeneralException) {
                Utility.sendErrorResponse((GeneralException)e);
            } else {
                Utility.sendErrorResponse(e);
            }
        }
    }
    
    public without sharing class MockResource {
        public String appId { get; private set; }
        public String subpath { get; private set; }
        public String apiKey { get; private set; }
        public String method { get; private set; }
        public RestResponse res { get; private set; }
        private Resource__c resource;
        
        public MockResource(RestRequest req, RestResponse res) {
            List<String> pathParts = req.requestURI.replace('/api/', '').split('/');
            if (pathParts.size() > 0) {
                appId = pathParts[0];
                pathParts.remove(0);
            }
            if (pathParts.size() > 0) {
                subpath = String.join(pathParts, '/');
            }
            method = req.httpMethod;
            this.res = res;
            apiKey = extractApiKey(req);
            validate();
        }
        
        private String extractApiKey(RestRequest req) {
            List<String> headerKeys = new List<String>{'x-api-key', 'X-API-Key', 'X-API-KEY'};
            List<String> paramKeys = new List<String>{'apiKey', 'apikey'};
            
            for (String key : headerKeys) {
                if (req.headers.containsKey(key)) {
                    return req.headers.get(key);
                }
            }
            
            for (String key : paramKeys) {
                if (req.params.containsKey(key)) {
                    return req.params.get(key);
                }
            }
            
            return null;
        }
        
        private void validate() {
            for (Resource__c r : [SELECT Id, Name, APIKey__c FROM Resource__c WHERE AppID__c = :appId LIMIT 1]) {
                resource = r;
            }
            if (resource == null) {
                throw new GeneralException(Label.NotFound, Constants.HTTP_NOT_FOUND);
            }
            if (String.isNotBlank(resource.APIKey__c) && resource.APIKey__c != apiKey) {
                throw new GeneralException(Label.Unauthorised, Constants.HTTP_UNAUTHORIZED);
            }
        }
        
        public void respond() {
            if (String.isBlank(subpath)) {
                Utility.sendSuccessResponse(String.format(Label.NoSubpath, new List<String>{Label.BaseURL.replace('/services/apexrest/api/', '/s/resource?appId=' + appId)}));
                return;
            }
            Boolean isSubpathValid = false;
            for (Path__c p : [SELECT Id, Name, Path__c, Method__c, ContentType__c, Body__c, StatusCode__c FROM Path__c WHERE Resource__c = :resource.Id AND Path__c = :subpath]) {
                isSubpathValid = true;
                if (p.Method__c == method) {
                    setResponse(p, res);
                    return;
                }
            }
            if (isSubpathValid) {
                Utility.sendErrorResponse(Label.InvalidMethod, Constants.HTTP_NOT_ALLOWED);
            } else {
                Utility.sendErrorResponse(Label.NotFound, Constants.HTTP_NOT_FOUND);
            }
        }
        
        public void setResponse(Path__c path, RestResponse res) {
            if (String.isNotBlank(path.Body__c)) {
                res.responseBody = Blob.valueOf(path.Body__c);
            }
            res.statusCode = Integer.valueOf(path.StatusCode__c);
            if (String.isNotBlank(path.ContentType__c)) {
                res.addHeader('Content-Type', path.ContentType__c);
            } else {
                res.addHeader('Content-Type', 'application/json');
            }
        }
    }
    
}