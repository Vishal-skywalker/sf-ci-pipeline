public without sharing class CertificationService {
    public static string SITE_URL = 'https://personalproject6-dev-ed.develop.my.salesforce-sites.com/api/resource/' + DateTime.now().getTime() + '/badges/';
    public static List<CertWrapper> getAllCerts() {
        List<CertWrapper> wpList = new List<CertWrapper>();
        for (Certification__c c : [SELECT Id, Title_t__c, BadgeName_t__c, IssuedOn_d__c FROM Certification__c ORDER BY IssuedOn_d__c DESC]) {
            wpList.add(new CertWrapper(c));
        }
        return wpList;
    }
    public class CertWrapper {
        public String title;
        public String badge_url;
        public String issued_date;
        
        public CertWrapper(Certification__c a) {
            title = a.Title_t__c;
            issued_date = a.IssuedOn_d__c == null ? '' : Utility.toMonthAndYear(a.IssuedOn_d__c);
            badge_url = String.isNotBlank(a.BadgeName_t__c) ? SITE_URL + a.BadgeName_t__c : '';
        }
    }
}