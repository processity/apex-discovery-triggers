/**
 * @author aidan@mantratech.uk
 * @date 21/11/2023
 */

public interface AfterUpdate extends TriggerHandler {
    void onAfterUpdate(List<SObject> oldList, List<SObject> newList);
}
