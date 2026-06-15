public without sharing class AccountService {
    public AccountService() {
        
    }
    
    public static List<AccountWrapper> getAccounts(String recordType) {
        List<AccountWrapper> wpList = new List<AccountWrapper>();
        for (Account acc : [SELECT Id, Name, StartDate_d__c, EndDate_d__c, ID_t__c, Info_t__c,
                            Description FROM Account WHERE RecordType.DeveloperName = :recordType ORDER BY EndDate_d__c DESC]) {
            wpList.add(new AccountWrapper(acc));
        }
        return wpList;
    }
    
    public class AccountWrapper {
        public String name;
        public String start_date;
        public String end_date;
        public String addition_info;
        public String uuid;
        public String info;
        
        public AccountWrapper(Account a) {
            name = a.Name;
            addition_info = a.Description;
            start_date = a.StartDate_d__c == null ? '' : Utility.toMonthAndYear(a.StartDate_d__c);
            end_date = a.EndDate_d__c == null ? '' : Utility.toMonthAndYear(a.EndDate_d__c);
            uuid = a.ID_t__c;
            info = a.Info_t__c;
        }
    }
    
    public static void push(List<Account> newList) {
        Set<String> endPoints = new Set<String>();
        Map<Id, String> recordTypeMap = new Map<Id, String>{
            Utility.getRecordTypeId(Account.SobjectType, 'Employer') => 'employer',
            Utility.getRecordTypeId(Account.SobjectType, 'School') => 'school'
        };
        for(Account a: newList) {
            if(a.RecordTypeId != null && recordTypeMap.containsKey(a.RecordTypeId)) {
                endPoints.add(recordTypeMap.get(a.RecordTypeId));
            }
            if(endPoints.size() == recordTypeMap.size()) {
                break;
            }
        }
        for(String e : endPoints) {
            GitHubWorkflowInvoker.enqueueJob(e);
        }
    }
}