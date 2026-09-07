public with sharing class TB_QueryDeadlinesAction {
    public class Request {
        @InvocableVariable(label='Student Id' required=true)
        public Id studentId;
        @InvocableVariable(label='Days Ahead')
        public Integer daysAhead;
    }

    public class Response {
        @InvocableVariable
        public String message;
        @InvocableVariable
        public Boolean success;
    }

    @InvocableMethod(
        label='Query Upcoming Deadlines'
        description='Returns upcoming deadline milestones for a student within the next N days.'
        category='TransitionBridge'
    )
    public static List<Response> queryDeadlines(List<Request> requests) {
        List<Response> results = new List<Response>();
        for (Request req : requests) {
            Response res = new Response();
            Integer horizon = req.daysAhead == null || req.daysAhead <= 0 ? 90 : req.daysAhead;
            Student__c student = TB_AgentService.getStudent(req.studentId);
            Date endDate = Date.today().addDays(horizon);
            List<Deadline_Milestone__c> deadlines = [
                SELECT Description__c, Deadline_Date__c, Type__c, Status__c
                FROM Deadline_Milestone__c
                WHERE Student__c = :req.studentId
                AND Status__c = 'Upcoming'
                AND Deadline_Date__c <= :endDate
                ORDER BY Deadline_Date__c ASC
            ];
            if (deadlines.isEmpty()) {
                res.message = 'No upcoming deadlines in the next ' + horizon + ' days for ' + student.Name + '.';
            } else {
                List<String> lines = new List<String>();
                lines.add('Upcoming deadlines for ' + student.Name + ' (next ' + horizon + ' days):');
                for (Deadline_Milestone__c d : deadlines) {
                    lines.add(
                        '- ' + d.Description__c + ' on ' + String.valueOf(d.Deadline_Date__c) +
                        ' (' + d.Type__c + ', ' + d.Status__c + ')'
                    );
                }
                res.message = String.join(lines, '\n');
            }
            res.success = true;
            TB_AgentService.logAction(req.studentId, 'Query Upcoming Deadlines', res.message);
            results.add(res);
        }
        return results;
    }
}
