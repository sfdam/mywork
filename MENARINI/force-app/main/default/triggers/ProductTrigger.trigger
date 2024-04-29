/**
 * Created by alai on 17/03/2022.
 */

trigger ProductTrigger on Product2 (after update) {

    if (Trigger.isUpdate)
    {
        if(Trigger.isAfter) {
            System.debug('@@@ ProductTrigger afterUpdate START');
            THR_ProductTriggerHandler.discontinuedProductSpain(Trigger.newMap,Trigger.oldMap);
            System.debug('@@@ ProductTrigger afterUpdate END');

        }
    }

}