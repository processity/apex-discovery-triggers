/**
 * @author aidan@mantratech.uk
 * @date 21/11/2023
 */

public class TriggerContext {

    private List<SObject> oldList;
    private List<SObject> newList;
    public TriggerOperation operation {get; private set;}

    public TriggerContext(TriggerOperation operation, List<SObject> oldList, List<SObject> newList) {
        this.operation = operation;
        this.oldList = oldList;
        this.newList = newList;
    }

    public void handleUsing(TriggerHandler handlerInstance) {
        switch on operation {
            when BEFORE_UPDATE {
                ((BeforeUpdate)handlerInstance).handleBeforeUpdate(oldList, newList);
            }
            when BEFORE_INSERT {
                ((BeforeInsert)handlerInstance).handleBeforeInsert(newList);
            }
            when BEFORE_DELETE {
                ((BeforeDelete)handlerInstance).handleBeforeDelete(oldList);
            }
            when AFTER_UPDATE {
                ((AfterUpdate)handlerInstance).handleAfterUpdate(oldList, newList);
            }
            when AFTER_INSERT {
                ((AfterInsert)handlerInstance).handleAfterInsert(newList);
            }
            when AFTER_DELETE {
                ((AfterDelete)handlerInstance).handleAfterDelete(oldList);
            }
            when AFTER_UNDELETE {
                ((AfterUndelete)handlerInstance).handleAfterUndelete(newList);
            }
        }
    }
}
