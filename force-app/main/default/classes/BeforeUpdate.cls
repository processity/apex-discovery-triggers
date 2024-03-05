/**
 * @author aidan@mantratech.uk
 * @date 20/11/2023
 */

public interface BeforeUpdate extends TriggerHandler {
    void beforeUpdate(List<SObject> oldRecords, List<SObject> newRecords);
}