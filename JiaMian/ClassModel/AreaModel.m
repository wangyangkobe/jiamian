//
// Area.m
// JSON
//
// Created by wy on 13-11-12.
// Copyright (c) 2013年 yang. All rights reserved.
//

#import "AreaModel.h"

@implementation AreaModel

- (id)initWithCoder:(NSCoder *)aDecoder
{
	if (self = [super init])
	{
		_area_id     = [aDecoder decodeIntForKey:@"area_id"];
		_area_name   = [aDecoder decodeObjectForKey:@"area_name"];
		_type        = [aDecoder decodeIntForKey:@"type"];
		_type_name   = [aDecoder decodeObjectForKey:@"type_name"];
		_city        = [aDecoder decodeObjectForKey:@"city"];
	}
	return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeInt:_area_id      forKey:@"area_id"];
    [aCoder encodeObject:_area_name forKey:@"area_name"];
    [aCoder encodeInt:_type         forKey:@"type"];
    [aCoder encodeObject:_type_name forKey:@"type_name"];
    [aCoder encodeObject:_city      forKey:@"city"];
}

#pragma mark NSCopying
-(id)copyWithZone:(NSZone *)zone
{
    AreaModel* copy = [[AreaModel allocWithZone:zone] init];
    
    copy.area_id  = self.area_id;
    copy.type     = self.type;
    
    copy.area_name = [self.area_name copyWithZone:zone];
    copy.type_name = [self.type_name copyWithZone:zone];
    copy.city      = [self.city copyWithZone:zone];
    return copy;
}
@end

@implementation Areas

@end