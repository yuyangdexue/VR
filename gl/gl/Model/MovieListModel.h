//
//  MovieListModel.h
//  gl
//
//  Created by Yuyangdexue on 15/8/5.
//  Copyright (c) 2015年 yuyang. All rights reserved.
//

#import "JSONModel.h"

@interface MovieListModel : JSONModel
@property (nonatomic,strong) NSString<Optional> *channel;
@property (nonatomic,strong) NSString<Optional> *format;
@property (nonatomic,strong) NSString<Optional> *id;
@property (nonatomic,strong) NSDictionary<Optional> *img;
@property (nonatomic,strong) NSString<Optional> *name;
@property (nonatomic,strong) NSString<Optional> *released;
@property (nonatomic,strong) NSString<Optional> *score;
@end
