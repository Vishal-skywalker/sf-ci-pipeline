trigger ProjectTrigger2 on Project__c (after insert, after update, after delete) {
	GitHubWorkflowInvoker.enqueueJob('projects');
    GitHubWorkflowInvoker.enqueueJob('skills', 3);
}