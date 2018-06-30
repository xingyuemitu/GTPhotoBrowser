//
//  NSBundle+GTPhotoBrowser.h
//  GPUImage
//
//  Created by liuxc on 2018/6/30.
//

#import <Foundation/Foundation.h>

@interface NSBundle (GTPhotoBrowser)

+ (instancetype)gtPhotoBrowserBundle;

+ (void)resetLanguage;

+ (NSString *)gtLocalizedStringForKey:(NSString *)key;

+ (NSString *)gtLocalizedStringForKey:(NSString *)key value:(NSString *)value;

@end
