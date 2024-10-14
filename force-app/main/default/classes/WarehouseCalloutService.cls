public  class WarehouseCalloutService implements Queueable, Database.AllowsCallouts  {

    private static final String WAREHOUSE_URL = 'https://th-superbadge-apex.herokuapp.com/equipment';
   
    public void execute(QueueableContext context) {
        
          
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint(WAREHOUSE_URL);
        request.setMethod('GET');
        HttpResponse response = http.send(request);
        // If the request is successful, parse the JSON response.
        if(response.getStatusCode() == 200) {
            // Deserialize the JSON string into collections of primitive data types.
           List<Object> results = (List<Object>) JSON.deserializeUntyped(response.getBody());
    // System.debug(results);
    List<Product2> queryEquipmentsInSf = [SELECT Replacement_Part__c, Cost__c, Current_Inventory__c, Lifespan_Months__c, Maintenance_Cycle__c, Warehouse_SKU__c
                                          FROM Product2
                                         ];
    
    List<Product2> ItemsToAddOrUpdate = New List<Product2>();
    
    for(Object equipmentObj : results) {
        Map<String, Object> equipment = (Map<String, Object>) equipmentObj;
        Product2 equipmentToAddUpdate = New Product2();
            equipmentToAddUpdate.Replacement_Part__c = true;
            equipmentToAddUpdate.Cost__c = (Integer) equipment.get('cost');
            equipmentToAddUpdate.Current_Inventory__c=  (Integer) equipment.get('quantity');
            equipmentToAddUpdate.Lifespan_Months__c = (Integer) equipment.get('lifespan');
            equipmentToAddUpdate.Maintenance_Cycle__c = (Integer) equipment.get('maintenanceperiod');
            equipmentToAddUpdate.Warehouse_SKU__c = (String) equipment.get('_id');
            equipmentToAddUpdate.StockKeepingUnit = (String) equipment.get('sku');
        	equipmentToAddUpdate.Name =(String) equipment.get('name'); 
        
        ItemsToAddOrUpdate.add(equipmentToAddUpdate);
    }
            upsert ItemsToAddOrUpdate Warehouse_SKU__c;
        }
        
        
        
    }
    
}