//
// Area.m
// JSON
//
// Created by wy on 13-11-12.
// Copyright (c) 2013年 yang. All rights reserved.
//

#import "AreaModel.h"

@implementation AreaModel

+ (BOOL)propertyIsOptional:(NSString*)propertyName
{
    if ([propertyName isEqualToString:@"hots"])
        return YES;
    else if ([propertyName isEqualToString:@"sequence"])
        return YES;
    else
        return NO;
}
- (id)initWithCoder:(NSCoder *)aDecoder
{
	if (self = [super init])
	{
		_area_id     = [aDecoder decodeIntForKey:@"area_id"];
		_area_name   = [aDecoder decodeObjectForKey:@"area_name"];
        _hots        = [aDecoder decodeIntForKey:@"hots"];
		_type        = [aDecoder decodeIntForKey:@"type"];
        _sequence    = [aDecoder decodeIntForKey:@"sequence"];
		_type_name   = [aDecoder decodeObjectForKey:@"type_name"];
		_city        = [aDecoder decodeObjectForKey:@"city"];
	}
	return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeInt:_area_id      forKey:@"area_id"];
    [aCoder encodeObject:_area_name forKey:@"area_name"];
    [aCoder encodeInt:_hots         forKey:@"hots"];
    [aCoder encodeInt:_type         forKey:@"type"];
    [aCoder encodeObject:_type_name forKey:@"type_name"];
    [aCoder encodeInt:_sequence     forKey:@"sequence"];
    [aCoder encodeObject:_city      forKey:@"city"];
}

#pragma mark NSCopying
-(id)copyWithZone:(NSZone *)zone
{
    AreaModel* copy = [[AreaModel allocWithZone:zone] init];
    
    copy.area_id  = self.area_id;
    copy.type     = self.type;
    copy.hots     = self.hots;
    copy.sequence = self.sequence;
    
    copy.area_name = [self.area_name copyWithZone:zone];
    copy.type_name = [self.type_name copyWithZone:zone];
    copy.city      = [self.city copyWithZone:zone];
    return copy;
}
@end

@implementation Areas

@end