public with sharing class TB_DraftReferralAction {
    public class Request {
        @InvocableVariable(label='Student Id' required=true)
        public Id studentId;
        @InvocableVariable(label='Program Name' required=true)
        public String programName;
    }

    public class Response {
        @InvocableVariable
        public Id enrollmentId;
        @InvocableVariable
        public String message;
        @InvocableVariable
        public Boolean success;
    }

    @InvocableMethod(
        label='Draft Referral'
        description='Creates a Program Enrollment in Referral Drafted status. Does not send the referral.'
        category='TransitionBridge'
    )
    public static List<Response> draftReferral(List<Request> requests) {
        List<Response> results = new List<Response>();
        for (Request req : requests) {
            Response res = new Response();
            res.success = false;
            Student__c student = TB_AgentService.getStudent(req.studentId);
            Program__c program = TB_AgentService.findProgram(req.programName);
            if (program == null) {
                res.message = 'Program not found: ' + req.programName + '.';
                results.add(res);
                continue;
            }
            List<Program_Enrollment__c> existing = [
                SELECT Id, Status__c
                FROM Program_Enrollment__c
                WHERE Student__c = :req.studentId AND Program__c = :program.Id
                LIMIT 1
            ];
            Program_Enrollment__c enrollment;
            if (!existing.isEmpty()) {
                enrollment = existing[0];
                enrollment.Status__c = 'Referral Drafted';
                enrollment.Referral_Date__c = Date.today();
                update enrollment;
            } else {
                enrollment = new Program_Enrollment__c(
                    Student__c = req.studentId,
                    Program__c = program.Id,
                    Status__c = 'Referral Drafted',
                    Referral_Date__c = Date.today()
                );
                insert enrollment;
            }
            res.enrollmentId = enrollment.Id;
            res.success = true;
            res.message =
                'Draft referral created for ' + student.Name + ' to ' + program.Name +
                '. Status is Referral Drafted — it has NOT been sent. A case worker must review and send it.';
            TB_AgentService.logAction(req.studentId, 'Draft Referral', res.message);
            results.add(res);
        }
        return results;
    }
}
