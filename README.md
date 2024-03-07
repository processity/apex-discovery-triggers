# Apex Discovery Triggers

This trigger handler framework discovers classes that implement trigger handlers by querying `ApexTypeImplementor`.

This provides a slim trigger framework, with ordering, that does not require custom metadata or any other type of table
to drive the triggers. 

Here is an example trigger implementation:

```apex
public class MyTrigger implements BeforeInsert {
    
    public SObjectType getSObjectType() {
        return Account.SObjectType;
    }

    public void onBeforeInsert(List<Account> newRecords) {
        // do something
    }
}
```

If ordering is important, then you specify that with an extra interface. For a particular `SObjectType` and trigger 
event the handlers are run in ascending order of the numbers they declare with `getOrder()`. The absence of `OrderedTriggerHandler`
implies an order value of `0`.

```apex
public class MyTrigger implements BeforeInsert, OrderedTriggerHandler {
    
    public SObjectType getSObjectType() {
        return Account.SObjectType;
    }

    public Integer getOrder() {
        return 10;
    }
    
    public void onBeforeInsert(List<Account> newRecords) {
        // do something
    }
}
```

And an example trigger:

```apex
trigger AccountTrigger on Account (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    DiscoveryTriggerManager.getInstance(Account.SObjectType).handle();
}
```

Note that this library loads all trigger events for all `SObjectType`s on first invocation and caches them in a static 
variable. So, the performance profile will be a relatively slow start at the beginning of a transaction, then fast 
performance for further triggers. 