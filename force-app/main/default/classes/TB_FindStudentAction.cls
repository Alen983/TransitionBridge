public with sharing class TB_FindStudentAction {
    public class Request {
        @InvocableVariable(label='Student Name' required=true)
        public String studentName;
    }

    public class Response {
        @InvocableVariable
        public Id studentId;
        @InvocableVariable
        public String studentName;
        @InvocableVariable
        public String message;
        @InvocableVariable
        public Boolean success;
    }

    @InvocableMethod(
        label='Find Student'
        description='Looks up a Student record by name for use in other agent actions.'
        category='TransitionBridge'
    )
    public static List<Response> findStudent(List<Request> requests) {
        List<Response> results = new List<Response>();
        for (Request req : requests) {
            Response res = new Response();
            res.success = false;
            if (String.isBlank(req.studentName)) {
                res.message = 'Please provide a student name.';
                results.add(res);
                continue;
            }
            String searchTerm = req.studentName.trim();
            List<Student__c> exact = [
                SELECT Id, Name
                FROM Student__c
                WHERE Name = :searchTerm
                LIMIT 5
            ];
            List<Student__c> matches = exact;
            if (matches.isEmpty()) {
                matches = [
                    SELECT Id, Name
                    FROM Student__c
                    WHERE Name LIKE :('%' + searchTerm + '%')
                    LIMIT 5
                ];
            }
            if (matches.isEmpty()) {
                res.message = 'No student found matching "' + searchTerm + '".';
            } else if (matches.size() > 1) {
                List<String> names = new List<String>();
                for (Student__c s : matches) {
                    names.add(s.Name);
                }
                res.message = 'Multiple students found: ' + String.join(names, ', ') + '. Please specify which one.';
            } else {
                res.studentId = matches[0].Id;
                res.studentName = matches[0].Name;
                res.success = true;
                res.message = 'Found student: ' + matches[0].Name + '.';
                TB_AgentService.logAction(matches[0].Id, 'Find Student', res.message);
            }
            results.add(res);
        }
        return results;
    }
}
