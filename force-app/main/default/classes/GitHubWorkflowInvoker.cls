public with sharing class GitHubWorkflowInvoker implements Queueable,Database.AllowsCallouts {
    
    static final String url = 'https://api.github.com/repos/Vishal-skywalker/profile-react-app/actions/workflows/refresh.yml/dispatches';
    string endpoint = null; 
    
    public static void enqueueJob(String ep, Integer delay) {
        System.enqueueJob(new GitHubWorkflowInvoker(ep), delay);
    }
    
    public static void enqueueJob(String ep) {
        System.enqueueJob(new GitHubWorkflowInvoker(ep));
    }
    
    private GitHubWorkflowInvoker(string ep) {
        endpoint = ep;
    }

    public void execute(System.QueueableContext qc) {
        if(string.isNotBlank(endPoint)) triggerWorkflow(endPoint);
    }
    
    public static void triggerWorkflow(String endpoint) {
        HttpRequest req = new HttpRequest();
        req.setEndpoint(url);
        req.setMethod('POST');
        req.setHeader('Authorization', 'Bearer ' + Label.GitHubToken);
        req.setHeader('Accept', 'application/vnd.github+json');
        req.setHeader('Content-Type', 'application/json');

        Map<String, Object> payload = new Map<String, Object>{
            'ref' => 'main',
            'inputs' => new Map<String, String>{ 'endpoint' => endpoint }
        };

        req.setBody(JSON.serialize(payload));

        Http http = new Http();
        try {
            HTTPResponse res = http.send(req);
            System.debug('GitHub Response: ' + res.getBody());
            if (res.getStatusCode() >= 300) {
                System.debug('GitHub API Error: ' + res.getStatus());
            }
        } catch (Exception e) {
            System.debug('GitHub callout failed: ' + e.getMessage());
        }
    }
}