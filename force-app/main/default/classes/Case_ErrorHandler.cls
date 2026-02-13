// Utility class to log errors and inform the LWC
public with sharing class Case_ErrorHandler {
    public static void logError(String caseId, String section, String errorMessage) {
        TriaTeamA__Case_Activity__c log = new TriaTeamA__Case_Activity__c();
        log.TriaTeamA__Case__c = caseId; 
        log.TriaTeamA__Activity_Type__c = 'Error';
        log.TriaTeamA__Description__c = 'ERROR in ' + section + ': ' + errorMessage;
        
        try {
            // Security enforcement
            insert as user log;
        } catch (Exception e) {
            System.debug('Logging failed: ' + e.getMessage());
        }

        // AuraHandledException allows LWC to display the error message
        // Returns a readable error to the LWC front-end
        throw new AuraHandledException('Service Error in ' + section + ': ' + errorMessage);
    }
}