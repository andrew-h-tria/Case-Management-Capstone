@IsTest
public class Case_ExternalProviderServiceTest {

    /* ---------------------------
        MOCK CALLOUT – SUCCESS
       --------------------------- */
    private class ProviderSuccessMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);
            res.setHeader('Content-Type', 'application/json');

            res.setBody(
                '[{"id":1,"rating":"⭐️","location":"Danbury, CT","specialty":"mental health","provider_id":"user_634","phone_number":"(555) 473-6703","provider_name":"Twitter","distance_miles":97,"capacity_status":"limited","service_category":"medical","accepting_new_patients":true}]'
            );

            return res;
        }
    }

    /* ---------------------------
        MOCK CALLOUT – ERROR
       --------------------------- */
    private class ProviderErrorMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(500);
            res.setBody('Server Error');
            return res;
        }
    }

    /* ---------------------------
        TEST: SUCCESS PATH
       --------------------------- */
    @IsTest
    static void testFetchProvidersSuccess() {
        Case c = TestDataFactory.createCase('Medium');
        Test.setMock(HttpCalloutMock.class, new ProviderSuccessMock());

        Test.startTest();
        // Fixed: Passing both c.Id and category
        List<TriaTeamA__Case_Provider__c> providers =
            Case_ExternalProviderService.fetchProviders(c.Id, 'medical');
        Test.stopTest();

        System.assertEquals(1, providers.size(), 'One provider should be returned');
        System.assertEquals('Twitter', providers[0].Name);
    }

    /* ---------------------------
        TEST: FILTERING LOGIC
       --------------------------- */
    @IsTest
    static void testServiceCategoryFilter() {
        Case c = TestDataFactory.createCase('Medium');
        Test.setMock(HttpCalloutMock.class, new ProviderSuccessMock());

        Test.startTest();
        // Fixed: Passing both c.Id and category
        List<TriaTeamA__Case_Provider__c> providers =
            Case_ExternalProviderService.fetchProviders(c.Id, 'housing');
        Test.stopTest();

        System.assertEquals(0, providers.size(), 'Provider should be filtered out');
    }

    /* ---------------------------
        TEST: ERROR PATH
       --------------------------- */
    @IsTest
    static void testFetchProvidersFailure() {
        Case c = TestDataFactory.createCase('Medium');
        Test.setMock(HttpCalloutMock.class, new ProviderErrorMock());

        try {
            Test.startTest();
            // Fixed: Passing both c.Id and category
            Case_ExternalProviderService.fetchProviders(c.Id, 'medical');
            Test.stopTest();
        }
        catch (AuraHandledException e) {
            System.assert(e.getMessage() != null);
        }
    }
}