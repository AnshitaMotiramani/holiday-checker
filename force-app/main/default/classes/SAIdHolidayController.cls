public with sharing class SAIdHolidayController {

    @AuraEnabled
    public static String searchIdNumber(String idNumber) {
        return 'Search initiated for ID: ' + idNumber;
    }
}