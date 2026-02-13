@isTest
public class TestDataFactory {

    /* ==========================
        CASE CREATION
       ========================== */
    public static Case createCase(String priority) {
        Case c = new Case(
            Subject = 'Test Case',
            Priority = priority,
            Description = 'This is a long description that is at least thirty characters.',
            TriaTeamA__Origin__c = 'Web',
            // SLA Target is required by the Org
            TriaTeamA__SLA_Target__c = System.today().addDays(2)
        );
        insert c;
        return c;
    }

    /* ==========================
        CASE ACTIVITY CREATION
       ========================== */
    public static TriaTeamA__Case_Activity__c createActivity(Id caseId, String type, String descrip) {
        TriaTeamA__Case_Activity__c act = new TriaTeamA__Case_Activity__c(
            TriaTeamA__Case__c = caseId,
            TriaTeamA__Activity_Type__c = type,
            TriaTeamA__Description__c = descrip
        );
        insert act;
        return act;
    }

    /* ==========================
        CASE PROVIDER CREATION
       ========================== */
    public static TriaTeamA__Case_Provider__c createProvider(Id caseId, String name) {
        TriaTeamA__Case_Provider__c p = new TriaTeamA__Case_Provider__c(
            TriaTeamA__Case__c = caseId,
            Name = name,
            TriaTeamA__External_Id__c = 'EXT-' + name,
            TriaTeamA__Unique_Key__c = caseId + '-' + name
        );
        insert p;
        return p;
    }
}