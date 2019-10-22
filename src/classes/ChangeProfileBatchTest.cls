@IsTest
public class ChangeProfileBatchTest {
    @testSetup static void setup() {
        // Create an account
        Account acct = new Account(Name='Test Account');
        acct.external_Id__c = '1';
        insert acct;
        // Create a contact
        Contact contact = new Contact();
        contact.Lastname ='test';
        contact.Level__c = 'Primary';
        contact.AccountId = acct.id;
        insert contact;
        //Create a user
        Profile profile = [SELECT Id FROM Profile WHERE Name='Custom Community Profile']; 
        User user = new User(Alias = 'aliasTst', Email='opatzke@nexant.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = profile.Id, 
            TimeZoneSidKey='America/Los_Angeles', UserName='testuser@testorg.com');
        user.ContactId = contact.Id;
        insert user;
        Application_Settings__c setting = new Application_Settings__c(
			Name = Constants.SUBSCRIBED_PROFILE_NAME,
			Value__c = 'Custom Customer Community Plus'
		);
		insert setting;
    }
    
	@IsTest
	static void changeProfileStartTest() {
        List<User> users = [SELECT Id FROM User WHERE UserName='testuser@testorg.com' LIMIT 1];
    	ChangeProfileBatch cp = new ChangeProfileBatch();
        Database.QueryLocator dq = cp.start(null);
        try {
        	cp.execute(null, users);
        } catch (Exception error) {
            
        }
    }
}