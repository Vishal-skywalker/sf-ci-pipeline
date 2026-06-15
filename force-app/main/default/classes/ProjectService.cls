public without sharing class ProjectService {
    
    public static List<ProjectWrapper> getAllProjects() {
        List<ProjectWrapper> projectList = new List<ProjectWrapper>();
        for (Project__c p : [SELECT Id, Name, Name_t__c, Description_tal__c, StartDate_d__c, EndDate_d__c, TechStack_mp__c, URL_url__c FROM Project__c ORDER BY EndDate_d__c DESC NULLS FIRST]) {
            projectList.add(new ProjectWrapper(p));
        }
        return projectList;
    }

    public static ProjectWrapperExtended getProjectByUUID(String uuid) {
        List<Project__c> projectList = [SELECT Id, Name, Name_t__c, Description_tal__c, StartDate_d__c, EndDate_d__c, TechStack_mp__c, URL_url__c FROM Project__c WHERE Name =:uuid];
        if (projectList.isEmpty()) {
            throw new GeneralException('Project not found with UUID: ' + uuid, 404);
        }
        return new ProjectWrapperExtended(projectList[0]);
    }
    
    public static Set<String> getAllSkills() {
        Set<String> skills = new Set<String>();
        for (Project__c p : [SELECT Id, toLabel(TechStack_mp__c) FROM Project__c ORDER BY EndDate_d__c DESC NULLS FIRST]) {
            if (String.isNotBlank(p.TechStack_mp__c))
            	skills.addAll(p.TechStack_mp__c.split(';'));
        }
        return skills;
    }
    
    public virtual class ProjectWrapper {
        public String name;
        public String start_date;
        public String end_date;
        public String descrption;
        public String uuid;
        public String more_info;
        private ProjectWrapper(Project__c p) {
            uuid = p.Name;
            name = p.Name_t__c;
            descrption = p.Description_tal__c;
            more_info = p.URL_url__c;
            start_date = Utility.toMonthAndYear(p.StartDate_d__c);
            end_date = Utility.toMonthAndYear(p.EndDate_d__c);
        }
    }

    public class ProjectWrapperExtended extends ProjectWrapper{
        public List<String> tech_stack;
        private ProjectWrapperExtended(Project__c p) {
            super(p);
            tech_stack = String.isNotBlank(p.TechStack_mp__c) ? p.TechStack_mp__c.split(';') : new List<String>();
        }
    }
    
}