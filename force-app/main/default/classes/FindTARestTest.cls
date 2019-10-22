@IsTest
private class FindTARestTest  {
	private static List<String> getSectors() {
		List<String> sectors = new List<String>();
		Schema.DescribeFieldResult field = Specialty__c.Sector__c.getDescribe();
		for (Schema.PicklistEntry e: field.getPicklistValues()) {
			sectors.add(e.getValue());
		}
		return sectors;
	}

	private static List<String> getBusinessTypes() {
		List<String> types = new List<String>();
		Schema.DescribeFieldResult field = Account.Business_Type__c.getDescribe();
		for (Schema.PicklistEntry e: field.getPicklistValues()) {
			types.add(e.getValue());
		}
		return types;
	}

    @isTest static void testSearchComprehensive() {
        // Set up a test request
        RestRequest request = new RestRequest();
        request.requestUri =
            'https://tradeallydev-dev-ed.my.salesforce.com/services/apexrest/FindTA';
        request.httpMethod = 'GET';
        request.params.put('name', 'sForce');
        request.params.put(FindTARest.QUERY_PARAM_SECTOR, 'Commercial');
        request.params.put(FindTARest.QUERY_PARAM_BUSINESS_TYPE, 'Contractor,Manufacturing');
        request.params.put('specialties', 'Lighting,Appliances');
        request.params.put('states', 'a0Kf4000005lHKIEA2'); // a0Kf4000005lHKIEA2 is CA
        request.params.put('latitude', '37.775');
        request.params.put('longitude', '-122.418');
        request.params.put('radius', '50');
        request.params.put('contracted', 'true');
        request.params.put('tier', 'true');
        RestContext.request = request;
        RestContext.response = new RestResponse();
        // Call the method to test
        FindTARest.searchTradeAllies();
        // Verify results
        System.assert(RestContext.response.responseBody != null);
    }
    
    // Test searching without any parameter. This is the default query for FTA to get ALL records from TAC
    @isTest static void testSearchWithoutParam () {
        RestRequest request = new RestRequest();
        request.requestUri =
            'https://tradeallydev-dev-ed.my.salesforce.com/services/apexrest/FindTA';
        request.httpMethod = 'GET';
        request.params.put('territories','a0Kf4000005lHKIEA2');
        RestContext.request = request;
        RestContext.response = new RestResponse();
        // Call the method to test
        FindTARest.searchTradeAllies();
        // Verify results
        System.assert(RestContext.response.responseBody != null);
	}

	@IsTest
	private static void testSearchWithContactLevel() {
		List<String> sectors = getSectors();
        List<SingleFilterInfoWrapper__c> filterList = new List<SingleFilterInfoWrapper__c>();
		String query = FindTARest.constructQuery(	null,
													null,
													null, 
													sectors.get(0),
													null,
													null,
													null,
													null,
													null,
													null,
													false,
													filterList);
		if (FindTARest.getContactLevel() == FindTARest.CONTACT_LEVEL_COMPANY) {
			System.assert(query.containsIgnoreCase('Email_Address__c'));
		}
		if (FindTARest.getContactLevel() == FindTARest.CONTACT_LEVEL_PRIMARY) {
			System.assert(query.containsIgnoreCase('(Select name, email, phone from Contacts Where Level__c = \'Primary\')'));
		}
	}

	@IsTest
	private static void testSearchWithTerritory() {
		Territory__c territory = new Territory__c();
		insert territory;

		List<String> sectors = getSectors();
		
		List<SingleFilterInfoWrapper__c> filterList = new List<SingleFilterInfoWrapper__c>();
		
		String query = FindTARest.constructQuery(	null,
													null,
													null, 
													sectors.get(0),
													null,
													null,
													null,
													null,
													territory.Id,
													null,
													false,
													filterList);
		System.assert(String.isEmpty(query)); // search account that are not in territory result in null
	}

	@IsTest
	private static void testSearchWithBusinessType() {
		List<String> sectors = getSectors();
		List<String> businessTypes = getBusinessTypes();
		List<SingleFilterInfoWrapper__c> filterList = new List<SingleFilterInfoWrapper__c>();
		
		String query = FindTARest.constructQuery(	null,
													null,
													null, 
													sectors.get(0),
													businessTypes.get(0),
													null,
													null,
													null,
													null,
													null,
													false,
													filterList);
		System.assert(query.contains(' WHERE Business_Type__c INCLUDES ')); // search account that are not in territory result in null
	}

	@IsTest
	private static void testSearchWithCompanyName() {
		List<String> sectors = getSectors();
		List<SingleFilterInfoWrapper__c> filterList = new List<SingleFilterInfoWrapper__c>();
		
		String query = FindTARest.constructQuery(	null,
													null,
													'Test Company Name', 
													sectors.get(0),
													null,
													null,
													null,
													null,
													null,
													null,
													false,
													filterList);
		System.assert(query.contains(' WHERE Name = :companyName ')); // search account that are not in territory result in null
	}

	@IsTest
	private static void testSearchWithTradeAllyID() {
		List<String> sectors = getSectors();
		
		List<SingleFilterInfoWrapper__c> filterList = new List<SingleFilterInfoWrapper__c>();

			RecordType rt = [
			SELECT	Id
			FROM	RecordType
			WHERE	Name = 'Trade Ally'
		];
       
        Account a = new Account(
			Name = 'test account',
			Projects_Completed__c = 0,
			Business_Type__c = 'Contractor',
			Status__c = 'Active',
			Legal_Company_Name__c = 'test',
			Business_Structure__c = 'Other', 
			President_Owner_of_Company__c = 'test',
			RecordTypeId = rt.Id
		);
        insert a;
		
		String query = FindTARest.constructQuery(	a.Id,
													null,
													null, 
													sectors.get(0),
													null,
													null,
													null,
													null,
													null,
													null,
													false,
													filterList);
		System.assert(query.contains('FROM Account  WHERE  Id = :taId')); // search account that are not in territory result in null
	}

	// Test searching with valid sector-specialty combination
	@isTest static void testSearchWithSectorAndSpecailty() {
		RestRequest request = new RestRequest();
        request.requestUri = 'https://tradeallydev-dev-ed.my.salesforce.com/services/apexrest/FindTA';
        request.httpMethod = 'GET';
        request.params.put(FindTARest.QUERY_PARAM_SECTOR, 'Agriculture');
        request.params.put(FindTARest.QUERY_PARAM_SPECIALTIES, 'Irrigation'); // YHOU: by 2019-03-26, this should return at least 5 results
        request.params.put('territories','a0Kf4000005lHKIEA2');
        RestContext.request = request;
        RestContext.response = new RestResponse();
        FindTARest.searchTradeAllies();
        System.assert(RestContext.response.responseBody != null);
    }
    
    // Test searching with valid tier and contract status
    @isTest static void testSearchWithTierAndContractStatus() {
        RestRequest request = new RestRequest();
        request.requestUri = 'https://tradeallydev-dev-ed.my.salesforce.com/services/apexrest/FindTA';
        request.httpMethod = 'GET';
        request.params.put(FindTARest.QUERY_PARAM_TIER, 'true');
        request.params.put(FindTARest.QUERY_PARAM_NAME,'Test Comp');
        request.params.put(FindTARest.QUERY_PARAM_BUSINESS_TYPE,'Contractor,Manufacturing');
        request.params.put('latitude', '37.775');
        request.params.put('longitude', '-122.418');
        request.params.put('radius', '50');
        request.params.put('contracted', 'true');
        request.params.put(FindTARest.QUERY_PARAM_ID,'a0Kf4000005lHKIEA2');
        request.params.put(FindTARest.QUERY_PARAM_CONTRACTED, 'true'); // YHOU: by 2019-03-26, this should return at least 5 results
        RestContext.request = request;
        RestContext.response = new RestResponse();
        FindTARest.searchTradeAllies();
        System.assert(RestContext.response.responseBody != null);
    }
}