@RestResource(urlMapping='/v1/schools')
global with sharing class Schools_v1 {
    @HttpGet
    global static void getSchool() {
        try {
            Utility.sendSuccessResponse(JSON.serialize(AccountService.getAccounts('School')));
        } catch (Exception ex) {
            Utility.sendErrorResponse(ex.getMessage());
        }
    }
}