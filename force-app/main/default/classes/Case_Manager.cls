public with sharing class Case_Manager {

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

        //  Delegate SLA calculation to Flow (as designed)

        //  Fetch + persist providers
        List<TriaTeamA__Case_Provider__c> providers =
            Case_ExternalProviderService.fetchProviders(
                c.Id,
                c.Triage_Category__c
            );

        //  Pick first accepting provider
        for (TriaTeamA__Case_Provider__c p : providers) {
            if (p.TriaTeamA__Accepting_New_Patients__c) {
                c.TriaTeamA__External_Provider_Selected__c = p.Id;
                break;
            }
        }

        update as user c;

/*
        insert as user new TriaTeamA__Case_Activity__c(
            TriaTeamA__Case__c = caseId,
            TriaTeamA__Activity_Type__c = 'Routing',
            TriaTeamA__Description__c = 'Auto-selection completed. Provider linked.'
        );
        */
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

        // Added activity creation so the Timeline LWC shows the manual selection
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