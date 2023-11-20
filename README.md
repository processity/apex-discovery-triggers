# Apex Discovery Triggers

This trigger handler framework discovers classes that implement trigger handlers by querying `ApexTypeImplementor`.

This provides a slim trigger framework, with ordering, that does not require custom metadata or any other type of table
to drive the triggers. 

Here is an example trigger implementation:

```apex
public class MyTrigger implements BeforeInsert {

    public Integer getOrder() {
        return 0;
    }

    public Boolean canHandle(SObjectType type) {
        return type == Account.SObjectType;
    }

    public void handleBeforeInsert(List<Account> newRecords) {
        // do something
    }
}
```