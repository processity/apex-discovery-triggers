/**
 * @author aidan@mantratech.uk
 * @date 20/11/2023
 * @description Entry point for the trigger framework. This factory class returns a DiscoveryTriggerHandler instance 
 * for a given SObjectType, using ApexTypeImplementor to discover all trigger handlers in the org.
 */

public without sharing class DiscoveryTriggerManager {

    private static String namespacePrefix;

    public static List<String> interfaceNames {get {
        if(interfaceNames == null) {
            interfaceNames = new List<String>{
                    BeforeInsert.class.getName(),
                    BeforeUpdate.class.getName(),
                    BeforeDelete.class.getName(),
                    AfterInsert.class.getName(),
                    AfterUpdate.class.getName(),
                    AfterDelete.class.getName(),
                    AfterUndelete.class.getName()
            };
            namespacePrefix = interfaceNames[0].substringBefore('.');
            if(namespacePrefix != interfaceNames[0])  {
                Integer start = namespacePrefix.length() + 1;
                for(Integer i=0; i < interfaceNames.size(); i++) {
                    interfaceNames[i] = interfaceNames[i].substring(start);
                }
            }
        }
        return interfaceNames;
    } set;}

    @TestVisible
    private static List<ApexTypeImplementor> allImplementors = [
            SELECT ClassName, ClassNamespacePrefix, InterfaceName, InterfaceNamespacePrefix
            FROM ApexTypeImplementor
            WHERE InterfaceName IN :interfaceNames
            AND InterfaceNamespacePrefix = :namespacePrefix
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
                TriggerHandler triggerHandler = (TriggerHandler)Type.forName(thisApexTypeImplementor.ClassNamespacePrefix, thisApexTypeImplementor.ClassName).newInstance();
                TriggerOperation thisTriggerOperation = InterfaceNameToTriggerOperation.get(thisApexTypeImplementor.InterfaceNamespacePrefix + '.' + thisApexTypeImplementor.InterfaceName);
                SObjectType triggerHandlerSObjectType = triggerHandler.getSObjectType();

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