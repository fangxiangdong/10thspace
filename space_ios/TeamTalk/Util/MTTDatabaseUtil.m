//  MTTDatabaseUtil.m
//  Duoduo
//
//  Created by zuoye on 14-3-21.
//  Copyright (c) 2015年 IM All rights reserved.
//

#import "MTTDatabaseUtil.h"
#import "MTTMessageEntity.h"
#import "MTTUserEntity.h"
#import "DDUserModule.h"
#import "MTTGroupEntity.h"
#import "NSString+DDPath.h"
#import "NSDictionary+Safe.h"
#import "MTTDepartment.h"
#import "MTTSessionEntity.h"
#import "MTTUtil.h"
#import "XunxinModel.h"
#import "AddFriendMSGModel.h"

#define DB_FILE_NAME                    @"tt.sqlite"
#define TABLE_MESSAGE                   @"message"
#define TABLE_ALL_CONTACTS              @"allContacts"
#define TABLE_DEPARTMENTS               @"departments"
#define TABLE_GROUPS                    @"groups"
#define TABLE_RECENT_SESSION            @"recentSession"
#define TABLE_BLOG                      @"blog"      // 原来的
#define TABLE_BLOGS_NEW                 @"blogs_new" // 新的
#define TABLE_Add_FRIEND                @"addFriend"

#define SQL_CREATE_MESSAGE              [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@ (messageID integer,sessionId text ,fromUserId text,toUserId text,content text, status integer, msgTime real, sessionType integer,messageContentType integer,messageType integer,info text,reserve1 integer,reserve2 text,primary key (messageID,sessionId))",TABLE_MESSAGE]

#define SQL_CREATE_MESSAGE_INDEX        [NSString stringWithFormat:@"CREATE INDEX msgid on %@(messageID)",TABLE_MESSAGE]

#define SQL_CREATE_DEPARTMENTS      [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@ (ID text UNIQUE,parentID text,title text, description text,leader text, status integer,count integer)",TABLE_DEPARTMENTS]

#define SQL_CREATE_ALL_CONTACTS      [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@ (ID text UNIQUE,Name text,Nick text,Avatar text, Department text,DepartID text, Email text,Postion text,Telphone text,Sex integer,updated real,pyname text,signature text,relation text,fanscount text)",TABLE_ALL_CONTACTS]

// 博客
// (ID text UNIQUE,Name text,Avatar text,blogTime real,blogText text,blogImages text,zfNum text,zanNum text,plNum text)
#define SQL_CREATE_ALL_BLOG       [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@ (ID text UNIQUE,Name text,Avatar text,blogTime real,blogText text,blogImages text,zfNum text,zanNum text,plNum text)",TABLE_BLOG]


// 新blog type
#define SQL_CREATE_ALL_BLOGS_NEW   [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@ (ID text UNIQUE,writeUserID text,Name text,Avatar text,blogId text,blogType text,blogTime real,blogText text,blogImages text,zfNum text,zanNum text,plNum text)",TABLE_BLOGS_NEW]


#define SQL_CREATE_Add_FRIEND       [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@ (ID text UNIQUE,Name text,Avatar text,adsMsg text,userid text,agree text)",TABLE_Add_FRIEND]


#define SQL_CREATE_GROUPS     [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@ (ID text UNIQUE,Avatar text, GroupType integer, Name text,CreatID text,Users Text,LastMessage Text,updated real,isshield integer,version integer)",TABLE_GROUPS]

#define SQL_CREATE_CONTACTS_INDEX     [NSString stringWithFormat:@"CREATE UNIQUE ID on %@(ID)",TABLE_ALL_CONTACTS]

#define SQL_CREATE_RECENT_SESSION     [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@ (ID text UNIQUE,avatar text, type integer, name text,updated real,isshield integer,users Text , unreadCount integer, lasMsg text , lastMsgId integer)",TABLE_RECENT_SESSION]

#define SQL_ADD_CONTACTS_SIGNATURE    [NSString stringWithFormat:@"ALTER TABLE %@ ADD COLUMN signature TEXT",TABLE_ALL_CONTACTS]

@implementation MTTDatabaseUtil
{
    FMDatabase* _database;
    FMDatabaseQueue* _dataBaseQueue;
}

+ (instancetype)instance
{
    static MTTDatabaseUtil* g_databaseUtil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        g_databaseUtil = [[MTTDatabaseUtil alloc] init];
        
    });
    return g_databaseUtil;
}

-(void)reOpenNewDB
{
    [self openCurrentUserDB];
}

- (id)init
{
    self = [super init];
    if (self)
    {
        //初始化数据库
        [self openCurrentUserDB];
    }
    return self;
}

- (void)openCurrentUserDB
{
    if (_database)
    {
        [_database close];
        _database = nil;
    }
    _dataBaseQueue = [FMDatabaseQueue databaseQueueWithPath:[MTTDatabaseUtil dbFilePath]];
    _database = [FMDatabase databaseWithPath:[MTTDatabaseUtil dbFilePath]];
    if (![_database open])
    {
        DDLog(@"打开数据库失败");
    }
    else
    {
        // 更新数据库字段增加signature
        if(![_database columnExists:@"signature" inTableWithName:@"allContacts"]){
            // 不存在,需要allContacts增加signature字段
            [_database executeUpdate:SQL_ADD_CONTACTS_SIGNATURE];
            // 版本号变0,全部重新获取用户信息
            __block NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            [defaults setObject:@(0) forKey:@"alllastupdatetime"];
        }
        
        // 检查是否需要 重新获取数据
        NSInteger dbVersion = [MTTUtil getDBVersion];
        NSInteger lastDbVersion = [MTTUtil getLastDBVersion];
        if(dbVersion > lastDbVersion){
            // 删除联系人数据 重新获取.
            [self clearTable:TABLE_ALL_CONTACTS];
            [self clearTable:TABLE_DEPARTMENTS];
            [self clearTable:TABLE_GROUPS];
            [self clearTable:TABLE_RECENT_SESSION];
            [self clearTable:TABLE_BLOG];
            [self clearTable:TABLE_Add_FRIEND];
            [MTTUtil setLastDBVersion:dbVersion];
        }
        
        //创建
        [_dataBaseQueue inDatabase:^(FMDatabase *db) {
            if (![_database tableExists:TABLE_MESSAGE])
            {
                [self createTable:SQL_CREATE_MESSAGE];
            }
            if (![_database tableExists:TABLE_DEPARTMENTS])
            {
                [self createTable:SQL_CREATE_DEPARTMENTS];
            }
            if (![_database tableExists:TABLE_ALL_CONTACTS]) {
                [self createTable:SQL_CREATE_ALL_CONTACTS];
            }
            if (![_database tableExists:TABLE_GROUPS]) {
                [self createTable:SQL_CREATE_GROUPS];
            }
            if (![_database tableExists:TABLE_RECENT_SESSION]) {
                [self createTable:SQL_CREATE_RECENT_SESSION];
            }
            if (![_database tableExists:TABLE_BLOG]){
                [self createTable:SQL_CREATE_ALL_BLOG];
            }
            if (![_database tableExists:TABLE_BLOGS_NEW]){
                [self createTable:SQL_CREATE_ALL_BLOGS_NEW];
            }
            if (![_database tableExists:TABLE_Add_FRIEND]){
                [self createTable:SQL_CREATE_Add_FRIEND];
            }
        }];
    }
}




+(NSString *)dbFilePath
{
    NSString* directorPath = [NSString userExclusiveDirection];
    
    NSFileManager* fileManager = [NSFileManager defaultManager];
    
    //改用户的db是否存在，若不存在则创建相应的DB目录
    BOOL isDirector = NO;
    BOOL isExiting = [fileManager fileExistsAtPath:directorPath isDirectory:&isDirector];
    
    if (!(isExiting && isDirector))
    {
        BOOL createDirection = [fileManager createDirectoryAtPath:directorPath
                                      withIntermediateDirectories:YES
                                                       attributes:nil
                                                            error:nil];
        if (!createDirection)
        {
            DDLog(@"创建DB目录失败");
        }
    }
    
    
    NSString *dbPath = [directorPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@_%@",TheRuntime.user.objID,DB_FILE_NAME]];
    return dbPath;
}

-(BOOL)createTable:(NSString *)sql          //创建表
{
    BOOL result = NO;
    [_database setShouldCacheStatements:YES];
    NSString *tempSql = [NSString stringWithFormat:@"%@",sql];
    result = [_database executeUpdate:tempSql];
    // [_database executeUpdate:SQL_CREATE_MESSAGE_INDEX];
    //BOOL dd =[_database executeUpdate:SQL_CREATE_CONTACTS_INDEX];
    
    return result;
}

-(BOOL)clearTable:(NSString *)tableName
{
    BOOL result = NO;
    [_database setShouldCacheStatements:YES];
    NSString *tempSql = [NSString stringWithFormat:@"DELETE FROM %@",tableName];
    result = [_database executeUpdate:tempSql];
    //    [_database executeUpdate:SQL_CREATE_MESSAGE_INDEX];
    //    //BOOL dd =[_database executeUpdate:SQL_CREATE_CONTACTS_INDEX];
    //
    return result;
}

#pragma mark - 解析数据库返回的数据
- (NSArray*)messageFromSearchResult:(FMResultSet*)resultSet
{
    
    NSString* sessionID = [resultSet stringForColumn:@"sessionId"];
    NSString* fromUserId = [resultSet stringForColumn:@"fromUserId"];
    NSString* toUserId = [resultSet stringForColumn:@"toUserId"];
    NSString* content = [resultSet stringForColumn:@"content"];
    NSTimeInterval msgTime = [resultSet doubleForColumn:@"msgTime"];
    MsgType messageType = [resultSet intForColumn:@"messageType"];
    NSUInteger messageContentType = [resultSet intForColumn:@"messageContentType"];
    NSUInteger messageID = [resultSet intForColumn:@"messageID"];
    NSUInteger messageState = [resultSet intForColumn:@"status"];
    NSUInteger count = [resultSet intForColumn:@"count(*)"];
    
    //NSLog(@"--- %@--%@--%@--%@",sessionID,fromUserId,toUserId,content);
    
    MTTMessageEntity* messageEntity = [[MTTMessageEntity alloc] initWithMsgID:messageID
                                                                      msgType:messageType
                                                                      msgTime:msgTime
                                                                    sessionID:sessionID
                                                                     senderID:fromUserId
                                                                   msgContent:content
                                                                     toUserID:toUserId];
    messageEntity.state = messageState;
    messageEntity.msgContentType = messageContentType;
    NSString* infoString = [resultSet stringForColumn:@"info"];
    if (infoString)
    {
        NSData* infoData = [infoString dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary* info = [NSJSONSerialization JSONObjectWithData:infoData options:0 error:nil];
        NSMutableDictionary* mutalInfo = [NSMutableDictionary dictionaryWithDictionary:info];
        messageEntity.info = mutalInfo;
        
    }
    return [NSArray arrayWithObjects:@(count),messageEntity, nil];
}

- (MTTMessageEntity*)messageFromResult:(FMResultSet*)resultSet
{
    
    NSString* sessionID = [resultSet stringForColumn:@"sessionId"];
    NSString* fromUserId = [resultSet stringForColumn:@"fromUserId"];
    NSString* toUserId = [resultSet stringForColumn:@"toUserId"];
    NSString* content = [resultSet stringForColumn:@"content"];
    NSTimeInterval msgTime = [resultSet doubleForColumn:@"msgTime"];
    MsgType messageType = [resultSet intForColumn:@"messageType"];
    NSUInteger messageContentType = [resultSet intForColumn:@"messageContentType"];
    NSUInteger messageID = [resultSet intForColumn:@"messageID"];
    NSUInteger messageState = [resultSet intForColumn:@"status"];
    
    //NSLog(@"--- %@--%@--%@--%@",sessionID,fromUserId,toUserId,content);
    
    MTTMessageEntity* messageEntity = [[MTTMessageEntity alloc] initWithMsgID:messageID
                                                                      msgType:messageType
                                                                      msgTime:msgTime
                                                                    sessionID:sessionID
                                                                     senderID:fromUserId
                                                                   msgContent:content
                                                                     toUserID:toUserId];
    messageEntity.state = messageState;
    messageEntity.msgContentType = messageContentType;
    NSString* infoString = [resultSet stringForColumn:@"info"];
    if (infoString)
    {
        NSData* infoData = [infoString dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary* info = [NSJSONSerialization JSONObjectWithData:infoData options:0 error:nil];
        NSMutableDictionary* mutalInfo = [NSMutableDictionary dictionaryWithDictionary:info];
        messageEntity.info = mutalInfo;
        
    }
    return messageEntity;
}

- (MTTUserEntity*)userFromResult:(FMResultSet*)resultSet
{
    NSMutableDictionary *dic = [NSMutableDictionary new];
    // ID text UNIQUE,Name text,Nick text,Avatar text, Department text,DepartID text, Email text,Postion text,Telphone text,Sex integer,updated real,pyname text,signature text
    [dic safeSetObject:[resultSet stringForColumn:@"Name"]       forKey:@"name"];
    [dic safeSetObject:[resultSet stringForColumn:@"Nick"]       forKey:@"nickName"];
    [dic safeSetObject:[resultSet stringForColumn:@"ID"]         forKey:@"userId"];
    [dic safeSetObject:[resultSet stringForColumn:@"Department"] forKey:@"department"];
    [dic safeSetObject:[resultSet stringForColumn:@"Postion"]    forKey:@"position"];
    [dic safeSetObject:[NSNumber numberWithInt:[resultSet intForColumn:@"Sex"]] forKey:@"sex"];
    [dic safeSetObject:[resultSet stringForColumn:@"DepartID"]   forKey:@"departId"];
    [dic safeSetObject:[resultSet stringForColumn:@"Telphone"]   forKey:@"telphone"];
    [dic safeSetObject:[resultSet stringForColumn:@"Avatar"]     forKey:@"avatar"];
    [dic safeSetObject:[resultSet stringForColumn:@"Email"]      forKey:@"email"];
    [dic safeSetObject:@([resultSet longForColumn:@"updated"])   forKey:@"lastUpdateTime"];
    [dic safeSetObject:[resultSet stringForColumn:@"pyname"]     forKey:@"pyname"];
    [dic safeSetObject:[resultSet stringForColumn:@"signature"]  forKey:@"signature"];
      [dic safeSetObject:[resultSet stringForColumn:@"fanscount"]  forKey:@"fanscount"];
    
    MTTUserEntity *user = [MTTUserEntity dicToUserEntity:dic];
    return user;
}

- (AddFriendMSGModel*)addFriendMsgFromResult:(FMResultSet*)resultSet
{
      NSString* ID = [resultSet stringForColumn:@"ID"];
      NSString* Name = [resultSet stringForColumn:@"Name"];
       NSString*Avatar = [resultSet stringForColumn:@"Avatar"];
    NSString*adsMsg = [resultSet stringForColumn:@"adsMsg"];

    NSString*userid = [resultSet stringForColumn:@"userid"];

    NSString*agree = [resultSet stringForColumn:@"agree"];

    AddFriendMSGModel *model=[[AddFriendMSGModel alloc]init];
   
    model.userId=[ID intValue];
    model.friendId=[userid intValue];
    model.nick_name=Name;
    model.avatar_url=Avatar;
    model.addition_msg=adsMsg;
    model.isAgree=[agree intValue];
  
    
    return model;
}


-(MTTGroupEntity *)groupFromResult:(FMResultSet *)resultSet
{
    NSMutableDictionary *dic = [NSMutableDictionary new];
    [dic safeSetObject:[resultSet stringForColumn:@"Name"] forKey:@"name"];
    [dic safeSetObject:[resultSet stringForColumn:@"ID"] forKey:@"groupId"];
    [dic safeSetObject:[resultSet stringForColumn:@"Avatar"] forKey:@"avatar"];
    [dic safeSetObject:[NSNumber numberWithInt:[resultSet intForColumn:@"GroupType"]] forKey:@"groupType"];
    [dic safeSetObject:@([resultSet longForColumn:@"updated"]) forKey:@"lastUpdateTime"];
    [dic safeSetObject:[resultSet stringForColumn:@"CreatID"] forKey:@"creatID"];
    [dic safeSetObject:[resultSet stringForColumn:@"Users"] forKey:@"Users"];
    [dic safeSetObject:[resultSet stringForColumn:@"LastMessage"] forKey:@"lastMessage"];
    [dic safeSetObject:[NSNumber numberWithInt:[resultSet intForColumn:@"isshield"]] forKey:@"isshield"];
    [dic safeSetObject:[NSNumber numberWithInt:[resultSet intForColumn:@"version"]] forKey:@"version"];
    
    MTTGroupEntity* group = [MTTGroupEntity dicToMTTGroupEntity:dic];
    return group;
}

- (MTTDepartment*)departmentFromResult:(FMResultSet*)resultSet
{
    
    NSDictionary *dic = @{@"departID":[resultSet stringForColumn:@"ID"],
                          @"title":[resultSet stringForColumn:@"title"],
                          @"description":[resultSet stringForColumn:@"description"],
                          @"leader":[resultSet stringForColumn:@"leader"],
                          @"parentID":[resultSet stringForColumn:@"parentID"],
                          @"status":[NSNumber numberWithInt:[resultSet intForColumn:@"status"]],
                          @"count":[NSNumber numberWithInt:[resultSet intForColumn:@"count"]],
                          };
    MTTDepartment *deaprtment = [MTTDepartment departmentFromDic:dic];
    return deaprtment;
}

/**
 * 博客
 */
- (XunxinModel *)blogDataFromResult:(FMResultSet*)resultSet
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    // (ID text UNIQUE,BlogId text,BlogType text,Name text,Avatar text,BlogTime real,BlogText text,BlogImages text,zfNum text,LikeCount text,CommentCount text)
    [dict safeSetObject:[resultSet stringForColumn:@"writeUserID"]  forKey:@"writerUserId"];
    [dict safeSetObject:[resultSet stringForColumn:@"Name"]         forKey:@"nickName"];
    [dict safeSetObject:[resultSet stringForColumn:@"Avatar"]       forKey:@"avatarUrl"];
    [dict safeSetObject:[resultSet stringForColumn:@"blogId"]       forKey:@"blogId"];
    [dict safeSetObject:[resultSet stringForColumn:@"blogType"]     forKey:@"blogType"];
    [dict safeSetObject:[resultSet stringForColumn:@"blogTime"]     forKey:@"createTime"];
    [dict safeSetObject:[resultSet stringForColumn:@"blogText"]     forKey:@"blogContent"];
    [dict safeSetObject:[resultSet stringForColumn:@"blogImages"]   forKey:@"blogImages"];
    [dict safeSetObject:[resultSet stringForColumn:@"zfNum"]        forKey:@"concernCnt"];
    [dict safeSetObject:[resultSet stringForColumn:@"zanNum"]       forKey:@"likeCnt"];
    [dict safeSetObject:[resultSet stringForColumn:@"plNum"]        forKey:@"commentCnt"];
    
    XunxinModel *xunxinModel = [XunxinModel xunxinModelFromDic:dict];
    return xunxinModel;
}

#pragma mark Message

- (void)loadMessageForSessionID:(NSString*)sessionID pageCount:(int)pagecount index:(NSInteger)index completion:(LoadMessageInSessionCompletion)completion
{
    [_dataBaseQueue inDatabase:^(FMDatabase *db) {
        NSMutableArray* array = [[NSMutableArray alloc] init];
        if ([_database tableExists:TABLE_MESSAGE])
        {
            [_database setShouldCacheStatements:YES];
            
            NSString* sqlString = [NSString stringWithFormat:@"SELECT * FROM message where sessionId=? ORDER BY msgTime DESC limit ?,?"];
            FMResultSet* result = [_database executeQuery:sqlString,sessionID,[NSNumber numberWithInteger:index],[NSNumber numberWithInteger:pagecount]];
            while ([result next])
            {
                MTTMessageEntity* message = [self messageFromResult:result];
                [array addObject:message];
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                
                completion(array,nil);
            });
        }
    }];
}

- (void)loadMessageForSessionID:(NSString*)sessionID afterMessage:(MTTMessageEntity*)message completion:(LoadMessageInSessionCompletion)completion
{
    [_dataBaseQueue inDatabase:^(FMDatabase *db) {
        NSMutableArray* array = [[NSMutableArray alloc] init];
        if ([_database tableExists:TABLE_MESSAGE])
        {
            [_database setShouldCacheStatements:YES];
            NSString* sqlString = [NSString stringWithFormat:@"select * from %@ where sessionId = '%@' AND messageID >= ? order by msgTime DESC,messageID DESC",TABLE_MESSAGE,sessionID];
            FMResultSet* result = [_database executeQuery:sqlString,@(message.msgID)];
            while ([result next])
            {
                MTTMessageEntity* message = [self messageFromResult:result];
                [array addObject:message];
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(array,nil);
            });
        }
    }];
}

- (void)searchHistory:(NSString *)key completion:(LoadMessageInSessionCompletion)completion
{
    [_dataBaseQueue inDatabase:^(FMDatabase *db) {
        NSMutableArray* array = [[NSMutableArray alloc] init];
        if ([_database tableExists:TABLE_MESSAGE])
        {
            [_database setShouldCacheStatements:YES];
            NSString* sqlString = [NSString stringWithFormat:@"select count(*),* from %@ where content like '%%%@%%' and content not like '%%&$#@~^@[{:%%' GROUP BY sessionId",TABLE_MESSAGE,key];
            FMResultSet* result = [_database executeQuery:sqlString];
            while ([result next])
            {
                NSArray* message = [self messageFromSearchResult:result];
                [array addObject:message];
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(array,nil);
            });
        }
    }];
}

- (void)searchHistoryBySessionId:(NSString *)key sessionId:(NSString *)sessionId completion:(LoadMessageInSessionCompletion)completion
{
    [_dataBaseQueue inDatabase:^(FMDatabase *db) {
        NSMutableArray* array = [[NSMutableArray alloc] init];
        if ([_database tableExists:TABLE_MESSAGE])
        {
            [_database setShouldCacheStatements:YES];
            NSString* sqlString = [NSString stringWithFormat:@"select * from %@ where content like '%%%@%%' and sessionId = '%@' and content not like '%%&$#@~^@[{:%%'",TABLE_MESSAGE,key,sessionId];
            FMResultSet* result = [_database executeQuery:sqlString];
            while ([result next])
            {
                MTTMessageEntity* message = [self messageFromResult:result];
                [array addObject:message];
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(array,nil);
            });
        }
    }];
}

- (void)getLasetCommodityTypeImageForSession:(NSString*)sessionID completion:(DDGetLastestCommodityMessageCompletion)completion
{
    [_dataBaseQueue inDatabase:^(FMDatabase *db) {
        if ([_database tableExists:TABLE_MESSAGE])
        {
            [_database setShouldCacheStatements:YES];
            NSString* sqlString = [NSString stringWithFormat:@"SELECT * from %@ where sessionId=? AND messageType = ? ORDER BY msgTime DESC,rowid DESC limit 0,1",TABLE_MESSAGE];
            FMResultSet* result = [_database executeQuery:sqlString,sessionID,@(4)];
            MTTMessageEntity* message = nil;
            while ([result next])
            {
                message = [self messageFromResult:result];
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(message);
            });
        }
    }];
}

- (void)getLastestMessageForSessionID:(NSString*)sessionID completion:(DDDBGetLastestMessageCompletion)completion
{
    [_dataBaseQueue inDatabase:^(FMDatabase *db) {
        if ([_database tableExists:TABLE_MESSAGE])
        {
            [_database setShouldCacheStatements:YES];
            
            NSString* sqlString = [NSString stringWithFormat:@"SELECT * FROM %@ where sessionId=? and status = 2 ORDER BY messageId DESC limit 0,1",TABLE_MESSAGE];
            
            FMResultSet* result = [_database executeQuery:sqlString,sessionID];
            MTTMessageEntity* message = nil;
            while ([result next])
            {
                message = [self messageFromResult:result];
                dispatch_async(dispatch_get_main_queue(), ^{
                    completion(message,nil);
                });
                
                break;
            }
            if(message == nil){
                completion(message,nil);
            }
        }
    }];
}



- (void)getMessagesCountForSessionID:(NSString*)sessionID completion:(MessageCountCompletion)completion
{
    [_dataBaseQueue inDatabase:^(FMDatabase *db) {
        if ([_database tableExists:TABLE_MESSAGE])
        {
            [_database setShouldCacheStatements:YES];
            
            NSString* sqlString = [NSString stringWithFormat:@"SELECT COUNT(*) FROM %@ where sessionId=?",TABLE_MESSAGE];
            
            FMResultSet* result = [_database executeQuery:sqlString,sessionID];
            int count = 0;
            while ([result next])
            {
                count = [result intForColumnIndex:0];
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(count);
            });
        }
    }];
}

- (void)insertMessages:(NSArray*)messages
               success:(void(^)())success
               failure:(void(^)(NSString* errorDescripe))failure
{
    [_dataBaseQueue inDatabase:^(FMDatabase *db) {
        [_database beginTransaction];
        __block BOOL isRollBack = NO;
        @try {
            [messages enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                MTTMessageEntity* message = (MTTMessageEntity*)obj;

                NSString* sql = [NSString stringWithFormat:@"INSERT OR REPLACE INTO %@ VALUES(?,?,?,?,?,?,?,?,?,?,?,?,?)",TABLE_MESSAGE];
                
                NSData* infoJsonData = [NSJSONSerialization dataWithJSONObject:message.info options:NSJSONWritingPrettyPrinted error:nil];
                NSString* json = [[NSString alloc] initWithData:infoJsonData encoding:NSUTF8StringEncoding];
                
                //NSLog(@"--- %lu--%@--%@--%@--%@--%lu--%f--%d--%d",(unsigned long)message.msgID,message.sessionId,message.senderId,message.toUserID,message.msgContent,(unsigned long)message.state,message.msgTime,(int)message.msgType,(int)message.msgType);
                
                //NSLog(@"--- %d--%@",message.msgID,message.sessionId);
                
                BOOL result = [_database executeUpdate:sql,@(message.msgID),message.sessionId,message.senderId,message.toUserID,message.msgContent,@(message.state),@(message.msgTime),@(1),@(message.msgContentType),@(message.msgType),json,@(0),@""];
                //NSLog(@"result == %d",result);
                
                if (!result)
                {
                    isRollBack = YES;
                    *stop = YES;
                }
            }];
        }
        @catch (NSException *exception) {
            [_database rollback];
            failure(@"插入数据失败");
        }
        @finally {
            if (isRollBack)
            {
                [_database rollback];
                DDLog(@"insert to database failure content");
                failure(@"插入数据失败");
            }
            else
            {
                [_database commit];
                success();
            }
        }
    }];
}

- (void)deleteFriendForSession:(NSString*)userID completion:(DeleteFriendCompletion)completion
{
    [_dataBaseQueue inDatabase:^(FMDatabase *db) {
        if ([_database tableExists:TABLE_ALL_CONTACTS])
        {
            [_database setShouldCacheStatements:YES];
           // NSMutableArray* array = [[NSMutableArray alloc] init];
//            NSString* sqlString = [NSString stringWithFormat:@"SELECT * FROM %@ ",TABLE_ALL_CONTACTS];
//            [NSString stringWithFormat:@"delete from %@ where name = '%@'",TABLE_ALL_CONTACTS,userID];
            
            NSString* sql = @"DELETE FROM allContacts WHERE ID = ?";
            BOOL result = [_database executeUpdate:sql,userID];
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(result);
            });
        }
    }];
}


- (void)deleteMesagesForSession:(NSString*)sessionID completion:(DeleteSessionCompletion)completion
{
    [_dataBaseQueue inDatabase:^(FMDatabase *db) {
        NSString* sql = @"DELETE FROM message WHERE sessionId = ?";
        BOOL result = [_database executeUpdate:sql,sessionID];
        dispatch_async(dispatch_get_main_queue(), ^{
            completion(result);
        });
    }];
}

//本地数据库删除消息
- (void)deleteMesages:(MTTMessageEntity * )message completion:(DeleteSessionCompletion)completion
{
    [_dataBaseQueue inDatabase:^(FMDatabase *db) {
        NSString* sql = @"DELETE FROM message WHERE messageID = ?";
        BOOL result = [_database executeUpdate:sql,@(message.msgID)];
        dispatch_async(dispatch_get_main_queue(), ^{
            completion(result);
        });
    }];
}

- (void)updateMessageForMessage:(MTTMessageEntity*)message completion:(DDUpdateMessageCompletion)completion
{
    //(messageID integer,sessionId text,fromUserId text,toUserId text,content text, status integer, msgTime real, sessionType integer,messageType integer,reserve1 integer,reserve2 text)
    [_dataBaseQueue inDatabase:^(FMDatabase *db) {
        NSString* sql = [NSString stringWithFormat:@"UPDATE %@ set sessionId = ? , fromUserId = ? , toUserId = ? , content = ? , status = ? , msgTime = ? , sessionType = ? , messageType = ? ,messageContentType = ? , info = ? where messageID = ?",TABLE_MESSAGE];
        
        NSData* infoJsonData = [NSJSONSerialization dataWithJSONObject:message.info options:NSJSONWritingPrettyPrinted error:nil];
        NSString* json = [[NSString alloc] initWithData:infoJsonData encoding:NSUTF8StringEncoding];
        
        BOOL result = [_database executeUpdate:sql,message.sessionId,message.senderId,message.toUserID,message.msgContent,@(message.state),@(message.msgTime),@(message.sessionType),@(message.msgType),@(message.msgContentType),json,@(message.msgID)];
        dispatch_async(dispatch_get_main_queue(), ^{
            completion(result);
        });
    }];
}

#pragma mark - Users

- (void)insertDepartments:(NSArray*)departments completion:(InsertsRecentContactsCOmplection)completion
{
    [_dataBaseQueue inDatabase:^(FMDatabase *db) {
        [_database beginTransaction];
        __block BOOL isRollBack = NO;
        @try {
            [departments enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                MTTDepartment* department = [MTTDepartment departmentFromDic:obj];
                NSString* sql = [NSString stringWithFormat:@"INSERT OR REPLACE INTO %@ VALUES(?,?,?,?,?,?,?)",TABLE_DEPARTMENTS];
                //ID,Name,Nick,Avatar,Role,updated,reserve1,reserve2
                BOOL result = [_database executeUpdate:sql,department.ID,department.parentID,department.title,department.description,department.leader,@(department.status),@(department.count)];
                if (!result)
                {
                    isRollBack = YES;
                    *stop = YES;
                }
            }];
        }
        @catch (NSException *exception) {
            [_database rollback];
        }
        @finally {
            if (isRollBack)
            {
                [_database rollback];
                DDLog(@"insert to database failure content");
                NSError* error = [NSError errorWithDomain:@"批量插入部门信息失败" code:0 userInfo:nil];
                completion(error);
            }
            else
            {
                [_database commit];
                completion(nil);
            }
        }
    }];
}

- (void)getDepartmentFromID:(NSString*)departmentID completion:(void(^)(MTTDepartment *department))completion
{
    [_dataBaseQueue inDatabase:^(FMDatabase *db) {
        if ([_database tableExists:TABLE_DEPARTMENTS])
        {
            [_database setShouldCacheStatements:YES];
            
            NSString* sqlString = [NSString stringWithFormat:@"SELECT * FROM %@ where ID=?",TABLE_DEPARTMENTS];
            
            FMResultSet* result = [_database executeQuery:sqlString,departmentID];
            MTTDepartment* department = nil;
            while ([result next])
            {
                department = [self departmentFromResult:result];
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(department);
            });
        }
    }];
}

- (void)insertAllUser:(NSArray*)users completion:(InsertsRecentContactsCOmplection)completion
{
    [_dataBaseQueue inDatabase:^(FMDatabase *db) {
        [_database beginTransaction];
        __block BOOL isRollBack = NO;
        @try {
            
            [users enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                MTTUserEntity* user = (MTTUserEntity *)obj;
                if (user.userStatus == 3) {
                    user.telphone = @"";
                    user.email = @"";
                    user.name = @"";
                }
                
                NSLog(@"12345678%@",NSHomeDirectory());
                NSString* sql = [NSString stringWithFormat:@"INSERT OR REPLACE INTO %@ VALUES(?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)",TABLE_ALL_CONTACTS];
                //ID,Name,Nick,Avatar,Role,updated,reserve1,reserve2
                NSString *fanscount=[NSString stringWithFormat:@"%ld",user.fansCount];
                
                BOOL result = [_database executeUpdate:sql,user.objID,user.name,user.nick,user.avatar,user.department,user.departId,user.email,user.position,user.telphone,@(user.sex),user.lastUpdateTime,user.pyname,user.signature,user.relation,fanscount];
                
                if (!result)
                {
                    isRollBack = YES;
                    *stop = YES;
                }
            }];
        }
        @catch (NSException *exception) {
            [_database rollback];
        }
        @finally {
            if (isRollBack)
            {
                [_database rollback];
                DDLog(@"insert to database failure content");
                NSError* error = [NSError errorWithDomain:@"批量插入全部用户信息失败" code:0 userInfo:nil];
                completion(error);
            }
            else
            {
                [_database commit];
                completion(nil);
            }
        }
    }];
}

- (void)getAllUsers:(LoadAllContactsComplection)completion
{
    [_dataBaseQueue inDatabase:^(FMDatabase *db) {
        if ([_database tableExists:TABLE_ALL_CONTACTS]) {
            [_database setShouldCacheStatements:YES];
            
            NSMutableArray *array = [[NSMutableArray alloc] init];
            NSString *sqlString = [NSString stringWithFormat:@"SELECT * FROM %@ ",TABLE_ALL_CONTACTS];
            FMResultSet *result = [_database executeQuery:sqlString];
            MTTUserEntity *user = nil;
            
            while ([result next]) {
                user = [self userFromResult:result];
//                NSLog(@"--%@", user.userID);
                if (user.userStatus != 3) {
                    [array addObject:user];
                }
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(array,nil);
            });
        }
    }];
}

- (void)getUserFromID:(NSString*)userID completion:(void(^)(MTTUserEntity *user))completion
{
    [_dataBaseQueue inDatabase:^(FMDatabase *db) {
        if ([_database tableExists:TABLE_ALL_CONTACTS])
        {
            [_database setShouldCacheStatements:YES];
            
            NSString* sqlString = [NSString stringWithFormat:@"SELECT * FROM %@ where ID= ?",TABLE_ALL_CONTACTS];
            FMResultSet* result = [_database executeQuery:sqlString,userID];
            MTTUserEntity* user = nil;
            while ([result next])
            {
                user = [self userFromResult:result];
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(user);
            });
        }
    }];
}

- (void)loadGroupByIDCompletion:(NSString *)groupID Block:(LoadRecentContactsComplection)completion
{
    [_dataBaseQueue inDatabase:^(FMDatabase *db) {
        NSMutableArray* array = [[NSMutableArray alloc] init];
        if ([_database tableExists:TABLE_GROUPS])
        {
            [_database setShouldCacheStatements:YES];
            
            NSString* sqlString = [NSString stringWithFormat:@"SELECT * FROM %@ where ID= ? ",TABLE_GROUPS];
            FMResultSet* result = [_database executeQuery:sqlString,groupID];
            while ([result next])
            {
                MTTGroupEntity* group = [self groupFromResult:result];
                [array addObject:group];
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(array,nil);
            });
        }
    }];
}

- (void)loadGroupsCompletion:(LoadRecentContactsComplection)completion
{
    [_dataBaseQueue inDatabase:^(FMDatabase *db) {
        NSMutableArray* array = [[NSMutableArray alloc] init];
        if ([_database tableExists:TABLE_GROUPS])
        {
            [_database setShouldCacheStatements:YES];
            
            NSString* sqlString = [NSString stringWithFormat:@"SELECT * FROM %@",TABLE_GROUPS];
            FMResultSet* result = [_database executeQuery:sqlString];
            while ([result next])
            {
                MTTGroupEntity* group = [self groupFromResult:result];
                [array addObject:group];
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(array,nil);
            });
        }
    }];
}

- (void)updateRecentGroup:(MTTGroupEntity *)group completion:(InsertsRecentContactsCOmplection)completion
{
    [_dataBaseQueue inDatabase:^(FMDatabase *db) {
        [_database beginTransaction];
        __block BOOL isRollBack = NO;
        @try {
            NSString* sql = [NSString stringWithFormat:@"INSERT OR REPLACE INTO %@ VALUES(?,?,?,?,?,?,?,?,?,?)",TABLE_GROUPS];
            NSString *users = @"";
            if ([group.groupUserIds count]>0) {
                users=[group.groupUserIds componentsJoinedByString:@"-"];
            }
            BOOL result = [_database executeUpdate:sql,group.objID,group.avatar,@(group.groupType),group.name,group.groupCreatorId,users,group.lastMsg,@(group.lastUpdateTime),@(group.isShield),@(group.objectVersion)];
            if (!result)
            {
                isRollBack = YES;
            }
            
        }
        @catch (NSException *exception) {
            [_database rollback];
        }
        @finally {
            if (isRollBack)
            {
                [_database rollback];
                DDLog(@"insert to database failure content");
                NSError* error = [NSError errorWithDomain:@"插入最近群失败" code:0 userInfo:nil];
                completion(error);
            }
            else
            {
                [_database commit];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    completion(nil);
                });
            }
        }
    }];
}

- (void)updateRecentSessions:(NSArray *)sessions completion:(InsertsRecentContactsCOmplection)completion{
    
    [_dataBaseQueue inDatabase:^(FMDatabase *db) {
        
        [_database beginTransaction];
        __block BOOL isRollBack = NO;
        @try {
            
            [sessions enumerateObjectsUsingBlock:^(MTTSessionEntity *session, NSUInteger idx, BOOL *stop) {
                
                NSString* sql = [NSString stringWithFormat:@"INSERT OR REPLACE INTO %@ VALUES(?,?,?,?,?,?,?,?,?,?)",TABLE_RECENT_SESSION];
                //ID Avatar GroupType Name CreatID Users  LastMessage
                NSString *users = @"";
                if ([session.sessionUsers count]>0) {
                    users=[session.sessionUsers componentsJoinedByString:@"-"];
                }
                BOOL result = [_database executeUpdate:sql,session.sessionID,session.avatar,@(session.sessionType),session.name,@(session.timeInterval),@(session.isShield),users,@(session.unReadMsgCount),session.lastMsg,@(session.lastMsgID)];
                
                if (!result)
                {
                    isRollBack = YES;
                    *stop = YES;
                }
            }];
        }
        @catch (NSException *exception) {
            [_database rollback];
        }
        @finally {
            if (isRollBack)
            {
                [_database rollback];
                DDLog(@"insert to database failure content");
                NSError* error = [NSError errorWithDomain:@"插入最近Session失败" code:0 userInfo:nil];
//                completion(error);
                dispatch_async(dispatch_get_main_queue(), ^{
                    completion(error);
                });
            }
            else
            {
                [_database commit];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    completion(nil);
                });
            }
        }
    }];
}

- (void)updateRecentSession:(MTTSessionEntity *)session completion:(InsertsRecentContactsCOmplection)completion{
    /*
     ID text UNIQUE,Avatar text, Type integer, Name text,LastMessage Text,updated real,isshield intege  Users Text
     */
    [_dataBaseQueue inDatabase:^(FMDatabase *db) {
        [_database beginTransaction];
        __block BOOL isRollBack = NO;
        @try {
            NSString* sql = [NSString stringWithFormat:@"INSERT OR REPLACE INTO %@ VALUES(?,?,?,?,?,?,?,?,?,?)",TABLE_RECENT_SESSION];
            //ID Avatar GroupType Name CreatID Users  LastMessage
            NSString *users = @"";
            if ([session.sessionUsers count]>0) {
                users=[session.sessionUsers componentsJoinedByString:@"-"];
            }
            BOOL result = [_database executeUpdate:sql,session.sessionID,session.avatar,@(session.sessionType),session.name,@(session.timeInterval),@(session.isShield),users,@(session.unReadMsgCount),session.lastMsg,@(session.lastMsgID)];
            if (!result)
            {
                isRollBack = YES;
            }
            
        }
        @catch (NSException *exception) {
            [_database rollback];
        }
        @finally {
            if (isRollBack)
            {
                [_database rollback];
                DDLog(@"insert to database failure content");
                NSError* error = [NSError errorWithDomain:@"插入最近Session失败" code:0 userInfo:nil];
                completion(error);
            }
            else
            {
                [_database commit];
                completion(nil);
            }
        }
    }];
}

#pragma session

- (void)loadSessionsCompletion:(LoadAllSessionsComplection)completion
{
    [_dataBaseQueue inDatabase:^(FMDatabase *db) {
        NSMutableArray* array = [[NSMutableArray alloc] init];
        if ([_database tableExists:TABLE_RECENT_SESSION])
        {
            [_database setShouldCacheStatements:YES];
            
            NSString* sqlString = [NSString stringWithFormat:@"SELECT * FROM %@ order BY updated DESC",TABLE_RECENT_SESSION];
            FMResultSet* result = [_database executeQuery:sqlString];
            while ([result next])
            {
                MTTSessionEntity* session = [self sessionFromResult:result];
                [array addObject:session];
            }
            //            dispatch_async(dispatch_get_main_queue(), ^{
            completion(array,nil);
            //            });
        }
    }];
}

-(MTTSessionEntity *)sessionFromResult:(FMResultSet *)resultSet
{
    /*
     ID text UNIQUE,Avatar text, Type integer, Name text,updated real,isshield integer,Users Text
     */
    SessionType type =(SessionType)[resultSet intForColumn:@"type"];
    MTTSessionEntity* session = [[MTTSessionEntity alloc] initWithSessionID:[resultSet stringForColumn:@"ID"]SessionName:[resultSet stringForColumn:@"name"] type:type];
    session.avatar       = [resultSet stringForColumn:@"avatar"];
    session.timeInterval = [resultSet longForColumn:@"updated"];
    session.lastMsg      = [resultSet stringForColumn:@"lasMsg"];
    session.lastMsgID    = [resultSet longForColumn:@"lastMsgId"];
    session.unReadMsgCount = [resultSet longForColumn:@"unreadCount"];
    
    return session;
}

-(void)removeSession:(NSString *)sessionID
{
    [_dataBaseQueue inDatabase:^(FMDatabase *db) {
        NSString *sql = @"DELETE FROM recentSession WHERE ID = ?";
        BOOL result = [_database executeUpdate:sql,sessionID];
        if(result) {
            NSString* sql = @"DELETE FROM message WHERE sessionId = ?";
            [_database executeUpdate:sql,sessionID];
        }
    }];
}

#pragma mark - Blogs

// 根据blogs类型获取
- (void)getAllBlogsWithBlogType:(NSString *)blogType complection:(LoadAllBlogsComplection)complection
{
    [_dataBaseQueue inDatabase:^(FMDatabase *db) {
        
        NSMutableArray *array = [NSMutableArray array];
        if ([_database tableExists:TABLE_BLOGS_NEW])
        {
            [_database setShouldCacheStatements:YES];
            // SQL语句
            NSString *sqlString = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE blogType = ?",TABLE_BLOGS_NEW];
            // 查询
            FMResultSet *result = [_database executeQuery:sqlString, blogType];
            // 结果
            while ([result next]) {
                XunxinModel *xunxinModel = [self blogDataFromResult:result];
                [array addObject:xunxinModel];
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                complection(array, nil);
            });
        }
    }];
}

// 获取所有的blog
-(void)getAllBlogs:(LoadAllBlogsComplection)complection
{
    [_dataBaseQueue inDatabase:^(FMDatabase *db) {
        
        NSMutableArray *array = [NSMutableArray array];
        if ([_database tableExists:TABLE_BLOGS_NEW])
        {
            [_database setShouldCacheStatements:YES];
            // SQL语句
            NSString *sqlString = [NSString stringWithFormat:@"SELECT * FROM %@",TABLE_BLOGS_NEW];
            // 查询
            FMResultSet *result = [_database executeQuery:sqlString];
            // 结果
            while ([result next]) {
                XunxinModel *xunxinModel = [self blogDataFromResult:result];
                [array addObject:xunxinModel];
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                complection(array, nil);
            });
        }
    }];
}

// 更新Blogs
-(void)updateBlogsWithBlogType:(NSString *)blogType andUserID:(NSString *)userID completion:(UpdataBlogsComplection)complection
{
    [_dataBaseQueue inDatabase:^(FMDatabase *db) {
        if ([_database tableExists:TABLE_BLOGS_NEW])
        {
            [_database setShouldCacheStatements:YES];
            // SQL语句
            NSString *sqlString = [NSString stringWithFormat:@"UPDATE %@ SET blogType = ? WHERE writeUserID = ?",TABLE_BLOGS_NEW];
            // 查询
            NSError *error;
            BOOL result = [_database executeUpdate:sqlString, blogType, userID];
            if (result) {
                error = nil;
            }else {
                error = [NSError errorWithDomain:@"更新blogs失败" code:0 userInfo:nil];
            }
            complection(error);
        }
    }];
}

/** 
 * 根据blogsType插入数据
 */
-(void)insertBlogs:(NSArray *)blogs withBlogType:(NSString *)blogType completion:(InsertBLogsComplection)complection
{
    [_dataBaseQueue inDatabase:^(FMDatabase *db) {
        [_database beginTransaction];
        __block BOOL isRollBack = NO;
        @try {
            [blogs enumerateObjectsUsingBlock:^(XunxinModel *xunxinModel, NSUInteger idx, BOOL * _Nonnull stop) {
                // 拼接图片路径
                NSMutableString *blogImgURL = [[NSMutableString alloc] init];
                
                // 拼接图片路径存储FMDB
                if (xunxinModel.imgArray.count) {
                    for (NSInteger i = 0; i < xunxinModel.imgArray.count; i++) {
                        NSString *urlString = xunxinModel.imgArray[i];
                        if (urlString.length) {
                            [blogImgURL appendString:urlString];
                            [blogImgURL appendString:@"+"];
                        }
                    }
                }
                
                // 插入数据
                NSString* sql = [NSString stringWithFormat:@"INSERT OR REPLACE INTO %@ VALUES(?,?,?,?,?,?,?,?,?,?,?,?)",TABLE_BLOGS_NEW];
                //ID text UNIQUE,writeUserID text,Name text,Avatar text,blogId text,blogType text,blogTime real,blogText text,blogImages text,zfNum text,zanNum text,plNum text
                // zanNum text 存用户类型（1-推荐，2-好友，3-关注）
                BOOL result = [_database executeUpdate:sql, xunxinModel.blogId ,xunxinModel.writerUserId, xunxinModel.nickName, xunxinModel.avatarUrl, xunxinModel.blogId, blogType, xunxinModel.createTime, xunxinModel.content, blogImgURL, xunxinModel.likeCnt, blogType, xunxinModel.commentCnt];
                
                if (!result) {
                    isRollBack = YES;
                    *stop = YES;
                }
            }];
            
        }@catch (NSException *exception) {
            [_database rollback];
            
        }@finally {
            if (isRollBack) {
                [_database rollback];
                DDLog(@"insert to database failure content");
                NSError *error = [NSError errorWithDomain:@"插入blogs失败" code:0 userInfo:nil];
                complection(error);
                
            }else{
                // 提交事务
                [_database commit];
                dispatch_async(dispatch_get_main_queue(), ^{
                    complection(nil);
                });
            }
        }
    }];
}

// 插入blogs
-(void)insertBlogs:(NSArray *)blogs completion:(InsertBLogsComplection)complection
{
    [_dataBaseQueue inDatabase:^(FMDatabase *db) {
        [_database beginTransaction];
        __block BOOL isRollBack = NO;
        @try {
            [blogs enumerateObjectsUsingBlock:^(XunxinModel *xunxinModel, NSUInteger idx, BOOL * _Nonnull stop) {
                // 拼接图片路径
                NSMutableString *blogImgURL = [[NSMutableString alloc] init];
                
                // 拼接图片路径存储FMDB
                if (xunxinModel.imgArray.count) {
                    for (NSInteger i = 0; i < xunxinModel.imgArray.count; i++) {
                        NSString *urlString = xunxinModel.imgArray[i];
                        if (urlString.length) {
                            [blogImgURL appendString:urlString];
                            [blogImgURL appendString:@"+"];
                        }
                    }
                }
                
                // 插入数据
                NSString* sql = [NSString stringWithFormat:@"INSERT OR REPLACE INTO %@ VALUES(?,?,?,?,?,?,?,?,?,?,?,?)",TABLE_BLOGS_NEW];
                //ID text UNIQUE,Name text,Avatar text,blogId text,blogType text,blogTime real,blogText text,blogImages text,zfNum text,zanNum text,plNum text
                BOOL result = [_database executeUpdate:sql, xunxinModel.blogId ,xunxinModel.writerUserId, xunxinModel.nickName, xunxinModel.avatarUrl, xunxinModel.blogId, xunxinModel.blogType, xunxinModel.createTime, xunxinModel.content, blogImgURL, xunxinModel.likeCnt, xunxinModel.likeCnt, xunxinModel.commentCnt];
                
                if (!result) {
                    isRollBack = YES;
                    *stop = YES;
                }
            }];
            
        }@catch (NSException *exception) {
            [_database rollback];
            
        }@finally {
            if (isRollBack) {
                [_database rollback];
                DDLog(@"insert to database failure content");
                NSError* error = [NSError errorWithDomain:@"插入blogs失败" code:0 userInfo:nil];
                complection(error);
                
            }else{
                // 提交事务
                [_database commit];
                dispatch_async(dispatch_get_main_queue(), ^{
                    complection(nil);
                });
            }
        }
    }];
}

#pragma mark - 添加好友

//好友添加的信息 插入数据库
- (void)insertAlladdFriendMsg:(NSArray*)users completion:(InsertsRecentContactsCOmplection)completion
{
    [_dataBaseQueue inDatabase:^(FMDatabase *db) {
        [_database beginTransaction];
        __block BOOL isRollBack = NO;
        @try {

            
            [users enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                AddFriendMSGModel* user = obj;
                
                
                NSString* sql = [NSString stringWithFormat:@"INSERT OR REPLACE INTO %@ VALUES(?,?,?,?,?,?)",TABLE_Add_FRIEND];
                //ID,Name,Nick,Avatar,Role,updated,reserve1,reserve2
                NSString *str=[NSString stringWithFormat:@"%d",user.userId];
                NSString *str2=[NSString stringWithFormat:@"%d",user.friendId];
                NSString *str3=[NSString stringWithFormat:@"%d",user.isAgree];
                
                BOOL result = [_database executeUpdate:sql,str,user.nick_name,user.avatar_url,user.addition_msg,str2,str3];
                
                if (!result)
                {
                    isRollBack = YES;
                    *stop = YES;
                }
                
                
            }];
            
        }
        @catch (NSException *exception) {
            [_database rollback];
        }
        @finally {
            if (isRollBack)
            {
                [_database rollback];
                DDLog(@"insert to database failure content");
                NSError* error = [NSError errorWithDomain:@"批量插入全部好友添加信息失败" code:0 userInfo:nil];
                completion(error);
            }
            else
            {
                [_database commit];
                completion(nil);
            }
        }
    }];
}
- (void)getAddFriendMsg:(LoadAllContactsComplection )completion
{
    [_dataBaseQueue inDatabase:^(FMDatabase *db) {
        if ([_database tableExists:TABLE_Add_FRIEND])
        {
            [_database setShouldCacheStatements:YES];
            NSMutableArray* array = [[NSMutableArray alloc] init];
            NSString* sqlString = [NSString stringWithFormat:@"SELECT * FROM %@ ",TABLE_Add_FRIEND];
            FMResultSet* result = [_database executeQuery:sqlString];
            AddFriendMSGModel* user = nil;
            while ([result next])
            {
                user = [self addFriendMsgFromResult:result];
               
                    [array addObject:user];
                
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(array,nil);
            });
        }
    }];
}

@end
