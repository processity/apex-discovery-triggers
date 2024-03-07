/**
 * @author aidan@mantratech.uk
 * @date 05/12/2023
 * @description Set the order that trigger handlers are run for a particular SObjectType and trigger event. Triggers
 * are run in ascending order
 */

public interface OrderedTriggerHandler {
    /**
     * @return The order that trigger handlers are run for a particular SObjectType and trigger event. Triggers
     * are run in ascending order
     */
    Integer getOrder();
}
