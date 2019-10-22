@isTest
private class FieldInfoWrapperTest {
    @TestSetup
    static void testSetup(){
        Account accObj = new Account();
            accObj.Name = 'test account';
            accObj.put(Constants.NAMESPACE +'Projects_Completed__c', 0);
            accObj.put(Constants.NAMESPACE +'Business_Type__c','Contractor');
            accObj.put(Constants.NAMESPACE +'Status__c','Active');
            accObj.put(Constants.NAMESPACE +'Legal_Company_Name__c','test');
            accObj.put(Constants.NAMESPACE +'Business_Structure__c','Other'); 
            accObj.put(Constants.NAMESPACE +'President_Owner_of_Company__c','test');
            accObj.put(Constants.NAMESPACE +'Date_Incorporated__c', System.today());
        
        insert accObj; 
        Contact conObj = new Contact();
            conObj.LastName ='test contact';
            conObj.AccountId = accObj.Id;
            conObj.put(Constants.NAMESPACE +'Level__c','Primary');
        insert conObj;
    }
    @isTest
    static void fieldInfoWrapperTest(){
        String accName = 'test account';
        String conName = 'test Contact';
        String queryaccount = 'SELECT Id,NumberOfEmployees,Name, ' + Constants.NAMESPACE + 'Date_Incorporated__c' + ' FROM Account WHERE Name =\''+accName +'\'';
        String querycontact = 'SELECT Id,LastName,Name, ' + Constants.NAMESPACE + 'Level__c' + ' FROM Contact WHERE LastName =\''+conName +'\'';
        Account accObj = Database.query(queryaccount);
        Contact conObj = Database.query(querycontact);
        
        List<Contact> conList = new List<Contact>();
        conList.add(conObj);
        
        String fieldSetName = Constants.NAMESPACE + 'Profile_Tab_Primary';
        
        //getting the contact field sets.
        Schema.DescribeFieldResult dfr = Contact.Description.getDescribe();
        List<Schema.FieldSetMember> fieldSetObjList = Schema.SObjectType.Contact.fieldSets.getMap().get(fieldSetName).getFields();
        //Schema.FieldSetMember fieldSetObj
        Schema.FieldSetMember fieldSetObj = fieldSetObjList[0];
        Schema.FieldSetMember fieldSetObj2 = fieldSetObjList[1];
        Schema.FieldSetMember fieldSetObj4 = fieldSetObjList[6];
        
        
        //Getting Account Field sets
        Schema.DescribeFieldResult dfracc = Account.Description.getDescribe();
        fieldSetName = Constants.NAMESPACE + 'Start_Application_Company_Info';
        List<Schema.FieldSetMember> fieldSetObjLists = Schema.SObjectType.Account.fieldSets.getMap().get(fieldSetName).getFields();
        Schema.FieldSetMember fieldSetObj5 = fieldSetObjLists[4];
        
        FieldInfoWrapper feildsinfo = new FieldInfoWrapper(null);
        feildsinfo.parentObjectType = 'Account';
        feildsinfo.valueBoolean = true;
        feildsinfo.valueNumber = 8.02;
        feildsinfo.valueDateTime = System.today();
   
        
        FieldInfoWrapper fieldInfoWrapper = new FieldInfoWrapper('label');
        //FieldInfoWrapper fieldInfoWrapper_one = new FieldInfoWrapper('Contact', 'Contact', accObj.Id, 'label', 'Contact');
        //FieldInfoWrapper fieldInfoWrapper_two = new FieldInfoWrapper(conList,'label','Contact',accObj.Id,'Contact');
        FieldInfoWrapper fieldInfoWrapper_three = new FieldInfoWrapper('LastName',fieldSetObj,conObj,dfr,'Contact');
        FieldInfoWrapper fieldInfoWrapper_three_one = new FieldInfoWrapper('LastName',fieldSetObj2,conObj,dfr,'Contact');
        FieldInfoWrapper fieldInfoWrapper_three_three = new FieldInfoWrapper('Level__c',fieldSetObj4,conObj,dfr,'Contact');
        //FieldInfoWrapper fieldInfoWrapper_three_acctwo = new FieldInfoWrapper('Date_Incorporated__c',fieldSetObj5,accObj,dfracc,'Account');
        
        System.assertEquals(feildsinfo.isValid, true);
        System.assertEquals(feildsinfo.type,'ATTACHMENT');
    }
}