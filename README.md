![blogimg](https://github.com/pkh0225/JSON-to-CLASS/blob/master/JsonToClass/jtc.png)

# 🚀 JTC

## JSON TO CLASS
> JSON to Class Helper written in Objective-C for iOS developers.

<br>

## 목표
> 클라이언트 개발 시 json 파싱 과정에서 생기는 실수를 방지하고 불필요한 반복 작업을 줄여 파싱 과정을 효율화 하기 위해 기획된 앱

![mainImage](https://github.com/pkh0225/JSON-to-CLASS/blob/master/JsonToClass/UIMain.png)



<br>

## Core Functions


```
- (NSString *)makeImplementationParser
{
    
    NSMutableString *str = [[NSMutableString alloc] init];
    
    for (PropertyModelData *propertyModelData in self.propertyList)
    {
        NSString *key = propertyModelData.key;
        NSObject *value = propertyModelData.value;
        NSString *subClassName = [NSString stringWithFormat:@"%@%@",self.perfix, [key upercaseFirstChar]];
        NSString *arraySubClassName = [NSString stringWithFormat:@"%@%@%@",self.perfix, [key upercaseFirstChar], ARRAY_INNER_CLASS_TAIL_PIX];
        //        NSLog(@"key = %@, value = %@, value class = %@", key, value, [value className]);
        
        if ([value isKindOfClass:[NSString class]])
        {
            [str appendFormat:@"\n    self.%@ = [dic objectForKey:@\"%@\"];", key, key];
        }
        else if ([value isKindOfClass:[NSNumber class]])
        {
            [str appendFormat:@"\n    %@", [self makeMClassParserNumberType:CFNumberGetType((CFNumberRef)value) key:key]];
        }
        else if ([value isKindOfClass:[NSArray class]])
        {
            NSArray *array = (NSArray *)value;
            
            if ([array count] > 0)
            {
                NSObject *obj = [array objectAtIndex:0];
                if ([obj isKindOfClass:[NSDictionary class]])
                {
                    [str appendFormat:@"\n    if ([[dic objectForKey:@\"%@\"] isKindOfClass:[NSArray class]]) {", key];
                    [str appendFormat:@"\n        self.%@ = [[NSMutableArray<%@*> alloc] init];", key, arraySubClassName];
                    [str appendFormat:@"\n        for (NSDictionary *arrayItem  in [dic objectForKey:@\"%@\"])"
                                      @"\n        {"
                                      @"\n            %@ *obj =  [%@ allocWithDictionary:arrayItem];"
                                      @"\n            if (obj != nil)"
                                      @"\n                [self.%@ addObject:obj];"
                                      @"\n        }",
                     key, arraySubClassName, arraySubClassName, key];
                    [str appendFormat:@"\n    }"];
                }
                else
                {
                    [str appendFormat:@"\n    self.%@ = [dic objectForKey:@\"%@\"];", key, key];
                }
                
            }
        }
        else if ([value isKindOfClass:[NSDictionary class]])
        {
            [str appendFormat:@"\n    self.%@ = [%@ allocWithDictionary:[dic objectForKey:@\"%@\"]];", key, subClassName, key];
        }
        else
        {
            [str appendFormat:@"\n    self.%@ =  %@; //type error %@", key, NSStringFromClass([value class]), NSStringFromClass([value class])];
        }
    }
    
    return str;
}
```
