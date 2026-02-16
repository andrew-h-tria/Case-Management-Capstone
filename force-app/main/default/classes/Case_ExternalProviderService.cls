public with sharing class Case_ExternalProviderService {

    /* ==========================
        API RESPONSE DTO
       ========================== */
    public class ProviderDTO {
        public Integer id;
        public String rating;
        public String location;
        public String specialty;
        public String provider_id;
        public String phone_number;
        public String provider_name;
        public Integer distance_miles;
        public String capacity_status;
        public String service_category;
        public Boolean accepting_new_patients;
    }

    /* ==========================
        BULK FETCH + UPSERT PROVIDERS
       ========================== */
    @AuraEnabled
    public static Map<Id, List<TriaTeamA__Case_Provider__c>> fetchProvidersBulk(
        List<Id> caseIds,
        List<Case> cases
    ) {
        Map<Id, List<TriaTeamA__Case_Provider__c>> resultMap = new Map<Id, List<TriaTeamA__Case_Provider__c>>();
        
        try {
            if (caseIds == null || caseIds.isEmpty()) {
                return resultMap;
            }

            // Single HTTP callout for all cases
            HttpRequest req = new HttpRequest();
            req.setMethod('GET');
            req.setEndpoint('callout:TriaTeamA__External_Provider_API');

            Http http = new Http();
            HttpResponse res = http.send(req);

            if (res.getStatusCode() != 200) {
                // Log error for all cases but don't throw exception
                Case_ErrorHandler.logErrorsBulk(caseIds, 'Provider API', 'HTTP Status ' + res.getStatusCode());
                return resultMap;
            }

            List<ProviderDTO> allProviders = (List<ProviderDTO>) JSON.deserialize(
                res.getBody(),
                List<ProviderDTO>.class
            );

            // Build category map for filtering
            Map<Id, String> caseToCategoryMap = new Map<Id, String>();
            for (Case c : cases) {
                caseToCategoryMap.put(c.Id, c.TriaTeamA__Triage_Category__c);
            }

            // Group providers by case
            Map<String, TriaTeamA__Case_Provider__c> uniqueRecordsMap = new Map<String, TriaTeamA__Case_Provider__c>();
            
            for (Id caseId : caseIds) {
                String serviceCategory = caseToCategoryMap.get(caseId);
                
                for (ProviderDTO p : allProviders) {
                    // Filter by category
                    if (serviceCategory != null && p.service_category != serviceCategory.toLowerCase()) {
                        continue;
                    }

                    TriaTeamA__Case_Provider__c cp = new TriaTeamA__Case_Provider__c();
                    cp.TriaTeamA__Case__c = caseId;
                    cp.TriaTeamA__External_Id__c = p.provider_id;
                    
                    String uniqueKey = caseId + '-' + p.provider_id;
                    cp.TriaTeamA__Unique_Key__c = uniqueKey;

                    cp.Name = p.provider_name;
                    cp.TriaTeamA__Service_Category__c = p.service_category;
                    cp.TriaTeamA__Specialty__c = p.specialty;
                    cp.TriaTeamA__Location__c = p.location;
                    cp.TriaTeamA__Phone_Number__c = p.phone_number;
                    cp.TriaTeamA__Rating__c = p.rating;
                    cp.TriaTeamA__Distance_Miles__c = p.distance_miles;
                    cp.TriaTeamA__Capacity_Status__c = p.capacity_status;
                    cp.TriaTeamA__Accepting_New_Patients__c = p.accepting_new_patients;

                    uniqueRecordsMap.put(uniqueKey, cp);
                }
            }

            // Build result map AFTER deduplication
            for (TriaTeamA__Case_Provider__c cp : uniqueRecordsMap.values()) {
                if (!resultMap.containsKey(cp.TriaTeamA__Case__c)) {
                    resultMap.put(cp.TriaTeamA__Case__c, new List<TriaTeamA__Case_Provider__c>());
                }
                resultMap.get(cp.TriaTeamA__Case__c).add(cp);
            }

            List<TriaTeamA__Case_Provider__c> recordsToUpsert = uniqueRecordsMap.values();

            if (!recordsToUpsert.isEmpty()) {
                // Bulk cleanup existing providers
                List<TriaTeamA__Case_Provider__c> existing = [
                    SELECT Id FROM TriaTeamA__Case_Provider__c 
                    WHERE TriaTeamA__Case__c IN :caseIds
                ];
                if (!existing.isEmpty()) {
                    delete as user existing;
                }

                // Single bulk upsert
                upsert as user recordsToUpsert TriaTeamA__Unique_Key__c;
            }

            return resultMap;
            
        } catch (Exception e) {
            // Log errors in bulk - does NOT throw exception
            Case_ErrorHandler.logErrorsBulk(caseIds, 'Provider Service Bulk', e.getMessage());
            return resultMap;
        }
    }

    /* ==========================
        SINGLE FETCH + UPSERT (keep for backward compatibility)
       ========================== */
    @AuraEnabled
    public static List<TriaTeamA__Case_Provider__c> fetchProviders(
        Id caseId,
        String serviceCategory
    ) {
        try {
            if (caseId == null) {
                throw new AuraHandledException('Case Id is required');
            }

            HttpRequest req = new HttpRequest();
            req.setMethod('GET');
            req.setEndpoint('callout:TriaTeamA__External_Provider_API');

            Http http = new Http();
            HttpResponse res = http.send(req);

            if (res.getStatusCode() != 200) {
                Case_ErrorHandler.logError(caseId, 'Provider API', 'HTTP Status ' + res.getStatusCode());
                return new List<TriaTeamA__Case_Provider__c>();
            }

            List<ProviderDTO> providers = (List<ProviderDTO>) JSON.deserialize(
                res.getBody(),
                List<ProviderDTO>.class
            );

            Map<String, TriaTeamA__Case_Provider__c> uniqueRecordsMap = new Map<String, TriaTeamA__Case_Provider__c>();

            for (ProviderDTO p : providers) {
                if (serviceCategory != null && p.service_category != serviceCategory.toLowerCase()) {
                    continue;
                }

                TriaTeamA__Case_Provider__c cp = new TriaTeamA__Case_Provider__c();
                cp.TriaTeamA__Case__c = caseId;
                cp.TriaTeamA__External_Id__c = p.provider_id;
                
                String uniqueKey = caseId + '-' + p.provider_id;
                cp.TriaTeamA__Unique_Key__c = uniqueKey;

                cp.Name = p.provider_name;
                cp.TriaTeamA__Service_Category__c = p.service_category;
                cp.TriaTeamA__Specialty__c = p.specialty;
                cp.TriaTeamA__Location__c = p.location;
                cp.TriaTeamA__Phone_Number__c = p.phone_number;
                cp.TriaTeamA__Rating__c = p.rating;
                cp.TriaTeamA__Distance_Miles__c = p.distance_miles;
                cp.TriaTeamA__Capacity_Status__c = p.capacity_status;
                cp.TriaTeamA__Accepting_New_Patients__c = p.accepting_new_patients;

                uniqueRecordsMap.put(uniqueKey, cp);
            }

            List<TriaTeamA__Case_Provider__c> recordsToUpsert = uniqueRecordsMap.values();

            if (!recordsToUpsert.isEmpty()) {
                List<TriaTeamA__Case_Provider__c> existing = [
                    SELECT Id FROM TriaTeamA__Case_Provider__c 
                    WHERE TriaTeamA__Case__c = :caseId
                ];
                if (!existing.isEmpty()) {
                    delete as user existing;
                }

                upsert as user recordsToUpsert TriaTeamA__Unique_Key__c;
            }

            return recordsToUpsert;
        } catch (Exception e) {
            Case_ErrorHandler.logError(caseId, 'Provider Service', e.getMessage());
            return new List<TriaTeamA__Case_Provider__c>();
        }
    }
}