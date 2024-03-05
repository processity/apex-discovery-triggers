/**
 * @author aidan@mantratech.uk
 * @date 21/11/2023
 */

public interface AfterUndelete {
    void afterUndelete(List<SObject> newList);
}