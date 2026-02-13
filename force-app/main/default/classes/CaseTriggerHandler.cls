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
}