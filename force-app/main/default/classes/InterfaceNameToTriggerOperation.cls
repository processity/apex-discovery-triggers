/**
 * @author aidan@mantratech.uk
 * @date 21/11/2023
 */

public with sharing class InterfaceNameToTriggerOperation {
    
    private static Map<String, TriggerOperation> interfaceNameToTriggerOperation = new Map<String, TriggerOperation> {
            BeforeInsert.class.getName() => TriggerOperation.BEFORE_INSERT,
            BeforeUpdate.class.getName() => TriggerOperation.BEFORE_UPDATE,
            'BeforeDelete' => TriggerOperation.BEFORE_DELETE,
            'AfterInsert' => TriggerOperation.AFTER_INSERT,
            'AfterUpdate' => TriggerOperation.AFTER_UPDATE,
            'AfterDelete' => TriggerOperation.AFTER_DELETE,
            'AfterUndelete' => TriggerOperation.AFTER_UNDELETE
    };
    
    public static TriggerOperation get(String interfaceName) {
        return interfaceNameToTriggerOperation.get(interfaceName);
    }
}