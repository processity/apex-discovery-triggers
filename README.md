# Apex Discovery Triggers

This trigger handler framework discovers classes that implement trigger handlers by querying `ApexTypeImplementor`.

That provides a slim trigger framework, with ordering, that does not require custom metadata or any other type of table
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

## Installation

Either:

 - Paste this onto the end of your My Domain URL: /packaging/installPackage.apexp?p0=04tWS000000HTQbYAO
 - Include in your SFDX project as "Discovery Triggers": "04tWS000000HTQbYAO"

## Examples

See the [unPackaged](unPackaged) directory for a working example trigger.