@RestResource(urlMapping='/v1/projects/*')
global with sharing class Projects_v1 {
    @HttpGet
    global static void getSchool() {
        try {
            RestRequest req = RestContext.request;
            String uuid = req.requestURI.substringAfter('/v1/projects/');
            if (String.isNotBlank(uuid)) {
                Utility.sendSuccessResponse(JSON.serialize(ProjectService.getProjectByUUID(uuid)));
            } else {
                Utility.sendSuccessResponse(JSON.serialize(ProjectService.getAllProjects()));
            }
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