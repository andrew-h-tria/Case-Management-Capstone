public with sharing class CaseTriggerHandler {
    // Logic that runs before the Case record is committed to the database
    public void handleBefore(List<Case> newCases, Map<Id, Case> oldMap) {
        for (Case c : newCases) {
            
            // makes sure High Priority cases are not saved with short descriptions
            if (c.Priority == 'High' && (c.Description == null || c.Description.length() < 30)) {
                c.addError('High Priority Cases must have a Description of at least 30 characters.');
            }

            // Checks for Supervisor permissions when closing a Case
            if (oldMap != null) {
                Case oldCase = oldMap.get(c.Id);
                if (c.Status == 'Closed' && oldCase.Status != 'Closed' && 
                    !FeatureManagement.checkPermission('Case_Supervisor')) {
                    c.addError('Only Case Supervisors can close a Case.');
                }
            }
        }
    }

    // Logic to create the activity record after the Case is updated
    // Alex did SLA Flow, so I added this here to handle Timeline record creation
    public void handleAfter(List<Case> newCases, Map<Id, Case> oldMap) {
        List<TriaTeamA__Case_Activity__c> activitiesToCreate = new List<TriaTeamA__Case_Activity__c>();

        for (Case c : newCases) {
            if (oldMap != null) {
                Case oldCase = oldMap.get(c.Id);

                // Create Timeline Activity when Status changes to Resolved 
                if (c.Status == 'Resolved' && oldCase.Status != 'Resolved') {
                    activitiesToCreate.add(new TriaTeamA__Case_Activity__c(
                        TriaTeamA__Case__c = c.Id,
                        // Set to 'resolution' to match your restricted picklist values
                        TriaTeamA__Activity_Type__c = 'resolution', 
                        TriaTeamA__Description__c = 'Case status was updated to Resolved.'
                    ));
                }
            }
        }

        if (!activitiesToCreate.isEmpty()) {
            insert activitiesToCreate;
        }
    }
}