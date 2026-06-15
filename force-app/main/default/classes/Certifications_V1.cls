@RestResource(urlMapping='/v1/certifications')
global with sharing class Certifications_V1 {
    @HttpGet
    global static void getCertifications() {
        try {
            Utility.sendSuccessResponse(JSON.serialize(CertificationService.getAllCerts()));
        } catch (Exception ex) {
            Utility.sendErrorResponse(ex.getMessage());
        }
    }
}