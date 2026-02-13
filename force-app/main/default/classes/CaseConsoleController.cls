public with sharing class CaseConsoleController {

    @AuraEnabled(cacheable=true)
    public static List<Case> getCases(
        String status,
        String priority,
        Id recordTypeId,
        Boolean myCasesOnly
    ) {
        System.debug('=== getCases called ===');
        System.debug('status: ' + status);
        System.debug('priority: ' + priority);
        System.debug('recordTypeId: ' + recordTypeId);
        System.debug('myCasesOnly: ' + myCasesOnly);
        
        String baseQuery =
            'SELECT Id, CaseNumber, Subject, Status, Priority, ' +
            'RecordTypeId, RecordType.Name, SLA_Target__c, OwnerId ' +
            'FROM Case WHERE IsDeleted = false';

        List<String> conditions = new List<String>();
        
        Id currentUserId = UserInfo.getUserId();
        System.debug('currentUserId: ' + currentUserId);

        if (String.isNotBlank(status)) {
            conditions.add('Status = :status');
        }
        if (String.isNotBlank(priority)) {
            conditions.add('Priority = :priority');
        }
        if (recordTypeId != null) {
            conditions.add('RecordTypeId = :recordTypeId');
        }
        if (myCasesOnly == true) {
            conditions.add('OwnerId = :currentUserId');
        }

        if (!conditions.isEmpty()) {
            baseQuery += ' AND ' + String.join(conditions, ' AND ');
        }

        baseQuery += ' ORDER BY SLA_Target__c ASC NULLS LAST';
        
        System.debug('Final query: ' + baseQuery);
        
        List<Case> results = Database.query(baseQuery);
        System.debug('Found ' + results.size() + ' cases');
        
        return results;
    }
}