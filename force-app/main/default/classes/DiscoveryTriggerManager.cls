/**
 * @author aidan@mantratech.uk
 * @date 20/11/2023
 */

public without sharing class DiscoveryTriggerManager {

    private static List<ApexTypeImplementor> allImplementors = [
            SELECT Id, ClassName, InterfaceName 
            FROM ApexTypeImplementor 
            WHERE InterfaceName IN ('BeforeInsert', 'BeforeUpdate')
            AND ApexClass.IsValid = TRUE
            AND IsConcrete = TRUE
            ORDER BY ClassNamespacePrefix ASC, ClassName ASC
    ];
    
    private static Map<SObjectType, DiscoveryTriggerManager> sObjectTypeToTriggerManager = new Map<SObjectType, DiscoveryTriggerManager>();
    private Map<TriggerOperation, List<TriggerHandler>> triggerOperationToHandlers = new Map<TriggerOperation, List<TriggerHandler>>();
    
    public static DiscoveryTriggerManager getInstance(SObjectType sObjectType) {
        DiscoveryTriggerManager triggerManager = sObjectTypeToTriggerManager.get(sObjectType);
        if(triggerManager == null) {
            triggerManager = new DiscoveryTriggerManager(sObjectType);
            sObjectTypeToTriggerManager.put(sObjectType, triggerManager);
        }
        return triggerManager;
    }
    
    private DiscoveryTriggerManager(SObjectType sObjectType) {
        List<ApexTypeImplementor> remainingImplementors = new List<ApexTypeImplementor>();
        
        for(ApexTypeImplementor thisApexTypeImplementor : allImplementors) {
            TriggerHandler triggerHandler = (TriggerHandler)Type.forName(thisApexTypeImplementor.ClassName).newInstance();
            TriggerOperation thisTriggerOperation = InterfaceNameToTriggerOperation.get(thisApexTypeImplementor.InterfaceName);
            
            if(triggerHandler.getSObjectType() == sObjectType) {
                List<TriggerHandler> handlers = triggerOperationToHandlers.get(thisTriggerOperation);
                if (handlers == null) {
                    handlers = new List<TriggerHandler>();
                    triggerOperationToHandlers.put(thisTriggerOperation, handlers);
                }
                handlers.add(triggerHandler);
            } else {
                remainingImplementors.add(thisApexTypeImplementor);
            }
        }
        
        allImplementors = remainingImplementors;
        
        for(TriggerOperation thisTriggerOperation : triggerOperationToHandlers.keySet()) {
            List<TriggerHandler> handlers = triggerOperationToHandlers.get(thisTriggerOperation);
            handlers.sort(new TypeImplementorComparator());
        }
    }
    public void handle() {
        handle(new TriggerContext(Trigger.operationType, Trigger.old, Trigger.new));
    }
    
    public void handle(TriggerContext triggerContext) {
        List<TriggerHandler> triggerHandlers = triggerOperationToHandlers.get(triggerContext.operation);
        
        Integer size = triggerHandlers?.size();
        for(Integer i=0; i < size; i++) {
            handleInstance(triggerHandlers[i], triggerContext);
        }
    }

    private static void handleInstance(TriggerHandler handlerInstance, TriggerContext triggerContext) {
        switch on triggerContext.operation {
            when BEFORE_UPDATE {
                ((BeforeUpdate)handlerInstance).handleBeforeUpdate(triggerContext.oldList, triggerContext.newList);
            }
            when BEFORE_INSERT {
                ((BeforeInsert)handlerInstance).handleBeforeInsert(triggerContext.newList);
            }
//            when BEFORE_DELETE {
//                ((BeforeDelete)handlerInstance).handleBeforeDelete(oldList);
//            }
//            when AFTER_UPDATE {
//                ((AfterUpdate)handlerInstance).handleAfterUpdate(oldList, newList);
//            }
//            when AFTER_INSERT {
//                ((AfterInsert)handlerInstance).handleAfterInsert(newList);
//            }
//            when AFTER_DELETE {
//                ((AfterDelete)handlerInstance).handleAfterDelete(oldList);
//            }
//            when AFTER_UNDELETE {
//                ((AfterUndelete)handlerInstance).handleAfterUndelete(newList);
//            }
        }
    }
    
    private class TypeImplementorComparator implements Comparator<TriggerHandler> {
        public Integer compare(TriggerHandler left, TriggerHandler right) {
            return left.getOrder() - right.getOrder();
        }
    }
    
    private class TriggerContext {
        
        public TriggerOperation operation;
        public List<SObject> oldList;
        public List<SObject> newList;
        
        public TriggerContext(TriggerOperation operation, List<SObject> oldList, List<SObject> newList) {
            this.operation = operation;
            this.oldList = oldList;
            this.newList = newList;
        }
    }
}