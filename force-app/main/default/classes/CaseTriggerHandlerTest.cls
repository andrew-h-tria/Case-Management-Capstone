@isTest
public class CaseTriggerHandlerTest {
    @isTest
    static void testHighPriorityValidation() {
        // Testing negative case: Short description should fail per Alex's business rules
        Case c = new Case(Subject = 'Test', Priority = 'High', Description = 'Short');
        
        Test.startTest();
        Database.SaveResult res = Database.insert(c, false);
        Test.stopTest();
        
        System.assert(!res.isSuccess());
    }

    @isTest
    static void testCaseClosurePermission() {
        Case c = TestDataFactory.createCase('Low');
        c.Status = 'Closed';
        
        Test.startTest();
        Database.Update(c, false);
        Test.stopTest();
        
        // Validation check based on custom permission
        if(!FeatureManagement.checkPermission('TriaTeamA__Case_Supervisor')) {
             Case updated = [SELECT Status FROM Case WHERE Id = :c.Id];
             System.assertNotEquals('Closed', updated.Status);
        }
    }
}