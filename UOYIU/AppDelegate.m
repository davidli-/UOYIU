//
//  AppDelegate.m
//  UOYIU
//
//  Created by Macmafia on 2018/2/28.
//  Copyright © 2018年 Macmafia. All rights reserved.
//

#import "AppDelegate.h"
#import "UOSubObject.h"

@interface AppDelegate()
@property (nonatomic, strong) NSManagedObjectContext *context;
@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application
didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    return YES;
}

#pragma mark -Business
- (void)coreDataTest
{
    [self initContext];
    
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

- (void)initContext
{
    //从应用程序包中加载模型文件
    //方法1：将项目中所有的 .xcodemodel 文件连接合并为一个datamodel
    //NSManagedObjectModel *model = [NSManagedObjectModel mergedModelFromBundles:nil];
    //方法2：只取指定的 .xcodemodel
    NSURL *modelPath = [[NSBundle mainBundle] URLForResource:@"Model" withExtension:@"momd"];
    NSManagedObjectModel *model = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelPath];
    //传入模型，初始化 NSPersistentStoreCoordinator：
    NSPersistentStoreCoordinator *psc = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:model];
    //构建SQLite文件路径：
    NSString *filePath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSURL *url = [NSURL fileURLWithPath:[filePath stringByAppendingPathComponent:@"person.sqlite"] isDirectory:NO];
    ///*测试代码
//    if ([[NSFileManager defaultManager] fileExistsAtPath:url.path]) {
//        [[NSFileManager defaultManager] removeItemAtPath:url.path error:nil];
//    }
    //*/
    //添加持久化存储库，这里使用SQLite作为存储库：
    NSError *storeError;
    NSDictionary *options = @{NSMigratePersistentStoresAutomaticallyOption:@(YES),
                              NSInferMappingModelAutomaticallyOption:@(NO)};//InferMapping=YES时 系统会自动推断映射模型 =NO时，使用我们自定义的映射模型
    NSPersistentStore *store = [psc addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:url options:options error:&storeError];
    if (!store) {
        NSLog(@"加载数据库时出错:%@",[storeError userInfo]);
    }else{
        NSLog(@"成功加载数据库!");
    }
    //初始化上下文，设置persistentStoreCoordinator属性：
    NSManagedObjectContext *context = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    context.persistentStoreCoordinator = psc;
    context.mergePolicy = NSErrorMergePolicy;//冲突合并策略
    _context = context;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onHandleSaveNotification:)
                                                 name:NSManagedObjectContextDidSaveNotification
                                               object:nil];
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
        NSManagedObject *person = [NSEntityDescription insertNewObjectForEntityForName:@"Person" inManagedObjectContext:_context];
        //设置属性：
        [person setValue:[NSString stringWithFormat:@"Davii%d",i] forKey:@"name"];
        [person setValue:@(20+i) forKey:@"age"];
        
        //传入上下文，创建一个Card实体对象：
        NSManagedObject *card = [NSEntityDescription insertNewObjectForEntityForName:@"Card" inManagedObjectContext:_context];
        [card setValue:[NSString stringWithFormat:@"%d",10000+i] forKey:@"no"];
        
        //设置Person和Card之间的关联关系：
        [person setValue:card forKey:@"card"];
    }
    //利用上下文对象，将数据同步到持久化存储库：
    [_context performBlockAndWait:^{
        NSError *error;
        [_context save:&error];
        if (error) {
            NSLog(@"+++++++++保存数据入库时出错!");
        }else{
            NSLog(@"+++++++++成功保存数据入库!");
        }
    }];
}

- (void)deleteData
{
    //建立请求，连接实体
    NSEntityDescription *person = [NSEntityDescription entityForName:@"Person" inManagedObjectContext:_context];
    NSFetchRequest *request = [NSFetchRequest new];
    request.entity = person;
    
    //设置条件过滤（搜索name属性中包含”Davii“的那条记录，注意等号必须加，可以有空格，也可以是==）
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name=%@",@"Davii0"];
    request.predicate = predicate;
    
    //遍历所有实体，将每个实体的信息存放在数组中
    NSError *error;
    NSArray *resultArr = [_context executeFetchRequest:request error:&error];
    if (!error && resultArr.count) {
        //删除并保存
        for (NSManagedObject *p in resultArr) {
            [_context deleteObject:p];
            NSLog(@"++++成功删除Person：%@！",[p valueForKey:@"name"]);
        }
        [_context performBlockAndWait:^{
            [_context save:nil];
        }];
    }
}

-(void)updateData
{
    //建立请求，连接实体
    NSFetchRequest *request = [[NSFetchRequest alloc] init] ;
    NSEntityDescription *person = [NSEntityDescription entityForName:@"Person" inManagedObjectContext:_context];
    request.entity = person;
    
    //设置条件过滤（搜索name属性为“Davii2”的数据）
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name=%@", @"Davii2"];
    request.predicate = predicate;
    
    //遍历所有实体，将每个实体的信息存放在数组中
    NSArray *arr = [_context executeFetchRequest:request error:nil];
    
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
        [_context performBlockAndWait:^{
            [_context save:nil];
        }];
    }
}

-(void)queryData
{
    //初始化一个查询请求：
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    //设置要查询的实体：
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Person" inManagedObjectContext:_context];
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
    NSArray *objs = [_context executeFetchRequest:request error:&error];
    if (error) {
        [NSException raise:@"++++查询错误" format:@"%@", [error localizedDescription]];
    }
    //遍历数据：
    for (NSManagedObject *obj in objs) {
        NSLog(@"++++name=%@，cardNo:%@", [obj valueForKey:@"name"],[obj valueForKeyPath:@"card.no"]);
    }
}
@end
