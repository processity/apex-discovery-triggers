/**
 * @author aidan@mantratech.uk
 * @date 21/11/2023
 */

public interface AfterDelete extends TriggerHandler {
    void afterDelete(List<SObject> oldList);
}