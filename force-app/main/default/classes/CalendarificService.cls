public with sharing class CalendarificService {

    private static final String API_KEY = '24c5e86734eb44dc4a962826324a5546e74dc42f';

    public class Holiday {
        @AuraEnabled public String name;
        @AuraEnabled public String dateValue;
        @AuraEnabled public String type;
    }

    public static List<Holiday> getHolidays(Integer year) {
        HttpRequest request = new HttpRequest();

        String endpoint = 'https://calendarific.com/api/v2/holidays'
            + '?api_key=' + API_KEY
            + '&country=ZA'
            + '&year=' + String.valueOf(year);

        request.setEndpoint(endpoint);
        request.setMethod('GET');

        Http http = new Http();
        HttpResponse response = http.send(request);

        if (response.getStatusCode() != 200) {
            throw new AuraHandledException('Unable to fetch holidays.');
        }

        Map<String, Object> responseMap =
            (Map<String, Object>) JSON.deserializeUntyped(response.getBody());

        Map<String, Object> responseBody =
            (Map<String, Object>) responseMap.get('response');

        List<Object> holidaysRaw =
            (List<Object>) responseBody.get('holidays');

        List<Holiday> holidays = new List<Holiday>();

        for (Object item : holidaysRaw) {
            Map<String, Object> holidayMap = (Map<String, Object>) item;

            Map<String, Object> dateMap =
                (Map<String, Object>) holidayMap.get('date');

            Holiday holiday = new Holiday();
            holiday.name = (String) holidayMap.get('name');
            holiday.dateValue = (String) dateMap.get('iso');

            List<Object> types = (List<Object>) holidayMap.get('type');
            holiday.type = types != null && !types.isEmpty()
                ? String.valueOf(types[0])
                : '';

            holidays.add(holiday);
        }

        return holidays;
    }
}