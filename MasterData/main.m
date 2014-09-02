//
//  main.m
//  MasterData
//
//  Created by Kenneth on 8/29/14.
//  Copyright (c) 2014 fatken. All rights reserved.
//

#import "Brands.h"
#import "Series.h"


static NSManagedObjectModel *managedObjectModel()
{
    static NSManagedObjectModel *model = nil;
    if (model != nil) {
        return model;
    }
    
    NSString *path = @"CarUsage";
    path = [path stringByDeletingPathExtension];
    NSURL *modelURL = [NSURL fileURLWithPath:[path stringByAppendingPathExtension:@"mom"]];
    model = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    
    return model;
}

static NSManagedObjectContext *managedObjectContext()
{
    static NSManagedObjectContext *context = nil;
    if (context != nil) {
        return context;
    }

    @autoreleasepool {
        context = [[NSManagedObjectContext alloc] init];
        
        NSPersistentStoreCoordinator *coordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:managedObjectModel()];
        [context setPersistentStoreCoordinator:coordinator];
        
        NSString *STORE_TYPE = NSSQLiteStoreType;
        
        NSString *path = @"CarUsage";
        NSURL *url = [NSURL fileURLWithPath:[path stringByAppendingPathExtension:@"sqlite"]];
        
        NSError *error;
        NSPersistentStore *newStore = [coordinator addPersistentStoreWithType:STORE_TYPE configuration:nil URL:url options:nil error:&error];
        
        if (newStore == nil) {
            NSLog(@"Store Configuration Failure %@", ([error localizedDescription] != nil) ? [error localizedDescription] : @"Unknown Error");
        }
    }
    return context;
}


static void deleteAllObjects(NSString *entityDescription, NSManagedObjectContext *context) {
    NSFetchRequest *request = [NSFetchRequest new];
    NSEntityDescription *entity = [NSEntityDescription entityForName:entityDescription inManagedObjectContext:context];
    [request setEntity:entity];
    
    NSError *error;
    NSArray *items = [context executeFetchRequest:request error:&error];
    
    for (NSManagedObject *managedObject in items) {
    	[context deleteObject:managedObject];
    	DLog(@"%@ object deleted",entityDescription);
    }
    if (![context save:&error]) {
    	DLog(@"Error deleting %@ - error:%@",entityDescription,error);
    }
}

static void prepareBrands(NSManagedObjectContext *context) {
    DLog(@"Deleting all records in BRANDS...");
    
    deleteAllObjects(@"Brands", context);
    
    NSError *err = nil;
    NSString *dataPath = [[NSBundle mainBundle] pathForResource:@"brands" ofType:@"json"];
    NSArray *brands = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfFile:dataPath]
                                                      options:kNilOptions
                                                        error:&err];
    
    DLog(@"Imported brands: %@", brands);
    
    [brands enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        Brands *brand = [NSEntityDescription insertNewObjectForEntityForName:@"Brands"
                                                      inManagedObjectContext:context];
        brand.id = [NSNumber numberWithInteger:[[obj objectForKey:@"id"] integerValue]];
        brand.isSubbrand = [NSNumber numberWithBool:[[obj objectForKey:@"isSubbrand"] boolValue]];
        brand.logoURL = [obj objectForKey:@"logoURL"];
        brand.name = [obj objectForKey:@"name"];
        brand.origName = [obj objectForKey:@"origName"];
        brand.pinyinName = [obj objectForKey:@"pinyinName"];
        
        if ([brand.isSubbrand isEqualToNumber:[NSNumber numberWithInt:1]]) {
            // Search for the existing parent brand;
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"id = %@", [obj objectForKey:@"parentBrand"]];
            NSFetchRequest *parentBrandRequest = [NSFetchRequest new];
            [parentBrandRequest setPredicate:predicate];
            NSEntityDescription *entity = [NSEntityDescription entityForName:@"Brands"
                                                      inManagedObjectContext:context];
            [parentBrandRequest setEntity:entity];
            
            brand.parentBrand = [[context executeFetchRequest:parentBrandRequest error:nil] firstObject];
        }
        
        NSError *error;
        if (![context save:&error]) {
            DLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
        }
    }];
    
    NSFetchRequest *request = [NSFetchRequest new];
    NSEntityDescription *entities = [NSEntityDescription entityForName:@"Brands" inManagedObjectContext:context];
    [request setEntity:entities];
    NSArray *fetchedObjects = [context executeFetchRequest:request error:&err];
    
    for (Brands *idx in fetchedObjects) {
        NSLog(@"Name: %@", idx.name);
        NSSet *hasSeries = idx.series;
        NSLog(@"series number: %lu", [hasSeries count]);
    }
}

static void prepareSeries(NSManagedObjectContext *context) {
    DLog(@"Deleting all records in SERIES...");
    
    deleteAllObjects(@"Series", context);
    NSError *error = nil;
    if (![context save:&error]) {
        DLog(@"Error while saving %@", ([error localizedDescription] != nil) ? [error localizedDescription] : @"Unknown Error");
    }
    
    NSError *err = nil;
    NSString *dataPath = [[NSBundle mainBundle] pathForResource:@"series" ofType:@"json"];
    NSArray *series = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfFile:dataPath]
                                                      options:kNilOptions
                                                        error:&err];
    DLog(@"Importing series: %@", series);
    [series enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        Series *series = [NSEntityDescription insertNewObjectForEntityForName:@"Series"
                                                       inManagedObjectContext:context];
        series.id = [NSNumber numberWithInteger:[[obj objectForKey:@"id"] integerValue]];
        series.name = [obj objectForKey:@"name"];
        series.rank = [obj objectForKey:@"rank"];
        
        // NSInteger brandId = [[obj objectForKey:@"brandId"] integerValue];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K = %@",@"id", [obj objectForKey:@"brandId"]];
        
        NSFetchRequest *request = [NSFetchRequest new];
        [request setPredicate:predicate];
        NSEntityDescription *brands = [NSEntityDescription entityForName:@"Brands" inManagedObjectContext:context];
        [request setEntity:brands];
        
        Brands *whoMake = [[context executeFetchRequest:request error:nil] firstObject];
        DLog(@"%@ makes %@", whoMake.name, series.name);
        
        series.brand = whoMake;
        NSError *error;
        if (![context save:&error]) {
            DLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
        }
        // Brands *whomake = [context executeFetchRequest:request error:&err];
    }];
}


int main(int argc, const char * argv[])
{

    @autoreleasepool {
        // Create the managed object context
        NSManagedObjectContext *context = managedObjectContext();
        
        // [MagicalRecord setupCoreDataStackWithAutoMigratingSqliteStoreNamed:@"CarUsage.sqlite"];
        
        prepareBrands(context);
        
        prepareSeries(context);
        
        /*
        NSError *reseterror = nil;
        NSPersistentStore *store = [[[context persistentStoreCoordinator] persistentStores] lastObject];
        NSURL *storeURL = [[context persistentStoreCoordinator] URLForPersistentStore:store];
        [context lock];
        [context reset];
        if ([[context persistentStoreCoordinator] removePersistentStore:store error:&reseterror]) {
            [[NSFileManager defaultManager] removeItemAtURL:storeURL error:&reseterror];
            [[context persistentStoreCoordinator] addPersistentStoreWithType:NSSQLiteStoreType
                                                               configuration:nil
                                                                         URL:storeURL
                                                                     options:nil
                                                                       error:&reseterror];
        }
         */
        
        // Custom code here...
        // Save the managed object context
        //[MagicalRecord cleanUp];
        
    }
    return 0;
}



