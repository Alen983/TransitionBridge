public with sharing class TB_IdentifyGapsAction {
    public class Request {
        @InvocableVariable(label='Student Id' required=true)
        public Id studentId;
    }

    public class Response {
        @InvocableVariable
        public String message;
        @InvocableVariable
        public Boolean hasGaps;
        @InvocableVariable
        public Boolean shouldEscalate;
        @InvocableVariable
        public Boolean success;
    }

    @InvocableMethod(
        label='Identify Transition Gaps'
        description='Identifies missing referrals, data conflicts, and timeline risks for a student.'
        category='TransitionBridge'
    )
    public static List<Response> identifyGaps(List<Request> requests) {
        List<Response> results = new List<Response>();
        for (Request req : requests) {
            Response res = new Response();
            res.success = true;
            res.hasGaps = false;
            res.shouldEscalate = false;
            Student__c student = TB_AgentService.getStudent(req.studentId);
            List<String> gaps = new List<String>();
            List<String> escalations = new List<String>();

            if (student.Date_of_Birth__c == null) {
                escalations.add('Date of birth is missing — age-based deadlines cannot be verified reliably.');
            }

            List<Deadline_Milestone__c> deadlines = [
                SELECT Description__c, Deadline_Date__c, Type__c, Status__c
                FROM Deadline_Milestone__c
                WHERE Student__c = :req.studentId AND Status__c = 'Upcoming'
                ORDER BY Deadline_Date__c ASC
            ];
            List<Program_Enrollment__c> enrollments = [
                SELECT Id, Status__c, Program__r.Name, Program__r.Typical_Referral_Lead_Time_Days__c,
                       Decision_Date__c, Assigned_Contact__c
                FROM Program_Enrollment__c
                WHERE Student__c = :req.studentId
            ];
            List<IEP_Transition_Goal__c> goals = [
                SELECT Goal_Area__c, Status__c
                FROM IEP_Transition_Goal__c
                WHERE Student__c = :req.studentId
            ];

            for (Deadline_Milestone__c deadline : deadlines) {
                String programHint = inferProgramFromDeadline(deadline.Description__c);
                if (programHint == null) {
                    continue;
                }
                Program_Enrollment__c related = findEnrollment(enrollments, programHint);
                Integer leadDays = related != null && related.Program__r.Typical_Referral_Lead_Time_Days__c != null
                    ? Integer.valueOf(related.Program__r.Typical_Referral_Lead_Time_Days__c)
                    : TB_AgentService.defaultLeadTimeDays();
                Integer daysUntil = Date.today().daysBetween(deadline.Deadline_Date__c);
                if (related == null || related.Status__c == 'Not Started') {
                    if (daysUntil <= leadDays || daysUntil <= 365) {
                        String urgency = daysUntil <= leadDays ? 'within referral lead time' : 'upcoming';
                        gaps.add(
                            deadline.Description__c + ' on ' + deadline.Deadline_Date__c +
                            ' (' + urgency + '), but ' + programHint + ' referral has not been started.'
                        );
                        res.hasGaps = true;
                    }
                }
            }

            for (Program_Enrollment__c enrollment : enrollments) {
                if (enrollment.Status__c == 'Denied' &&
                    (enrollment.Decision_Date__c == null || String.isBlank(enrollment.Assigned_Contact__c))) {
                    escalations.add(
                        enrollment.Program__r.Name + ' enrollment is Denied but decision details are incomplete.'
                    );
                    res.shouldEscalate = true;
                }
            }

            for (IEP_Transition_Goal__c goal : goals) {
                if (goal.Status__c == 'Met' && goal.Goal_Area__c == 'Employment') {
                    for (Program_Enrollment__c enrollment : enrollments) {
                        if (enrollment.Program__r.Name != null &&
                            enrollment.Program__r.Name.containsIgnoreCase('Vocational') &&
                            enrollment.Status__c == 'Denied') {
                            escalations.add(
                                'Employment IEP goal is marked Met, but Vocational Rehabilitation enrollment is Denied with no resolution notes.'
                            );
                            res.shouldEscalate = true;
                        }
                    }
                }
            }

            List<String> lines = new List<String>();
            lines.add('Gap analysis for ' + student.Name + ':');
            if (!gaps.isEmpty()) {
                lines.add('Gaps identified:');
                lines.addAll(gaps);
            } else if (!escalations.isEmpty()) {
                lines.add('No referral timeline gaps, but data conflicts require human review.');
            } else {
                lines.add('No urgent gaps identified. Transition items appear on track based on current records.');
            }
            if (!escalations.isEmpty()) {
                lines.add('Escalation recommended:');
                lines.addAll(escalations);
            }
            res.message = String.join(lines, '\n');
            TB_AgentService.logAction(req.studentId, 'Identify Transition Gaps', res.message);
            results.add(res);
        }
        return results;
    }

    private static String inferProgramFromDeadline(String description) {
        if (String.isBlank(description)) {
            return null;
        }
        String lower = description.toLowerCase();
        if (lower.contains('22') || lower.contains('vocational') || lower.contains('vr')) {
            return 'Vocational Rehabilitation';
        }
        if (lower.contains('ssi') || lower.contains('18') || lower.contains('redetermination')) {
            return 'SSI Age-18 Redetermination';
        }
        return null;
    }

    private static Program_Enrollment__c findEnrollment(
        List<Program_Enrollment__c> enrollments,
        String programName
    ) {
        for (Program_Enrollment__c enrollment : enrollments) {
            if (enrollment.Program__r.Name != null &&
                enrollment.Program__r.Name.containsIgnoreCase(programName.left(10))) {
                return enrollment;
            }
        }
        for (Program_Enrollment__c enrollment : enrollments) {
            if (enrollment.Program__r.Name == programName) {
                return enrollment;
            }
        }
        return null;
    }
}
