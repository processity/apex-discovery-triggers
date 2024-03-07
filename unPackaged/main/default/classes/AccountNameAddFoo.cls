/**
 * @author aidan@mantratech.uk
 * @date 20/11/2023
 * @description Adds 'Foo' to the end of the Account Name
 */

public with sharing class AccountNameAddFoo implements BeforeInsert {
    
    public void onBeforeInsert(List<Account> newRecords) {
        for (Account a : newRecords) {
            a.Name = a.Name + ' Foo';
        }
    }

    public SObjectType getSObjectType() {
        return Account.SObjectType;
    }
}