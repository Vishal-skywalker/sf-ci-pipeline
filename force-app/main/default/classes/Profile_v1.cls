@RestResource(urlMapping='/v1/profile')
global with sharing class Profile_v1 {
    @HttpGet
    global static void getProfile() {
        try {
            Utility.sendSuccessResponse(JSON.serialize(ContactService.getProfile()));
        } catch (Exception ex) {
            Utility.sendErrorResponse(ex.getMessage());
        }
    }
}