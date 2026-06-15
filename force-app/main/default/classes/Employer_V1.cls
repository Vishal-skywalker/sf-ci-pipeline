@RestResource(urlMapping='/v1/employer')
global with sharing class Employer_V1 {
    @HttpGet
    global static void getSchool() {
        try {
            Utility.sendSuccessResponse(JSON.serialize(AccountService.getAccounts('Employer')));
        } catch (Exception ex) {
            Utility.sendErrorResponse(ex.getMessage());
        }
    }
}