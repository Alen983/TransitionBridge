// Quick smoke test for TransitionBridge agent actions
Student__c jordan = [SELECT Id, Name FROM Student__c WHERE Name = 'Jordan Reyes' LIMIT 1];
Student__c amara = [SELECT Id, Name FROM Student__c WHERE Name = 'Amara Okafor' LIMIT 1];
Student__c diego = [SELECT Id, Name FROM Student__c WHERE Name = 'Diego Martinez' LIMIT 1];
Student__c priya = [SELECT Id, Name FROM Student__c WHERE Name = 'Priya Chen' LIMIT 1];

TB_IdentifyGapsAction.Request gapReq = new TB_IdentifyGapsAction.Request();
gapReq.studentId = jordan.Id;
System.debug(TB_IdentifyGapsAction.identifyGaps(new List<TB_IdentifyGapsAction.Request>{ gapReq }));

gapReq.studentId = diego.Id;
System.debug(TB_IdentifyGapsAction.identifyGaps(new List<TB_IdentifyGapsAction.Request>{ gapReq }));

gapReq.studentId = priya.Id;
System.debug(TB_IdentifyGapsAction.identifyGaps(new List<TB_IdentifyGapsAction.Request>{ gapReq }));

TB_EscalateAction.Request escReq = new TB_EscalateAction.Request();
escReq.studentId = amara.Id;
escReq.reason = 'User asked about SSI age-18 redetermination eligibility.';
escReq.triggeredBy = 'Transition Timeline & Gaps';
System.debug(TB_EscalateAction.escalate(new List<TB_EscalateAction.Request>{ escReq }));
