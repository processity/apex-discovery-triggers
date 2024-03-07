/**
 * @author aidan@mantratech.uk
 * @date 20/11/2023
 */

public interface BeforeInsert extends TriggerHandler {
    void onBeforeInsert(List<SObject> newRecords);
}
