//
// User.m
// JSON
//
// Created by wy on 13-11-12.
// Copyright (c) 2013年 yang. All rights reserved.
//

#import "UserModel.h"

@implementation UserModel

@synthesize user_id     = _user_id;
@synthesize user_name   = _user_name;
@synthesize gender      = _gender;
@synthesize head_image  = _head_image;
@synthesize user_type   = _user_type;
@synthesize description = _description;

- (id)initWithCoder:(NSCoder *)aDecoder
{
	if (self = [super init])
	{
		_user_id     = [aDecoder decodeLongForKey:@"user_id"];
		_user_name   = [aDecoder decodeObjectForKey:@"user_name"];
		_gender      = [aDecoder decodeIntForKey:@"gender"];
		_head_image  = [aDecoder decodeObjectForKey:@"head_image"];
		_user_type   = [aDecoder decodeIntForKey:@"user_type"];
		_description = [aDecoder decodeObjectForKey:@"description"];
	}
	return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeLong:_user_id       forKey:@"user_id"];
    [aCoder encodeObject:_user_name   forKey:@"user_name"];
    [aCoder encodeInt:_gender         forKey:@"gender"];
    [aCoder encodeObject:_head_image  forKey:@"head_image"];
    [aCoder encodeInt:_user_type      forKey:@"user_type"];
    [aCoder encodeObject:_description forKey:@"description"];
}

#pragma mark NSCopying
-(id)copyWithZone:(NSZone *)zone
{
    UserModel* copy = [[UserModel allocWithZone:zone] init];
    
    copy.user_id   = self.user_id;
    copy.gender    = self.gender;
    copy.user_type = self.user_type;

    copy.user_name   = [self.user_name copyWithZone:zone];
    copy.head_image  = [self.head_image copyWithZone:zone];
    copy.description = [self.description copyWithZone:zone];
    return copy;
}

@end