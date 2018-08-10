![blogimg](https://github.com/pkh0225/JTC-JSON-TO-CLASS/blob/master/jtc.png)

# 🚀 JTC
## JSON TO CLASS
> JSON to Class Helper written in Objective-C for iOS developers.

<br><br>
## 목표
> 클라이언트 개발 시 json 파싱 과정에서 생기는 실수를 방지하고 불필요한 반복 작업을 줄여 파싱 과정을 효율화 하기 위해 기획된 앱

<br><br>
## Sample Code
```
#import <Foundation/Foundation.h>
#import "PropertyModelData.h"

@interface ClassModelData : NSObject

@property (nonatomic, strong) NSString* name;
@property (nonatomic, strong) NSString* parentName;
@property (nonatomic, strong) NSString* perfix;
@property (nonatomic, strong) NSMutableArray<PropertyModelData*> *propertyList;



+ (ClassModelData*)allocWithDictionary:(NSDictionary*)dic className:(NSString*)className parentName:(NSString*)parentName perfix:(NSString*)perfix;
- (id)initWithDictionary:(NSDictionary *)dic className:(NSString*)className parentName:(NSString*)parentName perfix:(NSString*)perfix;
- (void)setSerialize:(NSDictionary *)dic;

- (NSString *)getStringObjectCHeader;
- (NSString *)getStringObjectCImplementation;

- (NSString*)getStringSwift;
@end
```
