/**
 * @author aidan@mantratech.uk
 * @date 21/11/2023
 */

public class InterfaceNameToTriggerOperation {
    
    private static Map<String, TriggerOperation> interfaceNameToTriggerOperation = new Map<String, TriggerOperation> {
            BeforeInsert.class.getName() => TriggerOperation.BEFORE_INSERT,
            BeforeUpdate.class.getName() => TriggerOperation.BEFORE_UPDATE,
            BeforeDelete.class.getName() => TriggerOperation.BEFORE_DELETE,
            AfterInsert.class.getName() => TriggerOperation.AFTER_INSERT,
            AfterUpdate.class.getName() => TriggerOperation.AFTER_UPDATE,
            AfterDelete.class.getName() => TriggerOperation.AFTER_DELETE,
            AfterUndelete.class.getName() => TriggerOperation.AFTER_UNDELETE
    };
    
    public static TriggerOperation get(String interfaceName) {
        return interfaceNameToTriggerOperation.get(interfaceName);
    }
}