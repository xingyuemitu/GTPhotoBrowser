//
//  NSBundle+GTPhotoBrowser.m
//  GPUImage
//
//  Created by liuxc on 2018/6/30.
//

#import "NSBundle+GTPhotoBrowser.h"
#import "GTPhotoActionSheet.h"
#import "GTPhotoDefine.h"

@implementation NSBundle (GTPhotoBrowser)

+ (instancetype)gtPhotoBrowserBundle
{
    static NSBundle *photoBrowserBundle = nil;
    if (photoBrowserBundle == nil) {
        photoBrowserBundle = [NSBundle bundleWithPath:[[NSBundle bundleForClass:[GTPhotoActionSheet class]] pathForResource:@"GTPhotoBrowser" ofType:@"bundle"]];
    }
    return photoBrowserBundle;
}

static NSBundle *bundle = nil;
+ (void)resetLanguage
{
    bundle = nil;
}

+ (NSString *)gtLocalizedStringForKey:(NSString *)key
{
    return [self gtLocalizedStringForKey:key value:nil];
}

+ (NSString *)gtLocalizedStringForKey:(NSString *)key value:(NSString *)value
{
    if (bundle == nil) {
        // 从bundle中查找资源
        bundle = [NSBundle bundleWithPath:[[NSBundle gtPhotoBrowserBundle] pathForResource:[self getLanguage] ofType:@"lproj"]];
    }
    value = [bundle localizedStringForKey:key value:value table:nil];
    return [[NSBundle mainBundle] localizedStringForKey:key value:value table:nil];
}

+ (NSString *)getLanguage
{
    GTLanguageType type = [[[NSUserDefaults standardUserDefaults] valueForKey:GTLanguageTypeKey] integerValue];
    
    NSString *language = nil;
    switch (type) {
        case GTLanguageSystem: {
            language = [NSLocale preferredLanguages].firstObject;
            if ([language hasPrefix:@"en"]) {
                language = @"en";
            } else if ([language hasPrefix:@"zh"]) {
                if ([language rangeOfString:@"Hans"].location != NSNotFound) {
                    language = @"zh-Hans"; // 简体中文
                } else { // zh-Hant\zh-HK\zh-TW
                    language = @"zh-Hant"; // 繁體中文
                }
            } else if ([language hasPrefix:@"ja"]) {
                language = @"ja-US";
            } else {
                language = @"en";
            }
        }
            break;
        case GTLanguageChineseSimplified:
            language = @"zh-Hans";
            break;
        case GTLanguageChineseTraditional:
            language = @"zh-Hant";
            break;
        case GTLanguageEnglish:
            language = @"en";
            break;
        case GTLanguageJapanese:
            language = @"ja-US";
            break;
    }
    return language;
}


@end
