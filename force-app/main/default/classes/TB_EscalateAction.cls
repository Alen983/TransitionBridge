public with sharing class TB_EscalateAction {
    public class Request {
        @InvocableVariable(label='Student Id' required=true)
        public Id studentId;
        @InvocableVariable(label='Reason' required=true)
        public String reason;
        @InvocableVariable(label='Triggered By Topic')
        public String triggeredBy;
        @InvocableVariable(label='Route To Queue')
        public String queueDeveloperName;
    }

    public class Response {
        @InvocableVariable
        public Id escalationLogId;
        @InvocableVariable
        public Id taskId;
        @InvocableVariable
        public String message;
        @InvocableVariable
        public Boolean success;
    }

    @InvocableMethod(
        label='Escalate To Human'
        description='Creates an Escalation Log and routes a Task to a counselor or case worker queue.'
        category='TransitionBridge'
    )
    public static List<Response> escalate(List<Request> requests) {
        List<Response> results = new List<Response>();
        for (Request req : requests) {
            Response res = new Response();
            res.success = false;
            Student__c student = TB_AgentService.getStudent(req.studentId);
            String queueName = String.isBlank(req.queueDeveloperName)
                ? resolveQueue(req.reason, req.triggeredBy)
                : req.queueDeveloperName;
            String queueLabel = queueName == 'Benefits_Counselors'
                ? 'Benefits Counselors'
                : 'Case Workers';
            Id queueId = TB_AgentService.getQueueId(queueName);

            Escalation_Log__c log = new Escalation_Log__c(
                Student__c = req.studentId,
                Triggered_By__c = String.isBlank(req.triggeredBy) ? 'Agent Escalation' : req.triggeredBy,
                Reason__c = req.reason,
                Assigned_To__c = queueLabel,
                Status__c = 'Open'
            );
            insert log;

            Task t = new Task(
                Subject = 'Escalation: ' + student.Name,
                Description =
                    'Student: ' + student.Name + '\n' +
                    'Reason: ' + req.reason + '\n' +
                    'Triggered by: ' + log.Triggered_By__c + '\n' +
                    'Escalation Log: ' + log.Id,
                Status = 'Not Started',
                Priority = 'High',
                ActivityDate = Date.today().addDays(1),
                WhatId = req.studentId
            );
            if (queueId != null) {
                t.OwnerId = queueId;
            }
            insert t;

            res.escalationLogId = log.Id;
            res.taskId = t.Id;
            res.success = true;
            res.message =
                'This requires professional judgment. I escalated to the ' + queueLabel +
                ' queue. Reason: ' + req.reason;
            TB_AgentService.logAction(req.studentId, 'Escalate To Human', res.message);
            results.add(res);
        }
        return results;
    }

    private static String resolveQueue(String reason, String triggeredBy) {
        String combined = (reason + ' ' + triggeredBy).toLowerCase();
        if (combined.contains('ssi') || combined.contains('benefit') || combined.contains('eligib')) {
            return 'Benefits_Counselors';
        }
        return 'Case_Workers';
    }
}
