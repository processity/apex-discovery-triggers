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
                ((BeforeUpdate)handlerInstance).beforeUpdate(oldList, newList);
            }
            when BEFORE_INSERT {
                ((BeforeInsert)handlerInstance).beforeInsert(newList);
            }
            when BEFORE_DELETE {
                ((BeforeDelete)handlerInstance).beforeDelete(oldList);
            }
            when AFTER_UPDATE {
                ((AfterUpdate)handlerInstance).afterUpdate(oldList, newList);
            }
            when AFTER_INSERT {
                ((AfterInsert)handlerInstance).afterInsert(newList);
            }
            when AFTER_DELETE {
                ((AfterDelete)handlerInstance).afterDelete(oldList);
            }
            when AFTER_UNDELETE {
                ((AfterUndelete)handlerInstance).afterUndelete(newList);
            }
        }
    }
}
