@isTest
public with sharing class WarehouseSyncScheduleTest {
	
	 @isTest
    static void testScheduledJob() {
        // Set the mock callout response
        Test.setMock(HttpCalloutMock.class, new WarehouseCalloutServiceMock());
        
        // Create an instance of the schedulable class
       WarehouseSyncSchedule scheduler = new WarehouseSyncSchedule();
        
        // Schedule the job to run immediately
        String cronExpression = '0 0 0 * * ? *'; // Future date to ensure it runs now
        String jobId = System.schedule('Test 2 Warehouse Scheduler', cronExpression, scheduler);
        
        
        Test.startTest();
        // Execute the scheduled job
        System.schedule('Test Warehouse Scheduler', cronExpression, scheduler);
        Test.stopTest();
        
        // Verify the results
        // Query the products created or updated by the job
        List<Product2> products = [SELECT Id, Name, Maintenance_Cycle__c, Current_Inventory__c, Lifespan_Months__c, Cost__c, Warehouse_SKU__c
                                   FROM Product2
                                   WHERE Warehouse_SKU__c IN ('100003', '100004')];
        
        // Assertions
        System.assertEquals(2, products.size(), 'Two products should be created or updated.');
        
        Product2 product1 = products[0];
        Product2 product2 = products[1];
        
        // Assertions for product1
        if (product1.StockKeepingUnit == '123') {
            System.assertEquals('Generator 1000 kW', product1.Name, 'The name should be "Generator 1000 kW".');
            System.assertEquals(5, product1.Current_Inventory__c, 'The quantity should be 5.');
            System.assertEquals(365, product1.Maintenance_Cycle__c, 'The maintenance period should be 365.');
            System.assertEquals(120, product1.Lifespan_Months__c, 'The lifespan should be 120.');
            System.assertEquals(5000, product1.Cost__c, 'The cost should be 5000.');
        } 
        
        // Assertions for product2
        if (product2.StockKeepingUnit == '124') {
           System.assertEquals('Cooling Fan', product2.Name, 'The name should be "Cooling Fan".');
            System.assertEquals(183, product2.Current_Inventory__c, 'The quantity should be 183.');
            System.assertEquals(0, product2.Maintenance_Cycle__c, 'The maintenance period should be 0.');
            System.assertEquals(0, product2.Lifespan_Months__c, 'The lifespan should be 0.');
            System.assertEquals(300, product2.Cost__c, 'The cost should be 300.');
        }
    }	
    
}