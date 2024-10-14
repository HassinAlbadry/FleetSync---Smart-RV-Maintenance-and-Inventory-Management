public with sharing class WarehouseSyncSchedule implements Schedulable {
    // implement scheduled code here
      public void execute(SchedulableContext context) {
        System.enqueueJob(new WarehouseCalloutService());
          
         system.debug('it ran');
    }
}