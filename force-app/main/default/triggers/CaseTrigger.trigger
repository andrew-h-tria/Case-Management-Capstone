trigger CaseTrigger on Case (before insert, before update) {
    // Calls the CaseTriggerHandler class 
    CaseTriggerHandler handler = new CaseTriggerHandler();
    
    if (Trigger.isBefore) {
        handler.handleBefore(Trigger.new, Trigger.oldMap);
    }
}