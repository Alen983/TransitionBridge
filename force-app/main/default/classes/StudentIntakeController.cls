public with sharing class StudentIntakeController {
    @AuraEnabled
    public static Id createStudent(
        String studentName,
        Date dateOfBirth,
        String school,
        String gradeStatus,
        Boolean iepFlag,
        String guardianName,
        String guardianContact
    ) {
        Student__c student = new Student__c(
            Name = studentName,
            Date_of_Birth__c = dateOfBirth,
            School__c = school,
            Grade_Status__c = gradeStatus,
            IEP_Flag__c = iepFlag != null ? iepFlag : false,
            Primary_Guardian_Name__c = guardianName,
            Primary_Guardian_Contact__c = guardianContact
        );
        insert student;
        return student.Id;
    }
}
