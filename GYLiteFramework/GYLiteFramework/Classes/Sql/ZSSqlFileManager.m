#import "ZSSqlFileManager.h"
#import <sqlite3.h>

@interface ZSSqlFileManager ()
@property (nonatomic, assign) sqlite3 *zs_database;
@end

@implementation ZSSqlFileManager

+ (instancetype)shared {
    static ZSSqlFileManager *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (instancetype)init {
    self = [super init];
    return self;
}

- (void)dealloc {
    if (_zs_database) {
        sqlite3_close(_zs_database);
    }
}

- (void)zs_saveFolderToSandbox:(NSString *)folderPath dbName:(NSString *)dbName progressCallback:(ZSProgressCallback)progressCallback completion:(ZSCompletionCallback)completion {
    if (_zs_database) {
        sqlite3_close(_zs_database);
        _zs_database = NULL;
    }
    
    NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    NSString *dbPath = [documentsPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.db", dbName]];
    
    NSLog(@"%@", documentsPath);
    
    if (sqlite3_open([dbPath UTF8String], &_zs_database) == SQLITE_OK) {
        const char *createTableSQL = "CREATE TABLE IF NOT EXISTS files (path TEXT PRIMARY KEY, data BLOB)";
        char *errMsg = NULL;
        if (sqlite3_exec(_zs_database, createTableSQL, NULL, NULL, &errMsg) != SQLITE_OK) {
            NSLog(@"Failed to create table: %s", errMsg);
            sqlite3_free(errMsg);
            if (completion) {
                NSError *error = [NSError errorWithDomain:@"ZSSqlFileManager" code:1001 userInfo:@{NSLocalizedDescriptionKey: @"Failed to create table"}];
                completion(NO, error);
            }
            return;
        }
        
        NSString *folderName = [folderPath lastPathComponent];
        [self zs_traverseAndSaveFolder:folderPath folderName:folderName progressCallback:progressCallback completion:completion];
    } else {
        NSLog(@"Failed to open database: %s", sqlite3_errmsg(_zs_database));
        if (completion) {
            NSError *error = [NSError errorWithDomain:@"ZSSqlFileManager" code:1000 userInfo:@{NSLocalizedDescriptionKey: @"Failed to open database"}];
            completion(NO, error);
        }
    }
}

- (void)zs_traverseAndSaveFolder:(NSString *)sourcePath folderName:(NSString *)folderName progressCallback:(ZSProgressCallback)progressCallback completion:(ZSCompletionCallback)completion {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSDirectoryEnumerator *enumerator = [fileManager enumeratorAtPath:sourcePath];
    
    if (sourcePath == nil) {
        if (completion) {
            completion(NO, nil);
            return;
        }
    }
    
    NSArray *allFiles = [[NSFileManager defaultManager] subpathsOfDirectoryAtPath:sourcePath error:nil];
    NSUInteger totalFiles = [allFiles count];
    NSUInteger processedFiles = 0;
    
    for (NSString *filePath in allFiles) {
        NSString *fullPath = [sourcePath stringByAppendingPathComponent:filePath];
        NSString *relativePath = [folderName stringByAppendingPathComponent:filePath];
        
        BOOL success = [self zs_saveFileToSQLite:fullPath withRelativePath:relativePath];
        processedFiles++;
        
        if (progressCallback) {
            progressCallback((CGFloat)processedFiles / totalFiles);
        }
        
        if (!success) {
            if (completion) {
                NSError *error = [NSError errorWithDomain:@"ZSSqlFileManager" code:1002 userInfo:@{NSLocalizedDescriptionKey: @"Failed to save file"}];
                completion(NO, error);
            }
            return;
        }
    }
    
    if (completion) {
        if (allFiles.count == 0) {
            completion(NO, nil);
        }else{
            completion(YES, nil);
        }
    }
}

- (BOOL)zs_saveFileToSQLite:(NSString *)filePath withRelativePath:(NSString *)relativePath {
    NSData *fileData = [NSData dataWithContentsOfFile:filePath];
    const char *sql = "INSERT OR REPLACE INTO files (path, data) VALUES (?, ?)";
    sqlite3_stmt *statement;
    
    if (sqlite3_prepare_v2(_zs_database, sql, -1, &statement, NULL) == SQLITE_OK) {
        sqlite3_bind_text(statement, 1, [relativePath UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_blob(statement, 2, [fileData bytes], (int)[fileData length], SQLITE_TRANSIENT);
        
        if (sqlite3_step(statement) != SQLITE_DONE) {
            NSLog(@"Failed to insert file: %s", sqlite3_errmsg(_zs_database));
            sqlite3_finalize(statement);
            return NO;
        }
        sqlite3_finalize(statement);
        return YES;
    }
    return NO;
}

- (void)zs_restoreFolderFromSandbox:(NSString *)folderName dbName:(NSString *)dbName isSandbox:(BOOL)isSandbox progressCallback:(ZSProgressCallback)progressCallback completion:(ZSCompletionCallback)completion {
    if (_zs_database) {
        sqlite3_close(_zs_database);
        _zs_database = NULL;
    }
    
    NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];

    NSLog(@"%@", documentsPath);

    
    NSString *dbPath = [[NSBundle mainBundle] pathForResource:dbName ofType:@"db"];
    
    if (isSandbox) {
        dbPath = [documentsPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.db", dbName]];
        
    }
    
    if (sqlite3_open([dbPath UTF8String], &_zs_database) != SQLITE_OK) {
        NSLog(@"Failed to open database: %s", sqlite3_errmsg(_zs_database));
        if (completion) {
            NSError *error = [NSError errorWithDomain:@"ZSSqlFileManager" code:1000 userInfo:@{NSLocalizedDescriptionKey: @"Failed to open database"}];
            completion(NO, error);
        }
        return;
    }
    
    // 首先获取总文件数
    const char *countSql = "SELECT COUNT(*) FROM files WHERE path LIKE ? AND path != ?";
    sqlite3_stmt *countStatement;
    NSString *pattern = [NSString stringWithFormat:@"%@%%", folderName];
    NSUInteger totalFiles = 0;
    
    if (sqlite3_prepare_v2(_zs_database, countSql, -1, &countStatement, NULL) == SQLITE_OK) {
        sqlite3_bind_text(countStatement, 1, [pattern UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_text(countStatement, 2, [folderName UTF8String], -1, SQLITE_TRANSIENT);
        
        if (sqlite3_step(countStatement) == SQLITE_ROW) {
            totalFiles = sqlite3_column_int(countStatement, 0);
        }
        sqlite3_finalize(countStatement);
    }
    
    if (totalFiles == 0) {
        if (completion) {
            completion(YES, nil);
        }
        return;
    }
    
    const char *sql = "SELECT path, data FROM files WHERE path LIKE ? AND path != ?";
    sqlite3_stmt *statement;
    NSUInteger processedFiles = 0;
    BOOL hasError = NO;
    
    if (sqlite3_prepare_v2(_zs_database, sql, -1, &statement, NULL) == SQLITE_OK) {
        sqlite3_bind_text(statement, 1, [pattern UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_text(statement, 2, [folderName UTF8String], -1, SQLITE_TRANSIENT);
        
        while (sqlite3_step(statement) == SQLITE_ROW) {
            const unsigned char *pathBytes = sqlite3_column_text(statement, 0);
            if (!pathBytes) {
                processedFiles++;
                if (progressCallback) {
                    progressCallback((CGFloat)processedFiles / totalFiles);
                }
                continue;
            }
            
            NSString *relativePath = [NSString stringWithUTF8String:(const char *)pathBytes];
            if (!relativePath) {
                processedFiles++;
                if (progressCallback) {
                    progressCallback((CGFloat)processedFiles / totalFiles);
                }
                continue;
            }
            
            const void *blobData = sqlite3_column_blob(statement, 1);
            int blobSize = sqlite3_column_bytes(statement, 1);
            if (!blobData || blobSize <= 0) {
                processedFiles++;
                if (progressCallback) {
                    progressCallback((CGFloat)processedFiles / totalFiles);
                }
                continue;
            }
            
            NSData *fileData = [NSData dataWithBytes:blobData length:blobSize];
            
            NSString *destinationPath = [documentsPath stringByAppendingPathComponent:relativePath];
            NSString *destinationFolder = [destinationPath stringByDeletingLastPathComponent];
            
            NSError *error = nil;
            NSFileManager *fileManager = [NSFileManager defaultManager];
            
            if (![fileManager fileExistsAtPath:destinationFolder]) {
                BOOL created = [fileManager createDirectoryAtPath:destinationFolder
                                      withIntermediateDirectories:YES
                                                       attributes:nil
                                                            error:&error];
                if (!created) {
                    NSLog(@"Failed to create directory at %@: %@", destinationFolder, error);
                    hasError = YES;
                    break;
                }
            }
            
            BOOL written = [fileData writeToFile:destinationPath atomically:YES];
            if (!written) {
                NSLog(@"Failed to write file at %@", destinationPath);
                hasError = YES;
                break;
            }
            
            processedFiles++;
            if (progressCallback) {
                progressCallback((CGFloat)processedFiles / totalFiles);
            }
        }
        sqlite3_finalize(statement);
        
        if (completion) {
            if (hasError) {
                NSError *error = [NSError errorWithDomain:@"ZSSqlFileManager" code:1004 userInfo:@{NSLocalizedDescriptionKey: @"Failed to restore files"}];
                completion(NO, error);
            } else {
                completion(YES, nil);
            }
        }
    } else {
        if (completion) {
            NSError *error = [NSError errorWithDomain:@"ZSSqlFileManager" code:1003 userInfo:@{NSLocalizedDescriptionKey: @"Failed to prepare statement"}];
            completion(NO, error);
        }
    }
    
    if (_zs_database) {
        sqlite3_close(_zs_database);
        _zs_database = NULL;
    }
}




@end
