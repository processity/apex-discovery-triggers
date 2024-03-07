/**
 * @author aidan@mantratech.uk
 * @date 20/11/2023
 * @description Entry point for the trigger framework. This factory class returns a DiscoveryTriggerHandler instance
 * for a given SObjectType, using ApexTypeImplementor to discover all trigger handlers in the org.
 */
// PMD False Positive: Field declarations cannot be at the start because the lazy-instantiated variables are required for the declarations
@SuppressWarnings('PMD.FieldDeclarationsShouldBeAtStart')
public without sharing class DiscoveryTriggerManager {
    private static String namespacePrefix;
    private static String discoveryTriggerManagerTestClassName;

    public static List<String> interfaceNames {
        get {
            if (interfaceNames == null) {
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
                if (namespacePrefix != interfaceNames[0]) {
                    Integer start = namespacePrefix.length() + 1;
                    for (Integer i = 0; i < interfaceNames.size(); i++) {
                        interfaceNames[i] = interfaceNames[i].substring(start);
                    }
                    discoveryTriggerManagerTestClassName = DiscoveryTriggerManagerTest.class.getName().substring(start);
                } else {
                    namespacePrefix = null;
                    discoveryTriggerManagerTestClassName = DiscoveryTriggerManagerTest.class.getName();
                }
            }
            return interfaceNames;
        }
        set;
    }

    // Note that we don't check ApexClass.IsValid. That would seem like a sensible precaution, but it does not indicate
    // whether or not the Apex Class is valid in the sense of being code that can be compiled and run.
    // See https://developer.salesforce.com/docs/atlas.en-us.object_reference.meta/object_reference/sforce_api_objects_apexclass.htm
    //
    //   "IsValid indicates whether any dependent metadata has changed since the class was last compiled (true) or not (false).
    //    The default value is false."
    //
    // Ensuring that trigger handlers contain compilable and runnable code, is therefore left to users of the framework.
    @TestVisible
    private static List<ApexTypeImplementor> allImplementors = [
        SELECT ClassName, ClassNamespacePrefix, InterfaceName, InterfaceNamespacePrefix
        FROM ApexTypeImplementor
        WHERE
            InterfaceName IN :interfaceNames
            AND InterfaceNamespacePrefix = :namespacePrefix
            AND IsConcrete = TRUE
            AND (NOT ClassName LIKE :discoveryTriggerManagerTestClassName + '.%')
        WITH SYSTEM_MODE
        ORDER BY ClassNamespacePrefix ASC, ClassName ASC 
    ];

    private static Map<SObjectType, DiscoveryTriggerHandler> sObjectTypeToDiscoveryTriggerHandler;

    public static DiscoveryTriggerHandler getInstance(SObjectType sObjectType) {
        if (sObjectTypeToDiscoveryTriggerHandler == null) {
            sObjectTypeToDiscoveryTriggerHandler = new Map<SObjectType, DiscoveryTriggerHandler>();

            Integer allImplementorsSize = allImplementors.size();

            for (Integer i = 0; i < allImplementorsSize; i++) {
                ApexTypeImplementor thisApexTypeImplementor = allImplementors[i];
                TriggerHandler triggerHandler = (TriggerHandler) Type.forName(
                        thisApexTypeImplementor.ClassNamespacePrefix,
                        thisApexTypeImplementor.ClassName
                    )
                    .newInstance();
                String fullQualifiedInterfaceName =
                    (thisApexTypeImplementor.InterfaceNamespacePrefix == null
                        ? ''
                        : thisApexTypeImplementor.InterfaceNamespacePrefix + '.') +
                    thisApexTypeImplementor.InterfaceName;
                TriggerOperation thisTriggerOperation = InterfaceNameToTriggerOperation.get(fullQualifiedInterfaceName);
                SObjectType triggerHandlerSObjectType = triggerHandler.getSObjectType();

                DiscoveryTriggerHandler thisDiscoveryTriggerHandler = sObjectTypeToDiscoveryTriggerHandler.get(
                    triggerHandlerSObjectType
                );
                if (thisDiscoveryTriggerHandler == null) {
                    thisDiscoveryTriggerHandler = new DiscoveryTriggerHandler();
                    sObjectTypeToDiscoveryTriggerHandler.put(triggerHandlerSObjectType, thisDiscoveryTriggerHandler);
                }

                thisDiscoveryTriggerHandler.addHandler(thisTriggerOperation, triggerHandler);
            }

            for (DiscoveryTriggerHandler thisDiscoveryTriggerHandler : sObjectTypeToDiscoveryTriggerHandler.values()) {
                thisDiscoveryTriggerHandler.sort();
            }
        }

        return sObjectTypeToDiscoveryTriggerHandler.get(sObjectType);
    }

    public static void handle() {
        getInstance(Trigger.new?.getSObjectType() ?? Trigger.old.getSObjectType()).handle();
    }
}
