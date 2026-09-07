public with sharing class TB_AgentService {
    public static void logAction(Id studentId, String actionTaken, String details) {
        insert new Agent_Action_Log__c(
            Student__c = studentId,
            Action_Taken__c = actionTaken,
            Details__c = details,
            Timestamp__c = System.now()
        );
    }

    public static Id getQueueId(String developerName) {
        List<Group> queues = [
            SELECT Id
            FROM Group
            WHERE Type = 'Queue' AND DeveloperName = :developerName
            LIMIT 1
        ];
        return queues.isEmpty() ? null : queues[0].Id;
    }

    public static Student__c getStudent(Id studentId) {
        return [
            SELECT Id, Name, Date_of_Birth__c, School__c, Grade_Status__c, IEP_Flag__c
            FROM Student__c
            WHERE Id = :studentId
            LIMIT 1
        ];
    }

    public static Program__c findProgram(String programName) {
        List<Program__c> programs = [
            SELECT Id, Name, Typical_Referral_Lead_Time_Days__c
            FROM Program__c
            WHERE Name = :programName
            LIMIT 1
        ];
        if (!programs.isEmpty()) {
            return programs[0];
        }
        programs = [
            SELECT Id, Name, Typical_Referral_Lead_Time_Days__c
            FROM Program__c
            WHERE Name LIKE :('%' + programName + '%')
            LIMIT 1
        ];
        return programs.isEmpty() ? null : programs[0];
    }

    public static Integer defaultLeadTimeDays() {
        return 90;
    }
}
