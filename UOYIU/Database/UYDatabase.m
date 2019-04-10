//
//  UYDatabase.m
//  UOYIU
//
//  Created by Macmafia on 2018/6/26.
//  Copyright © 2018年 Macmafia. All rights reserved.
//

#import "UYDatabase.h"
@interface UYDatabase()
@property (nonatomic, strong) NSManagedObjectContext *mainQueueContext;
@property (nonatomic, strong) NSManagedObjectContext *backgroundContext;
@end

static UYDatabase *mDatabase = nil;

@implementation UYDatabase

+ (instancetype)shareInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (!mDatabase) {
            mDatabase = [[UYDatabase alloc] init];
        }
    });
    return mDatabase;
}


- (instancetype)init
{
    if (self = [super init])
    {
        /*从应用程序包中加载模型文件
         #方案1：将项目中所有的 .xcodemodel 文件连接合并为一个datamodel
         NSManagedObjectModel *datamodel = [NSManagedObjectModel mergedModelFromBundles:nil];
        */
        //方案2：只取指定的 .xcodemodel 文件
        NSURL *modelPath = [[NSBundle mainBundle] URLForResource:@"Model" withExtension:@"momd"];
        NSManagedObjectModel *datamodel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelPath];
        
        //传入模型，初始化 NSPersistentStoreCoordinator：
        NSPersistentStoreCoordinator *psc = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:datamodel];
        
        //构建SQLite文件路径：
        NSString *filePath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
        NSURL *url = [NSURL fileURLWithPath:[filePath stringByAppendingPathComponent:@"person.sqlite"] isDirectory:NO];
        /*测试代码
            if ([[NSFileManager defaultManager] fileExistsAtPath:url.path]) {
                [[NSFileManager defaultManager] removeItemAtPath:url.path error:nil];
            }
        */
        //添加持久化存储库（这里使用SQLite作为存储库）
        NSError *storeError;
        NSDictionary *options = @{NSMigratePersistentStoresAutomaticallyOption:@(YES),
                                  NSInferMappingModelAutomaticallyOption:@(NO)};//InferMapping=YES时 系统会自动推断映射模型 =NO时，使用我们自定义的映射模型
        NSPersistentStore *store = [psc addPersistentStoreWithType:NSSQLiteStoreType configuration:nil
                                                               URL:url
                                                           options:options
                                                             error:&storeError];
        if (!store) {
            NSLog(@"加载数据库时出错:%@",[storeError userInfo]);
        }else{
            NSLog(@"成功加载数据库!");
        }
        
        //初始化运行在主队列上的上下文，处理UI相关事务。
        NSManagedObjectContext *mainQueueContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
        mainQueueContext.persistentStoreCoordinator = psc;
        mainQueueContext.mergePolicy = NSErrorMergePolicy;//冲突合并策略
        _mainQueueContext = mainQueueContext;
        
        //iOS5之前，可以使用多个MOC分别在不同队列或线程中执行不同任务，最终在context执行save时手动同步数据
        //初始化运行在私有队列中的上下文，处理其他复杂运算。
        NSManagedObjectContext *backgroundContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
        backgroundContext.persistentStoreCoordinator = psc;
        backgroundContext.mergePolicy = NSErrorMergePolicy;//冲突合并策略
        _backgroundContext = backgroundContext;
        
        //当一个MOC发生改变并持久化到本地时，系统并不会将其他MOC缓存在内存中的NSManagedObject对象改变。所以这就需要我们监听通知，在MOC发生改变时，将其他MOC数据更新。
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(onHandleSaveNotification:)
                                                     name:NSManagedObjectContextDidSaveNotification
                                                   object:nil];
        
        /*在iOS5之后，MOC可以设置parentContext，一个parentContext可以拥有多个ChildContext。在ChildContext执行save操作后，会将操作push到parentContext，由parentContext去完成真正的save操作，而ChildContext所有的改变都会被parentContext所知晓，这解决了之前MOC手动同步数据的问题。
         需要注意的是，在ChildContext调用save方法之后，此时并没有将数据写入存储区，还需要调用parentContext的save方法。因为ChildContext并不拥有PSC，ChildContext也不需要设置PSC，所以需要parentContext调用PSC来执行真正的save操作。也就是只有拥有PSC的MOC执行save操作后，才是真正的执行了写入存储区的操作。
         
         // 创建主队列MOC，用于执行UI操作
         NSManagedObjectContext *mainMOC = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
         mainMOC.persistentStoreCoordinator = PSC;
         
         // 创建私有队列MOC，用于执行其他耗时操作，backgroundMOC并不需要设置PSC
         NSManagedObjectContext *backgroundMOC = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
         backgroundMOC.parentContext = mainMOC;
         
         // 私有队列的MOC和主队列的MOC，在执行save操作时，都应该调用performBlock:方法，在自己的队列中执行save操作。
         // 私有队列的MOC执行完自己的save操作后，还调用了主队列MOC的save方法，来完成真正的持久化操作，否则不能持久化到本地
         [backgroundMOC performBlock:^{
         [backgroundMOC save:nil];
         
         [mainMOC performBlock:^{
         [mainMOC save:nil];
         }];
         }];
         
         */
    }
    return self;
}

- (void)coreDataTest
{
    //增
    [self addData];
    [self queryData];
    //删
    [self updateData];
    [self queryData];
    //改
    [self deleteData];
    [self queryData];
}

- (void)onHandleSaveNotification:(NSNotification*)notification
{
    /*
     NSManagedObjectContext是非线程安全的，所以不能跨线程传递使用。
     而通知是同步执行的，在通知对应的回调方法中所处的线程，和发出通知的MOC执行操作时所处的线程是同一个线程，也就是系统performBlock:回调方法分配的线程。
     所以其他MOC在通知回调方法中，需要注意使用performBlock:方法，并在block体中执行操作。
     */
    NSManagedObjectContext *context = notification.object;
    // 这里需要做判断操作，判断当前改变的MOC是否我们将要做同步的MOC，如果就是当前MOC自己做的改变，那就不需要再同步自己了。
    if ([context isEqual:_mainQueueContext]) {
        NSLog(@"++this is on mainQueueContext");
    }else if ([context isEqual:_backgroundContext]){
        NSLog(@"++this is on backgroundContext");
    }else{
        NSLog(@"++this is on other context");
    }
    // 由于项目中可能存在多个PSC，所以下面还需要判断PSC是否当前操作的PSC，如果不是当前PSC则不需要同步，不要去同步其他本地存储的数据。
    [context performBlock:^{
        [context mergeChangesFromContextDidSaveNotification:notification];
    }];
}

#pragma mark -数据库操作
- (void)addData
{
    for (int i = 0; i<5; i++) {
        //传入上下文，创建一个Person实体对象：
        NSManagedObject *person = [NSEntityDescription insertNewObjectForEntityForName:@"Person"
                                                                inManagedObjectContext:_mainQueueContext];
        //设置属性：
        [person setValue:[NSString stringWithFormat:@"Davii%d",i] forKey:@"name"];
        [person setValue:@(20+i) forKey:@"age"];
        
        //传入上下文，创建一个Card实体对象：
        NSManagedObject *card = [NSEntityDescription insertNewObjectForEntityForName:@"Card"
                                                              inManagedObjectContext:_mainQueueContext];
        [card setValue:[NSString stringWithFormat:@"%d",10000+i] forKey:@"no"];
        
        //设置Person和Card之间的关联关系：
        [person setValue:card forKey:@"card"];
    }
    //利用上下文对象，将数据同步到持久化存储库：
    [_mainQueueContext performBlock:^{//异步执行block
        NSLog(@"%@",[NSThread currentThread]);//因为是异步+主队列context，所以还是在主线程上
    }];
    
    [_mainQueueContext performBlockAndWait:^{//wait表示同步执行block，防止多线程下数据冲突
        NSError *error;
        [_mainQueueContext save:&error];
        if (error) {
            NSLog(@"+++++++++保存数据入库时出错!");
        }else{
            NSLog(@"+++++++++成功保存数据入库!");
        }
        NSLog(@"增加数据save完成，当前线程：%@",[NSThread currentThread]);//因为是同步+主队列context，所以还是在主线程上执行
    }];
}

- (void)deleteData
{
    //建立请求，连接实体
    NSEntityDescription *person = [NSEntityDescription entityForName:@"Person"
                                              inManagedObjectContext:_mainQueueContext];
    NSFetchRequest *request = [NSFetchRequest new];
    request.entity = person;
    
    //设置条件过滤（搜索name属性中包含”Davii“的那条记录，注意等号必须加，可以有空格，也可以是==）
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name=%@",@"Davii0"];
    request.predicate = predicate;
    
    //遍历所有实体，将每个实体的信息存放在数组中
    NSError *error;
    NSArray *resultArr = [_mainQueueContext executeFetchRequest:request error:&error];
    if (!error && resultArr.count) {
        //删除并保存
        for (NSManagedObject *p in resultArr) {
            [_mainQueueContext deleteObject:p];
            NSLog(@"++++成功删除Person：%@！",[p valueForKey:@"name"]);
        }
        [_mainQueueContext performBlockAndWait:^{
            [_mainQueueContext save:nil];
        }];
    }
}

-(void)updateData
{
    //建立请求，连接实体
    NSFetchRequest *request = [[NSFetchRequest alloc] init] ;
    NSEntityDescription *person = [NSEntityDescription entityForName:@"Person"
                                              inManagedObjectContext:_backgroundContext];
    request.entity = person;
    
    //设置条件过滤（搜索name属性为“Davii2”的数据）
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name=%@", @"Davii2"];
    request.predicate = predicate;
    
    //遍历所有实体，将每个实体的信息存放在数组中
    NSArray *arr = [_backgroundContext executeFetchRequest:request error:nil];
    
    //更改并保存
    NSInteger count = arr.count;
    if(count){
        for (int i = 0; i < count; i++){
            NSManagedObject *p = arr[i];
            NSString *pName = [p valueForKey:@"name"];
            NSString *newName = [NSString stringWithFormat:@"Name%d",i];
            [p setValue:newName forKey:@"name"];
            NSLog(@"++++更新前Name:%@,更新后Name:%@",pName,newName);
        }
        //保存
        [_backgroundContext performBlock:^{
            NSLog(@"更新数据，当前线程：%@",[NSThread currentThread]);//异步+私有队列context，所以是在子线程中执行
        }];
        [_backgroundContext performBlockAndWait:^{
            [_backgroundContext save:nil];
            NSLog(@"更新数据save完成，当前线程：%@",[NSThread currentThread]);//因为是同步+私有队列，不具备开辟新线程的能力，所以还是在主线程中执行
        }];
    }
}

-(void)queryData
{
    //初始化一个查询请求：
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    //设置要查询的实体：
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Person"
                                              inManagedObjectContext:_mainQueueContext];
    request.entity = entity;
    
    //设置排序（按照age降序）：
    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"age" ascending:NO];
    request.sortDescriptors = [NSArray arrayWithObject:sort];
    
    //设置条件过滤(name like '%Davii%')：
    //设置条件过滤时，数据库里面的%要用*来代替
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name like %@", @"*Davii*"];
    request.predicate = predicate;
    
    //执行请求：
    NSError *error = nil;
    NSArray *objs = [_mainQueueContext executeFetchRequest:request error:&error];
    if (error) {
        [NSException raise:@"++++查询错误" format:@"%@", [error localizedDescription]];
    }
    //遍历数据：
    for (NSManagedObject *obj in objs) {
        NSLog(@"++++name=%@，cardNo:%@", [obj valueForKey:@"name"],[obj valueForKeyPath:@"card.no"]);
    }
}

@end
