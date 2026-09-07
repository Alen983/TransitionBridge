public class TransitionBridgeDataLoader {
    public static void loadSampleData() {
        if (!Program__c.SObjectType.getDescribe().isAccessible()) {
            throw new AuraHandledException('Insufficient access to Program__c');
        }

        List<Program__c> existingPrograms = [SELECT Id, Name FROM Program__c LIMIT 10];
        if (!existingPrograms.isEmpty()) {
            System.debug('Sample data already exists. Skipping load.');
            return;
        }

        Program__c vr = new Program__c(
            Name = 'Vocational Rehabilitation',
            Administering_Agency__c = 'State Department of Rehabilitation Services',
            Eligibility_Summary__c = 'Individuals with disabilities who need employment-related services.',
            Typical_Referral_Lead_Time_Days__c = 90
        );
        Program__c ssi = new Program__c(
            Name = 'SSI Age-18 Redetermination',
            Administering_Agency__c = 'Social Security Administration',
            Eligibility_Summary__c = 'Age-18 redetermination review for SSI recipients.',
            Typical_Referral_Lead_Time_Days__c = 60
        );
        insert new List<Program__c>{ vr, ssi };

        Date today = Date.today();
        Date sixMonthsOut = today.addMonths(6);
        Date threeMonthsOut = today.addMonths(3);
        Date fourteenMonthsOut = today.addMonths(14);

        Student__c jordan = new Student__c(
            Name = 'Jordan Reyes',
            Date_of_Birth__c = today.addYears(-21).addMonths(-6),
            School__c = 'Lincoln High',
            Grade_Status__c = 'Exited',
            IEP_Flag__c = true,
            Primary_Guardian_Name__c = 'Maria Reyes',
            Primary_Guardian_Contact__c = '5035550101'
        );
        Student__c amara = new Student__c(
            Name = 'Amara Okafor',
            Date_of_Birth__c = today.addYears(-17).addMonths(-9),
            School__c = 'Riverside High',
            Grade_Status__c = 'Enrolled',
            IEP_Flag__c = true,
            Primary_Guardian_Name__c = 'Chidi Okafor',
            Primary_Guardian_Contact__c = '5035550102'
        );
        Student__c diego = new Student__c(
            Name = 'Diego Martinez',
            School__c = 'Westview High',
            Grade_Status__c = 'Enrolled',
            IEP_Flag__c = true,
            Primary_Guardian_Name__c = 'Elena Martinez',
            Primary_Guardian_Contact__c = '5035550103'
        );
        Student__c priya = new Student__c(
            Name = 'Priya Chen',
            Date_of_Birth__c = today.addYears(-20).addMonths(-10),
            School__c = 'Summit High',
            Grade_Status__c = 'Enrolled',
            IEP_Flag__c = true,
            Primary_Guardian_Name__c = 'Wei Chen',
            Primary_Guardian_Contact__c = '5035550104'
        );
        insert new List<Student__c>{ jordan, amara, diego, priya };

        insert new List<IEP_Transition_Goal__c>{
            new IEP_Transition_Goal__c(
                Student__c = jordan.Id,
                Goal_Area__c = 'Employment',
                Goal_Description__c = 'Obtain competitive integrated employment after school exit.',
                Target_Date__c = sixMonthsOut,
                Status__c = 'In Progress'
            ),
            new IEP_Transition_Goal__c(
                Student__c = diego.Id,
                Goal_Area__c = 'Employment',
                Goal_Description__c = 'Secure part-time employment with job coaching support.',
                Status__c = 'Met'
            )
        };

        insert new List<Accommodation_Record__c>{
            new Accommodation_Record__c(
                Student__c = amara.Id,
                Accommodation_Type__c = 'Extended time',
                Context__c = 'Testing',
                Active__c = true,
                Start_Date__c = today.addYears(-2)
            ),
            new Accommodation_Record__c(
                Student__c = priya.Id,
                Accommodation_Type__c = 'Screen reader',
                Context__c = 'Workplace',
                Active__c = true,
                Start_Date__c = today.addMonths(-6)
            )
        };

        insert new List<Program_Enrollment__c>{
            new Program_Enrollment__c(
                Student__c = jordan.Id,
                Program__c = vr.Id,
                Status__c = 'Not Started'
            ),
            new Program_Enrollment__c(
                Student__c = amara.Id,
                Program__c = ssi.Id,
                Status__c = 'Not Started'
            ),
            new Program_Enrollment__c(
                Student__c = diego.Id,
                Program__c = vr.Id,
                Status__c = 'Denied'
            ),
            new Program_Enrollment__c(
                Student__c = priya.Id,
                Program__c = vr.Id,
                Status__c = 'Enrolled',
                Referral_Date__c = today.addMonths(-8),
                Decision_Date__c = today.addMonths(-5),
                Assigned_Contact__c = 'Sarah Kim, VR Counselor',
                Last_Activity_Date__c = today.addDays(-14)
            )
        };

        insert new List<Deadline_Milestone__c>{
            new Deadline_Milestone__c(
                Student__c = jordan.Id,
                Deadline_Date__c = sixMonthsOut,
                Type__c = 'Age-based',
                Status__c = 'Upcoming',
                Description__c = 'Turns 22 — school-based services end'
            ),
            new Deadline_Milestone__c(
                Student__c = amara.Id,
                Deadline_Date__c = threeMonthsOut,
                Type__c = 'Age-based',
                Status__c = 'Upcoming',
                Description__c = 'Turns 18 — SSI redetermination review'
            ),
            new Deadline_Milestone__c(
                Student__c = priya.Id,
                Deadline_Date__c = fourteenMonthsOut,
                Type__c = 'Age-based',
                Status__c = 'Upcoming',
                Description__c = 'Turns 22 — school-based services end'
            )
        };

        System.debug('TransitionBridge sample data loaded successfully.');
    }
}
