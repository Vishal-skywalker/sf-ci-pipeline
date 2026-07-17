trigger CaseTrigger on Case (before insert, after insert) {
    if (Trigger.isBefore && Trigger.isInsert) {
        ScratchOrgCaseService.updateSubjectsForScratchOrgRequests(Trigger.new);
    }

    if (Trigger.isAfter && Trigger.isInsert) {
        ScratchOrgCaseService.enqueueScratchOrgWorkflows(Trigger.newMap.keySet());
    }
}
