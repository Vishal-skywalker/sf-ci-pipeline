public with sharing class ScratchOrgWorkflowInvoker implements Queueable, Database.AllowsCallouts {
    private static final String EVENT_TYPE = 'scratch-org-request';

    private final Id caseId;
    private final String adminEmail;
    private final String createdByName;

    public static void enqueueJob(Id caseId, String adminEmail, String createdByName) {
        System.enqueueJob(new ScratchOrgWorkflowInvoker(caseId, adminEmail, createdByName));
    }

    private ScratchOrgWorkflowInvoker(Id caseId, String adminEmail, String createdByName) {
        this.caseId = caseId;
        this.adminEmail = adminEmail;
        this.createdByName = createdByName;
    }

    public void execute(System.QueueableContext context) {
        Scratch_Org_Config__mdt config = ScratchOrgConfigService.getActiveConfig();
        if (config == null) {
            System.debug(LoggingLevel.ERROR, 'No active Scratch Org Config record found.');
            return;
        }

        triggerWorkflow(config);
    }

    private void triggerWorkflow(Scratch_Org_Config__mdt config) {
        String endpoint =
            'https://api.github.com/repos/' +
            config.GitHub_Owner__c +
            '/' +
            config.GitHub_Repo__c +
            '/dispatches';

        Map<String, Object> clientPayload = new Map<String, Object>{
            'case_id' => caseId,
            'admin_email' => adminEmail,
            'created_by_name' => createdByName
        };

        Map<String, Object> payload = new Map<String, Object>{
            'event_type' => EVENT_TYPE,
            'client_payload' => clientPayload
        };

        HttpRequest request = new HttpRequest();
        request.setEndpoint(endpoint);
        request.setMethod(Constants.HTTP_POST);
        request.setHeader('Authorization', 'Bearer ' + config.GitHub_Token__c);
        request.setHeader('Accept', 'application/vnd.github+json');
        request.setHeader('Content-Type', 'application/json');
        request.setBody(JSON.serialize(payload));

        Http http = new Http();
        try {
            HttpResponse response = http.send(request);
            System.debug('GitHub Response: ' + response.getBody());

            if (response.getStatusCode() >= 300) {
                System.debug(
                    LoggingLevel.ERROR,
                    'GitHub API Error: ' + response.getStatus() + ' ' + response.getBody()
                );
            }
        } catch (Exception ex) {
            System.debug(LoggingLevel.ERROR, 'GitHub callout failed: ' + ex.getMessage());
        }
    }
}
