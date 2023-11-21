/**
 * @author aidan@mantratech.uk
 * @date 20/11/2023
 */

trigger AccountTrigger on Account (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    DiscoveryTriggerManager.getInstance(Account.SObjectType).handle();
}