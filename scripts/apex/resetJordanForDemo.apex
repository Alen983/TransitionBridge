// Reset Jordan Reyes VR enrollment to "Not Started" for gap-analysis demo retest
Student__c jordan = [SELECT Id FROM Student__c WHERE Name = 'Jordan Reyes' LIMIT 1];
List<Program_Enrollment__c> enrollments = [
    SELECT Id, Status__c, Referral_Date__c
    FROM Program_Enrollment__c
    WHERE Student__c = :jordan.Id AND Program__r.Name = 'Vocational Rehabilitation'
];
for (Program_Enrollment__c e : enrollments) {
    e.Status__c = 'Not Started';
    e.Referral_Date__c = null;
}
update enrollments;
System.debug('Jordan VR enrollment reset to Not Started for demo.');
