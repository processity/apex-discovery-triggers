/**
 * @author aidan@mantratech.uk
 * @date 20/11/2023
 * @description (if required)
 */

public with sharing class AccountNameAddFoo implements BeforeInsert {
    
    public void handleBeforeInsert(List<Account> newRecords) {
        for (Account a : newRecords) {
            a.Name = a.Name + ' Foo';
        }
    }

    public Integer getOrder() {
        return 0;
    }
    
    public Boolean canHandle(SObjectType type) {
        return type == Account.SObjectType;
    }
}