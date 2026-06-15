@RestResource(urlMapping='/v1/skills')
global with sharing class Skills_v1 {
    @HttpGet
    global static void getSchool() {
        try {
            Utility.sendSuccessResponse(JSON.serialize(ProjectService.getAllSkills()));
        } catch (Exception ex) {
            Utility.sendErrorResponse(ex.getMessage());
        }
    }
}