/**
 * @author aidan@mantratech.uk
 * @date 21/11/2023
 */

public interface BeforeDelete extends TriggerHandler {
    void onBeforeDelete(List<SObject> oldList);
}
