@RestResource(urlMapping='/v1/sendMessage')
global with sharing class SendMessage_v1 {
    @HttpPost
    global static void sendMessage() {
        try {
            Utility.sendSuccessResponse(JSON.serialize(ContactService.processMessage(RestContext.request.requestBody.toString())));
        } catch (Exception ex) {
            if (ex instanceof GeneralException) {
                GeneralException ex1 = (GeneralException) ex;
                Utility.sendErrorResponse(ex1.getMessage(), ex1.statusCode);
                return;
            }
            Utility.sendErrorResponse(ex.getMessage());
        }
    }
}