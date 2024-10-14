@isTest
public with sharing class MaintenanceRequestHelperTest {
    // implement scheduled code here
    @isTest
    //test if trigger is inserting new cases when an old case with routine is closed
    static void caseUpdate() {
        
         // Set up test data
        // Create a product with a maintenance cycle
        Product2 testProduct = new Product2(
            Name = 'Test Equipment',
            Maintenance_Cycle__c = 30,
            Replacement_Part__c = true
        );
        insert testProduct;
        
         Vehicle__c testVehicle = new Vehicle__c(
            Name = 'Test Vehicle'
            // Set other required fields for Vehicle__c here if needed
        );
        insert testVehicle;
       
        
         
        // Create the initial case
        Case testCase = new Case(
            Type = 'Repair',
            Status = 'New',
            Vehicle__c = testVehicle.Id,
            ProductId = testProduct.Id
        );
        
        insert testCase;
        
          // Create an equipment maintenance item related to the case
        Equipment_Maintenance_Item__c testItem = new Equipment_Maintenance_Item__c(
            Equipment__c = testCase.ProductId,
            maintenance_Request__c = testCase.Id
            
        );
        insert testItem;
        
        testCase.Status = 'closed'; 
        System.Test.startTest();
        update testCase;
        System.Test.stopTest();
        
         // Query the new maintenance cases created by the trigger
        List<Case> newMaintenanceCases = [SELECT Id, Type, Date_Reported__c, Vehicle__c, ProductId, Date_Due__c, Subject
                                          FROM Case
                                          WHERE Type = 'Routine Maintenance'];
        
       
        // Assert that a new maintenance case was created
        System.assertEquals(1, newMaintenanceCases.size(), 'One new maintenance case should be created.');
        
         Case newMaintenanceCase = newMaintenanceCases[0];
        
        // Assert the new maintenance case has the correct values
        System.assertEquals('Routine Maintenance', newMaintenanceCase.Type, 'The new case type should be Routine Maintenance.');
        System.assertEquals('this is a maintenance request created by trigger', newMaintenanceCase.Subject, 'The new case subject should be set.');
        System.assertEquals(Date.today(), newMaintenanceCase.Date_Reported__c, 'The Date Reported should be today.');
        System.assertEquals(testCase.Vehicle__c, newMaintenanceCase.Vehicle__c, 'The Vehicle__c should match the original case.');
        System.assertEquals(testCase.ProductId, newMaintenanceCase.ProductId, 'The ProductId should match the original case.');
        System.assertEquals(Date.today().addDays(30), newMaintenanceCase.Date_Due__c, 'The Date Due should be 30 days from today.');
        
        
        List<Equipment_Maintenance_Item__c> newRelatedItems = [SELECT Equipment__c, Maintenance_Request__c
                                                               FROM Equipment_Maintenance_Item__c
                                                               WHERE Maintenance_Request__c = :newMaintenanceCase.Id];
        
         
        // Assert the related equipment maintenance items were copied correctly
        System.assertEquals(1, newRelatedItems.size(), 'One related equipment maintenance item should be copied.');
        System.assertEquals(testItem.Equipment__c, newRelatedItems[0].Equipment__c, 'The Equipment__c should match the original item.');
        System.assertEquals(newMaintenanceCase.Id, newRelatedItems[0].Maintenance_Request__c, 'The Maintenance_Request__c should be the new maintenance case.');
    }

}