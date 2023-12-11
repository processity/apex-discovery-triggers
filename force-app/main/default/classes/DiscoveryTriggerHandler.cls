/**
 * @author aidan@mantratech.uk
 * @date 11/12/2023
 * @description A trigger handler for a specific SObjectType
 */

public inherited sharing class DiscoveryTriggerHandler {

    private Map<TriggerOperation, List<TriggerHandler>> triggerOperationToHandlers = new Map<TriggerOperation, List<TriggerHandler>>();
    
    public void addHandler(TriggerOperation triggerOperation, TriggerHandler triggerHandler) {
        List<TriggerHandler> triggerHandlers = triggerOperationToHandlers.get(triggerOperation);
        if (triggerHandlers == null) {
            triggerHandlers = new List<TriggerHandler>();
            triggerOperationToHandlers.put(triggerOperation, triggerHandlers);
        }
        triggerHandlers.add(triggerHandler);
    }

    public void sort() {
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

        Integer triggerHandlersSize = triggerHandlers?.size();
        for(Integer i=0; i < triggerHandlersSize; i++) {
            triggerContext.handleUsing(triggerHandlers[i]);
        }
    }

    private class SortTriggerHandlersByOrder implements Comparator<TriggerHandler> {
        public Integer compare(TriggerHandler left, TriggerHandler right) {
            Integer leftOrder = left instanceof OrderedTriggerHandler ? ((OrderedTriggerHandler)left).getOrder() : 0;
            Integer rightOrder = right instanceof OrderedTriggerHandler ? ((OrderedTriggerHandler)right).getOrder() : 0;
            return leftOrder - rightOrder;
        }
    }
}