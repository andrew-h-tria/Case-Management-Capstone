trigger CaseTrigger on Case (before insert, before update, after update) {
    CaseTriggerHandler handler = new CaseTriggerHandler();
    
    if (Trigger.isBefore) {
        handler.handleBefore(Trigger.new, Trigger.oldMap);
    }

    // Process timeline record creation after the record is saved
    if (Trigger.isAfter && Trigger.isUpdate) {
        handler.handleAfter(Trigger.new, Trigger.oldMap);
    }
}