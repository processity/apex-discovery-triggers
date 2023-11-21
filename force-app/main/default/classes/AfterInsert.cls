/**
 * @author aidan@mantratech.uk
 * @date 21/11/2023
 */

public interface AfterInsert extends TriggerHandler {
    void handleAfterInsert(List<SObject> newList);
}