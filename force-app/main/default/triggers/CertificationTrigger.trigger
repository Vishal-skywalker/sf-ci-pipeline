trigger CertificationTrigger on Certification__c (after insert, after update, after delete) {
	GitHubWorkflowInvoker.enqueueJob('certifications');
}