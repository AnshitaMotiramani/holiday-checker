public with sharing class SAIdSearchService {

    public class SearchResult {
        @AuraEnabled public String idNumber;
        @AuraEnabled public Date dateOfBirth;
        @AuraEnabled public String gender;
        @AuraEnabled public Boolean saCitizen;
        @AuraEnabled public Decimal searchCount;
        @AuraEnabled public String message;
    }

    public static SearchResult saveSearch(String idNumber) {
        SearchResult result = decodeIdNumber(idNumber);

        List<SA_ID_Search__c> existingRecords = [
            SELECT Id, Search_Count__c
            FROM SA_ID_Search__c
            WHERE SA_ID_Number__c = :idNumber
            LIMIT 1
        ];

        SA_ID_Search__c searchRecord;

        if (existingRecords.isEmpty()) {
            searchRecord = new SA_ID_Search__c();
            searchRecord.SA_ID_Number__c = idNumber;
            searchRecord.Date_Of_Birth__c = result.dateOfBirth;
            searchRecord.Gender__c = result.gender;
            searchRecord.SA_Citizen__c = result.saCitizen;
            searchRecord.Search_Count__c = 1;
            insert searchRecord;

            result.searchCount = 1;
            result.message = 'Search record created successfully.';
        } else {
            searchRecord = existingRecords[0];
            Decimal currentCount = searchRecord.Search_Count__c == null ? 0 : searchRecord.Search_Count__c;
            searchRecord.Search_Count__c = currentCount + 1;
            update searchRecord;

            result.searchCount = searchRecord.Search_Count__c;
            result.message = 'Search record updated successfully.';
        }

        return result;
    }

    private static SearchResult decodeIdNumber(String idNumber) {
        SearchResult result = new SearchResult();
        result.idNumber = idNumber;

        Integer year = Integer.valueOf(idNumber.substring(0, 2));
        Integer month = Integer.valueOf(idNumber.substring(2, 4));
        Integer day = Integer.valueOf(idNumber.substring(4, 6));

        Integer currentYearTwoDigits = Integer.valueOf(String.valueOf(Date.today().year()).right(2));
        Integer fullYear = year <= currentYearTwoDigits ? 2000 + year : 1900 + year;

        result.dateOfBirth = Date.newInstance(fullYear, month, day);

        Integer genderSequence = Integer.valueOf(idNumber.substring(6, 10));
        result.gender = genderSequence < 5000 ? 'Female' : 'Male';

        String citizenshipDigit = idNumber.substring(10, 11);
        result.saCitizen = citizenshipDigit == '0';

        return result;
    }
}