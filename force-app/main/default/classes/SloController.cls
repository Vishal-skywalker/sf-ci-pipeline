public class SloController {
    public pageReference redirect() {
        return new PageReference(Site.getBaseUrl() + '/secur/logout.jsp');
    }
}