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
@synthesize area = _area;
@synthesize areas = _areas;
@synthesize easemob_name = _easemob_name;
@synthesize easemob_pwd = _easemob_pwd;

- (id)initWithCoder:(NSCoder *)aDecoder
{
	if (self = [super init])
	{
		_user_id     = [aDecoder decodeInt32ForKey:@"user_id"];
		_user_name   = [aDecoder decodeObjectForKey:@"user_name"];
		_gender      = [aDecoder decodeIntForKey:@"gender"];
		_head_image  = [aDecoder decodeObjectForKey:@"head_image"];
		_user_type   = [aDecoder decodeIntForKey:@"user_type"];
		_description = [aDecoder decodeObjectForKey:@"description"];
        _area        = [aDecoder decodeObjectForKey:@"area"];
        _areas       = [aDecoder decodeObjectForKey:@"areas"];
        _easemob_name = [aDecoder decodeObjectForKey:@"easemob_name"];
        _easemob_pwd = [aDecoder decodeObjectForKey:@"easemob_pwd"];
	}
	return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeInt:_user_id        forKey:@"user_id"];
    [aCoder encodeObject:_user_name   forKey:@"user_name"];
    [aCoder encodeInt:_gender         forKey:@"gender"];
    [aCoder encodeObject:_head_image  forKey:@"head_image"];
    [aCoder encodeInt:_user_type      forKey:@"user_type"];
    [aCoder encodeObject:_description forKey:@"description"];
    [aCoder encodeObject:_area        forKey:@"area"];
    [aCoder encodeObject:_areas       forKey:@"areas"];
    [aCoder encodeObject:_easemob_name forKey:@"easemob_name"];
    [aCoder encodeObject:_easemob_pwd forKey:@"easemob_pwd"];
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
    copy.area        = [self.area copyWithZone:zone];
    copy.areas       = [self.areas copyWithZone:zone];
    copy.easemob_name = [self.easemob_name copyWithZone:zone];
    copy.easemob_pwd = [self.easemob_pwd copyWithZone:zone];
    return copy;
}

+ (void)saveUserModelObject:(UserModel *)object key:(NSString *)key
{
    NSData *encodedObject = [NSKeyedArchiver archivedDataWithRootObject:object];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:encodedObject forKey:key];
    [defaults synchronize];
}
+ (UserModel*)loadUserModelObjectWithKey:(NSString*)key
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSData *encodedObject = [defaults objectForKey:key];
    UserModel *object = [NSKeyedUnarchiver unarchiveObjectWithData:encodedObject];
    return object;
}
@end
