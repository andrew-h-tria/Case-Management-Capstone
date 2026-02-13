@isTest
public class Case_ErrorHandlerTest {
    @isTest
    static void testErrorLogging() {
        // Using Factory due to Case validation rules
        Case c = TestDataFactory.createCase('Medium');
        
        Boolean caught = false;
        try {
            Test.startTest();
            Case_ErrorHandler.logError(c.Id, 'TestSection', 'TestMsg');
            Test.stopTest();
        } catch (AuraHandledException e) {
            caught = true;
        }
        
        System.assert(caught, 'An AuraHandledException should have been thrown');
        List<TriaTeamA__Case_Activity__c> logs = [SELECT Id, TriaTeamA__Activity_Type__c 
                                                  FROM TriaTeamA__Case_Activity__c 
                                                  WHERE TriaTeamA__Case__c = :c.Id];
        System.assertEquals(1, logs.size());
        System.assertEquals('Error', logs[0].TriaTeamA__Activity_Type__c);
    }
}