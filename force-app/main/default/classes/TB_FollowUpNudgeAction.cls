public with sharing class TB_FollowUpNudgeAction {
    public class Request {
        @InvocableVariable(label='Student Id' required=true)
        public Id studentId;
        @InvocableVariable(label='Stale Days')
        public Integer staleDays;
    }

    public class Response {
        @InvocableVariable
        public Id taskId;
        @InvocableVariable
        public String message;
        @InvocableVariable
        public Boolean success;
    }

    @InvocableMethod(
        label='Follow Up Nudge'
        description='Creates a follow-up task when a referral has been sent but is stale.'
        category='TransitionBridge'
    )
    public static List<Response> followUpNudge(List<Request> requests) {
        List<Response> results = new List<Response>();
        for (Request req : requests) {
            Response res = new Response();
            res.success = false;
            Integer threshold = req.staleDays == null || req.staleDays <= 0 ? 14 : req.staleDays;
            Date cutoff = Date.today().addDays(-threshold);
            Student__c student = TB_AgentService.getStudent(req.studentId);
            List<Program_Enrollment__c> stale = [
                SELECT Id, Program__r.Name, Assigned_Contact__c, Last_Activity_Date__c
                FROM Program_Enrollment__c
                WHERE Student__c = :req.studentId
                AND Status__c = 'Referral Sent'
                AND (Last_Activity_Date__c = null OR Last_Activity_Date__c < :cutoff)
                LIMIT 1
            ];
            if (stale.isEmpty()) {
                res.message = 'No stale Referral Sent enrollments found for ' + student.Name + '.';
                res.success = true;
                results.add(res);
                continue;
            }
            Program_Enrollment__c enrollment = stale[0];
            String assignee = String.isBlank(enrollment.Assigned_Contact__c)
                ? 'the assigned program contact'
                : enrollment.Assigned_Contact__c;
            Task t = new Task(
                Subject = 'Follow up: ' + enrollment.Program__r.Name + ' referral for ' + student.Name,
                Description =
                    'Referral sent for ' + student.Name + ' to ' + enrollment.Program__r.Name +
                    ' has had no activity in ' + threshold + '+ days. Please follow up with ' + assignee + '.',
                Status = 'Not Started',
                Priority = 'Normal',
                ActivityDate = Date.today().addDays(3),
                WhatId = req.studentId
            );
            insert t;
            res.taskId = t.Id;
            res.success = true;
            res.message = 'Follow-up task created to nudge ' + assignee + ' about the ' + enrollment.Program__r.Name + ' referral.';
            TB_AgentService.logAction(req.studentId, 'Follow Up Nudge', res.message);
            results.add(res);
        }
        return results;
    }
}
