/**
 * @author aidan@mantratech.uk
 * @date 20/11/2023
 * @description Entry point for the trigger framework. This factory class returns a DiscoveryTriggerHandler instance 
 * for a given SObjectType, using ApexTypeImplementor to discover all trigger handlers in the org.
 */

public without sharing class DiscoveryTriggerManager {

    @TestVisible
    private static List<ApexTypeImplementor> allImplementors = [
            SELECT ClassName, InterfaceName
            FROM ApexTypeImplementor 
            WHERE InterfaceName IN (
                    :BeforeInsert.class.getName(), 
                    :BeforeUpdate.class.getName(),
                    :BeforeDelete.class.getName(),
                    :AfterInsert.class.getName(),
                    :AfterUpdate.class.getName(),
                    :AfterDelete.class.getName(),
                    :AfterUndelete.class.getName()
            )
            AND ApexClass.IsValid = TRUE
            AND IsConcrete = TRUE
            AND (NOT(ClassName LIKE : DiscoveryTriggerManagerTest.class.getName() + '.%')) 
            ORDER BY ClassNamespacePrefix ASC, ClassName ASC
    ];
    
    private static Map<SObjectType, DiscoveryTriggerHandler> sObjectTypeToDiscoveryTriggerHandler;
    
    public static DiscoveryTriggerHandler getInstance(SObjectType sObjectType) {
        
        if(sObjectTypeToDiscoveryTriggerHandler == null) {
            sObjectTypeToDiscoveryTriggerHandler = new Map<SObjectType, DiscoveryTriggerHandler>();

            Integer allImplementorsSize = allImplementors.size();

            for(Integer i=0; i < allImplementorsSize; i++) {
                ApexTypeImplementor thisApexTypeImplementor = allImplementors[i];
                TriggerHandler triggerHandler = (TriggerHandler)Type.forName(thisApexTypeImplementor.ClassName).newInstance();
                TriggerOperation thisTriggerOperation = InterfaceNameToTriggerOperation.get(thisApexTypeImplementor.InterfaceName);

                DiscoveryTriggerHandler thisDiscoveryTriggerHandler = sObjectTypeToDiscoveryTriggerHandler.get(sObjectType);
                if(thisDiscoveryTriggerHandler == null) {
                    thisDiscoveryTriggerHandler = new DiscoveryTriggerHandler();
                    sObjectTypeToDiscoveryTriggerHandler.put(sObjectType, thisDiscoveryTriggerHandler);
                }
                thisDiscoveryTriggerHandler.addHandler(thisTriggerOperation, triggerHandler);
            }

            for(DiscoveryTriggerHandler thisDiscoveryTriggerHandler : sObjectTypeToDiscoveryTriggerHandler.values()) {
                thisDiscoveryTriggerHandler.sort();
            }
        }
        
        return sObjectTypeToDiscoveryTriggerHandler.get(sObjectType);
    }
}