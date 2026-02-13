@IsTest
public class Case_ManagerTest {

    /* ---------------------------
        MOCK CALLOUT
       --------------------------- */
    private class ProviderSuccessMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);
            res.setHeader('Content-Type', 'application/json');

            res.setBody(
                '[{"provider_id":"user_999","provider_name":"Test Provider","service_category":"medical","accepting_new_patients":true}]'
            );
            return res;
        }
    }

    /* ---------------------------
        TEST: PROCESS CASE
       --------------------------- */
    @IsTest
    static void testProcessCaseAssignsProvider() {
        Test.setMock(HttpCalloutMock.class, new ProviderSuccessMock());

        Case testCase = TestDataFactory.createCase('Medium');
        testCase.TriaTeamA__Triage_Category__c = 'medical';
        update testCase;

        Test.startTest();
        Id resultId = Case_Manager.processCase(testCase.Id);
        Test.stopTest();

        Case updatedCase = [SELECT TriaTeamA__External_Provider_Selected__c FROM Case WHERE Id = :resultId];

        System.assertNotEquals(null, updatedCase.TriaTeamA__External_Provider_Selected__c, 'External provider should be assigned');
    }

    /* ---------------------------
        TEST: MANUAL PROVIDER SELECTION
       --------------------------- */
    @IsTest
    static void testSelectProviderManual() {
        Case c = TestDataFactory.createCase('Low');
        TriaTeamA__Case_Provider__c p = TestDataFactory.createProvider(c.Id, 'Manual Provider');

        Test.startTest();
        Case_Manager.selectProvider(c.Id, p.Id);
        Test.stopTest();

        Case updated = [SELECT Status FROM Case WHERE Id = :c.Id];
        System.assertEquals('In Progress', updated.Status);
        
        List<TriaTeamA__Case_Activity__c> timeline = [SELECT Id FROM TriaTeamA__Case_Activity__c WHERE TriaTeamA__Case__c = :c.Id AND TriaTeamA__Activity_Type__c = 'Provider Lookup'];
        System.assertEquals(1, timeline.size(), 'Manual provider lookup activity should be logged');
    }
}