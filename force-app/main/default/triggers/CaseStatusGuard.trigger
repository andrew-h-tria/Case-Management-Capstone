trigger CaseStatusGuard on Case (before update) {
    for (Case c : Trigger.new) {
        Case oldCase = Trigger.oldMap.get(c.Id);

        if (
            c.Status == 'Closed' &&
            oldCase.Status != 'Closed' &&
            !FeatureManagement.checkPermission('Case_Supervisor')
        ) {
            c.addError('Only Case Supervisors can close a Case.');
        }
    }
}