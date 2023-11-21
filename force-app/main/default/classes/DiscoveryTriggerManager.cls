/**
 * @author aidan@mantratech.uk
 * @date 20/11/2023
 */

public without sharing class DiscoveryTriggerManager {

    private static List<ApexTypeImplementor> allImplementors = [
            SELECT ClassName, InterfaceName
            FROM ApexTypeImplementor 
            WHERE InterfaceName IN (
                    :BeforeInsert.class.getName(), 
                    :BeforeUpdate.class.getName(),
                    :BeforeDelete.class.getName(),
                    :AfterInsert.class.getName(),
                    :AfterUpdate.class.getName(),
                    :AfterDelete.class.getName(),
                    :AfterUndelete.class.getName()
            )
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
            handlers.sort(new SortTriggerHandlersByOrder());
        }
    }
    public void handle() {
        handle(new TriggerContext(Trigger.operationType, Trigger.old, Trigger.new));
    }
    
    public void handle(TriggerContext triggerContext) {
        List<TriggerHandler> triggerHandlers = triggerOperationToHandlers.get(triggerContext.operation);
        
        Integer size = triggerHandlers?.size();
        for(Integer i=0; i < size; i++) {
            triggerContext.handleUsing(triggerHandlers[i]);
        }
    }
    
    private class SortTriggerHandlersByOrder implements Comparator<TriggerHandler> {
        public Integer compare(TriggerHandler left, TriggerHandler right) {
            return left.getOrder() - right.getOrder();
        }
    }
}