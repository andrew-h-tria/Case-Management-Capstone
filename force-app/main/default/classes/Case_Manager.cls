public with sharing class Case_Manager {

    @AuraEnabled
public static void processCases(List<Id> caseIds) {

    if (caseIds == null || caseIds.isEmpty()) {
        return;
    }

    Set<Id> caseIdSet = new Set<Id>(caseIds);

    List<Case> cases = [
        SELECT Id,
               TriaTeamA__Triage_Category__c,
               TriaTeamA__External_Provider_Selected__c
        FROM Case
        WHERE Id IN :caseIdSet
    ];

    //  Call fetchProvidersBulk ONCE for all cases
    Map<Id, List<TriaTeamA__Case_Provider__c>> caseToProvidersMap = 
        Case_ExternalProviderService.fetchProvidersBulk(caseIds, cases);

    List<Case> casesToUpdate = new List<Case>();

   
    for (Case c : cases) {
        try {
            // Get pre-fetched providers for this case
            List<TriaTeamA__Case_Provider__c> providers = caseToProvidersMap.get(c.Id);

            if (providers != null && !providers.isEmpty()) {
                for (TriaTeamA__Case_Provider__c p : providers) {
                    if (p.TriaTeamA__Accepting_New_Patients__c) {
                        c.TriaTeamA__External_Provider_Selected__c = p.Id;
                        break;
                    }
                }
            }

            casesToUpdate.add(c);

        } catch (Exception e) {
            // Log but continue processing other cases
            System.debug('Handled provider error for case: ' + c.Id + ' - ' + e.getMessage());
        }
    }

    if (!casesToUpdate.isEmpty()) {
        update casesToUpdate;
    }
}

    // Keep existing single-case method for backward compatibility
    @AuraEnabled
    public static Id processCase(Id caseId) {
        Case c = [
            SELECT Id,
                   TriaTeamA__Triage_Category__c,
                   TriaTeamA__External_Provider_Selected__c
            FROM Case
            WHERE Id = :caseId
            LIMIT 1
        ];

        List<TriaTeamA__Case_Provider__c> providers =
            Case_ExternalProviderService.fetchProviders(
                c.Id,
                c.TriaTeamA__Triage_Category__c
            );

        for (TriaTeamA__Case_Provider__c p : providers) {
            if (p.TriaTeamA__Accepting_New_Patients__c) {
                c.TriaTeamA__External_Provider_Selected__c = p.Id;
                break;
            }
        }

        update as user c;
        return c.Id;
    }

    @AuraEnabled
    public static void selectProvider(Id caseId, Id providerId) {
        Case c = new Case(
            Id = caseId,
            TriaTeamA__External_Provider_Selected__c = providerId,
            Status = 'In Progress'
        );
        update as user c;

        insert as user new TriaTeamA__Case_Activity__c(
            TriaTeamA__Case__c = caseId,
            TriaTeamA__Activity_Type__c = 'Provider Lookup',
            TriaTeamA__Description__c = 'Manual selection: Provider record linked to case.'
        );
    }

    @AuraEnabled(cacheable=true)
    public static List<TriaTeamA__Case_Activity__c> getCaseTimeline(Id caseId) {
        return [SELECT Id, TriaTeamA__Activity_Type__c, TriaTeamA__Description__c, CreatedDate, CreatedBy.Name 
                FROM TriaTeamA__Case_Activity__c 
                WHERE TriaTeamA__Case__c = :caseId 
                ORDER BY CreatedDate DESC];
    }
}