public with sharing class SAIdHolidayController {

    @AuraEnabled
    public static SAIdSearchService.SearchResult searchIdNumber(String idNumber) {
        return SAIdSearchService.saveSearch(idNumber);
    }
}