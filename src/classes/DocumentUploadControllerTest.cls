@IsTest 
private class DocumentUploadControllerTest {

	@IsTest
	private static void testGetCurrentUserInfo() {
		User currentUser = DocumentUploadController.getCurrentUserInfo();
		User assumedUser = [SELECT Id, Name, AccountId, ContactId, Contact.AccountId FROM User Where Id = :UserInfo.getUserId() LIMIT 1].get(0);

		System.assert(currentUser.Id == assumedUser.Id);
	}

	@IsTest
	private static void testServerGetTadeAllyReferenceFieldSet() {
		List<Object> fieldSets = DocumentUploadController.serverGetTradeAllyReferenceFieldSet();
		System.assert(fieldSets != null);
		System.assert(fieldSets.size() > 0);
	}

	@IsTest
	private static void testServerGetLicenseFieldSet() {
		List<Object> fieldSets = DocumentUploadController.serverGetLicenseFieldSet();
		System.assert(fieldSets != null);
		System.assert(fieldSets.size() > 0);
	}

	@IsTest
	private static void testServerGetInsuranceFieldSet() {
		List<Object> fieldSets = DocumentUploadController.serverGetInsuranceFieldSet();
		System.assert(fieldSets != null);
		System.assert(fieldSets.size() > 0);
	}

	@IsTest
	private static void testServerGetCertificationFieldSet() {
		List<Object> fieldSets = DocumentUploadController.serverGetCertificationFieldSet();
		System.assert(fieldSets != null);
		System.assert(fieldSets.size() > 0);
	}

	@IsTest
	private static void testServerGetTaxFieldSet() {
		List<Object> fieldSets = DocumentUploadController.serverGetTaxFieldSet();
		System.assert(fieldSets != null);
		System.assert(fieldSets.size() > 0);
	}

	@IsTest
	private static void testServerGetOtherDocumentFieldSet() {
		List<Object> fieldSets = DocumentUploadController.serverGetOtherDocumentFieldSet();
		System.assert(fieldSets != null);
		System.assert(fieldSets.size() > 0);
	}

	@IsTest
	private static void testServerGetExistingRecords() {
		String applicationId;
		List<SObject> output;

		// has applicationId and objectType
		// TODO: there is no easy way of creating mock Application__c, User, and Account :( 

		// has applicationId, but invalid objectType
		output = DocumentUploadController.serverGetExistingRecords('', 'Random_Type__c');
		System.assert(output == null);

		// has objectType, but no applicationId
		output = DocumentUploadController.serverGetExistingRecords('', 'License__c');
		output = DocumentUploadController.serverGetExistingRecords('', 'Insurance__c');
		output = DocumentUploadController.serverGetExistingRecords('', 'Certification__c');
		output = DocumentUploadController.serverGetExistingRecords('', 'Tax__c');
		output = DocumentUploadController.serverGetExistingRecords('', 'Other_Document__c');

		// has no valid argument
		output = DocumentUploadController.serverGetExistingRecords('', '');
		System.assert(output == null);
	}

	@IsTest
	private static void testServerGetRelatedDocuments() {
		List<String> output;

		// invalid recordId results in null
		output = DocumentUploadController.serverGetRelatedDocuments(null);
		System.assert(output == null);

		output = DocumentUploadController.serverGetRelatedDocuments('');
		System.assert(output == null);

		// valid recordId
		License__c obj = new License__c(Type__c='ABC');
		insert obj;
		output = DocumentUploadController.serverGetRelatedDocuments(obj.Id);
		System.assert(output != null); 
	}

	@IsTest
	private static void testServerAssociateFilesWithApplicationId () {
		List<ContentDocument> documents = [SELECT Id, Title From ContentDocument];
		List<Id> fileIds = new List<Id>();
		for (ContentDocument each: documents) {
			fileIds.add(each.ID);
		}

		// Create an application object
		Account newAccount = new Account(
				Name = 'newAccount'
		);
		insert newAccount;
		Application__c app = new Application__c(
				Trade_Ally__c = newAccount.Id,
            	Business_Types__c = 'Contractor'
		);
		insert app;

		Boolean result = DocumentUploadController.serverAssociateFilesWithApplicationId(app.Id, fileIds);
		System.assert(result);

		List<ContentDocumentLink> links = [SELECT ID FROM ContentDocumentLink WHERE LinkedEntityId = :app.Id AND ContentDocumentId in :fileIds];
		System.assert(links.size() == fileIds.size());
		
	}

	@IsTest
	private static void testServerCreateApplicationDocumentJunction () {

		String profileName = 'Custom Community Basic Profile'; // TODO

		// UserRole role = [SELECT ID FROM UserRole Where PortalType = 'None' LIMIT 1];

		List<Profile> listOfProfiles = [
			SELECT	Id
			FROM	Profile
			WHERE	Name =: profileName//'Partner Community User'
		];

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
       
        Contact c = new Contact(
			LastName ='test contact',
			AccountId = a.Id,
			Level__c = 'Primary'
		);
        insert c;
                  
        User communityUser = new User(
			Alias = 'test123',
			Email = 'test123@noemail.com',
			EmailEncodingKey = 'UTF-8',
			LastName = 'Testing',
			LanguageLocaleKey = 'en_US',
			LocaleSidKey = 'en_US',
			ProfileId = listOfProfiles[0].Id,
			Country = 'United States',
			IsActive = true,
            ContactId = c.Id,
			TimeZoneSidKey='America/Los_Angeles',
			Username='tester@noemail.com'
		);

		Application__c app = new Application__c(
				Trade_Ally__c = a.Id,
            	Business_Types__c = 'Contractor'
		);
		insert app;

		// Create base objects
		Certification__c cert = new Certification__c(Expiry_Date__c = Date.today());
		Insurance__c insurance = new Insurance__c();
		License__c license = new License__c();
		Tax__c tax = new Tax__c();
		Other_Document__c otherDoc = new Other_Document__c();

		insert cert;
		insert insurance;
		insert license;
		insert tax;
		insert otherDoc;

		Boolean result_cert = DocumentUploadController.serverCreateApplicationDocumentJunction(app.Id, cert.Id, 'Certification__c');
		Boolean result_insurance = DocumentUploadController.serverCreateApplicationDocumentJunction(app.Id, insurance.Id, 'Insurance__c');
		Boolean result_license = DocumentUploadController.serverCreateApplicationDocumentJunction(app.Id, license.Id, 'License__c');
		Boolean result_tax = DocumentUploadController.serverCreateApplicationDocumentJunction(app.Id, tax.Id, 'Tax__c');
		Boolean result_otherDoc = DocumentUploadController.serverCreateApplicationDocumentJunction(app.Id, otherDoc.Id, 'Other_Document__c');

		System.assert(result_cert);
		System.assert(result_insurance);
		System.assert(result_license);
		System.assert(result_tax);
		System.assert(result_otherDoc);
	}
}