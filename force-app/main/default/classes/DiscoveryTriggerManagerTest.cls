/**
 * @author aidan@mantratech.uk
 * @date 22/11/2023
 */

@IsTest
public class DiscoveryTriggerManagerTest {
    
    private static List<TriggerOperation> handlerRuns = new List<TriggerOperation>();
    private static List<String> handlerNames = new List<String>();
    private static Integer testHandlerContactOneOrder = 0;
    private static Integer testHandlerContactTwoOrder = 1;

    static {
        DiscoveryTriggerManager.allImplementors = new List<ApexTypeImplementor>{
                createImplementor(TestHandlerAccount.class.getName(), BeforeInsert.class.getName()),
                createImplementor(TestHandlerAccount.class.getName(), BeforeUpdate.class.getName()),
                createImplementor(TestHandlerAccount.class.getName(), BeforeDelete.class.getName()),
                createImplementor(TestHandlerAccount.class.getName(), AfterInsert.class.getName()),
                createImplementor(TestHandlerAccount.class.getName(), AfterUpdate.class.getName()),
                createImplementor(TestHandlerAccount.class.getName(), AfterDelete.class.getName()),
                createImplementor(TestHandlerAccount.class.getName(), AfterUndelete.class.getName()),
                createImplementor(TestHandlerContactOne.class.getName(), BeforeInsert.class.getName()),
                createImplementor(TestHandlerContactTwo.class.getName(), BeforeInsert.class.getName())
        };
    }
    @IsTest
    static void allTheMethods() {
        
        List<TriggerOperation> expected = new List<TriggerOperation> {
            TriggerOperation.BEFORE_INSERT,
            TriggerOperation.BEFORE_UPDATE,
            TriggerOperation.BEFORE_DELETE,
            TriggerOperation.AFTER_INSERT,
            TriggerOperation.AFTER_UPDATE,
            TriggerOperation.AFTER_DELETE,
            TriggerOperation.AFTER_UNDELETE
        };
        
        for(TriggerOperation thisTriggerOperation : expected) {
            DiscoveryTriggerManager.getInstance(Account.SObjectType).handle(new TriggerContext(thisTriggerOperation, new List<Account>(), new List<Account>()));
        }
        
        Assert.areEqual(expected, DiscoveryTriggerManagerTest.handlerRuns);
    }

    @IsTest
    static void orderingOne() {
        DiscoveryTriggerManager.getInstance(Contact.SObjectType).handle(new TriggerContext(TriggerOperation.BEFORE_INSERT, null, new List<Contact>()));
        
        Assert.areEqual(new List<String>{ TestHandlerContactOne.class.getName(), TestHandlerContactTwo.class.getName() }, DiscoveryTriggerManagerTest.handlerNames);
    }

    @IsTest
    static void orderingTwo() {
        DiscoveryTriggerManagerTest.testHandlerContactOneOrder = 1;
        DiscoveryTriggerManagerTest.testHandlerContactTwoOrder = 0;
        
        DiscoveryTriggerManager.getInstance(Contact.SObjectType).handle(new TriggerContext(TriggerOperation.BEFORE_INSERT, null, new List<Contact>()));
        
        Assert.areEqual(new List<String>{ TestHandlerContactTwo.class.getName(), TestHandlerContactOne.class.getName() }, DiscoveryTriggerManagerTest.handlerNames);
    }

    public class TestHandlerAccount implements BeforeInsert, BeforeUpdate, BeforeDelete, AfterInsert, AfterUpdate, AfterDelete, AfterUndelete {
        public SObjectType getSObjectType() {
            return Account.SObjectType;
        }

        public void handleBeforeInsert(List<SObject> newRecords) {
            DiscoveryTriggerManagerTest.handlerRuns.add(TriggerOperation.BEFORE_INSERT);
        }

        public void handleBeforeUpdate(List<SObject> oldRecords, List<SObject> newRecords) {
            DiscoveryTriggerManagerTest.handlerRuns.add(TriggerOperation.BEFORE_UPDATE);
        }

        public void handleBeforeDelete(List<SObject> oldList) {
            DiscoveryTriggerManagerTest.handlerRuns.add(TriggerOperation.BEFORE_DELETE);
        }

        public void handleAfterInsert(List<SObject> newList) {
            DiscoveryTriggerManagerTest.handlerRuns.add(TriggerOperation.AFTER_INSERT);
        }

        public void handleAfterUpdate(List<SObject> oldList, List<SObject> newList) {
            DiscoveryTriggerManagerTest.handlerRuns.add(TriggerOperation.AFTER_UPDATE);
        }

        public void handleAfterDelete(List<SObject> oldList) {
            DiscoveryTriggerManagerTest.handlerRuns.add(TriggerOperation.AFTER_DELETE);
        }

        public void handleAfterUndelete(List<SObject> newList) {
            DiscoveryTriggerManagerTest.handlerRuns.add(TriggerOperation.AFTER_UNDELETE);
        }
    }

    public class TestHandlerContactOne implements BeforeInsert, OrderedTriggerHandler {
        public Integer getOrder() {
            return DiscoveryTriggerManagerTest.testHandlerContactOneOrder;
        }

        public SObjectType getSObjectType() {
            return Contact.SObjectType;
        }

        public void handleBeforeInsert(List<SObject> newRecords) {
            DiscoveryTriggerManagerTest.handlerNames.add(TestHandlerContactOne.class.getName());
        }
    }
    
    public class TestHandlerContactTwo implements BeforeInsert, OrderedTriggerHandler {
        public Integer getOrder() {
            return DiscoveryTriggerManagerTest.testHandlerContactTwoOrder;
        }

        public SObjectType getSObjectType() {
            return Contact.SObjectType;
        }

        public void handleBeforeInsert(List<SObject> newRecords) {
            DiscoveryTriggerManagerTest.handlerNames.add(TestHandlerContactTwo.class.getName());
        }
    }
    
    private static ApexTypeImplementor createImplementor(String className, String interfaceName) {
        return (ApexTypeImplementor)JSON.deserialize(
                '{' + String.format('"ClassName": "{0}", "InterfaceName": "{1}"', new List<String>{ className, interfaceName }) + '}',
                ApexTypeImplementor.class);
    }
}