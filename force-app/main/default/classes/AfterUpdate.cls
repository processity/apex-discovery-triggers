/**
 * @author aidan@mantratech.uk
 * @date 21/11/2023
 */

public interface AfterUpdate extends TriggerHandler {
    void handleAfterUpdate(List<SObject> oldList, List<SObject> newList);
}