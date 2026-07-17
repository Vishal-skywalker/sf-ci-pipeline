public with sharing class ScratchOrgCaseService {
    public static final String SCRATCH_ORG_REASON = 'New Scratch Org';

    public static void updateSubjectsForScratchOrgRequests(List<Case> cases) {
        User creator = [
            SELECT Name, Email
            FROM User
            WHERE Id = :UserInfo.getUserId()
            LIMIT 1
        ];
        String timestamp = Datetime.now().format(
            'yyyy-MM-dd HH:mm',
            UserInfo.getTimeZone().getID()
        );

        for (Case requestCase : cases) {
            if (requestCase.Reason == SCRATCH_ORG_REASON) {
                requestCase.Subject =
                    'Scratch Org Request by ' + creator.Name + ' - ' + timestamp;
            }
        }
    }

    public static void enqueueScratchOrgWorkflows(Set<Id> caseIds) {
        List<Case> scratchOrgCases = [
            SELECT Id, Reason, CreatedBy.Name, CreatedBy.Email
            FROM Case
            WHERE Id IN :caseIds AND Reason = :SCRATCH_ORG_REASON
        ];

        for (Case requestCase : scratchOrgCases) {
            ScratchOrgWorkflowInvoker.enqueueJob(
                requestCase.Id,
                requestCase.CreatedBy.Email,
                requestCase.CreatedBy.Name
            );
        }
    }
}
