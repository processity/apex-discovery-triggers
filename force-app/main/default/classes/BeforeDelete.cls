/**
 * @author aidan@mantratech.uk
 * @date 21/11/2023
 */

public interface BeforeDelete extends TriggerHandler {
    void beforeDelete(List<SObject> oldList);
}