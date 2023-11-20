/**
 * @author aidan@mantratech.uk
 * @date 20/11/2023
 */

@IsTest
private class AccountNameAddFooTest {

    @IsTest
    static void testBehavior() {
        Account testAccount = new Account(Name = 'Test Account');
        
        Test.startTest();
        insert testAccount;
        Test.stopTest();
        
        Account result = [SELECT Name FROM Account WHERE Id = :testAccount.Id];

        Assert.areEqual('Test Account Foo', result.Name);
    }
}