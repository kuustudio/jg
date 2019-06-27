//
//  YZCircleTableViewCell.m
//  ez
//
//  Created by 毛文豪 on 2018/7/18.
//  Copyright © 2018年 9ge. All rights reserved.
//

#import "YZCircleTableViewCell.h"
#import "YZCircleDetailViewController.h"
#import "YZUserCircleViewController.h"
#import "YZUnionBuyDetailViewController.h"
#import "UIButton+YZ.h"

@interface YZCircleTableViewCell ()

@property (nonatomic, weak) UIImageView *avatarImageView;
@property (nonatomic, weak) UILabel *nickNameLabel;
@property (nonatomic, weak) UILabel * timeLabel;
@property (nonatomic, weak) UILabel * communityLabel;
@property (nonatomic, weak) UIButton *attentionButon;
@property (nonatomic, weak) UILabel * detailLabel;
@property (nonatomic, weak) UIView * lotteryView;
@property (nonatomic, weak) UIImageView *logoImageView;
@property (nonatomic, weak) UIButton * praiseButton;
@property (nonatomic, weak) UIButton * commentButton;
@property (nonatomic, weak) YZBottomButton * followtButton;
@property (nonatomic, strong) NSMutableArray *labels;

@end

@implementation YZCircleTableViewCell

//初始化一个cell
+ (instancetype)cellWithTableView:(UITableView *)tableView
{
    static NSString *ID = @"CircleTableViewCellId";
    YZCircleTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if(cell == nil)
    {
        cell = [[YZCircleTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:ID];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return cell;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setupChildViews];
    }
    return self;
}

- (void)setupChildViews
{
    UITapGestureRecognizer * detailTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(circleDetailDidClick)];
    [self addGestureRecognizer:detailTap];
    
    //分割线
    UIView * lineView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, screenWidth, 9)];
    lineView.backgroundColor = YZBackgroundColor;
    [self addSubview:lineView];
    
    //头像
    UIImageView * avatarImageView = [[UIImageView alloc] init];
    self.avatarImageView = avatarImageView;
    avatarImageView.layer.masksToBounds = YES;
    avatarImageView.layer.cornerRadius = 18;
    avatarImageView.userInteractionEnabled = YES;
    [self addSubview:avatarImageView];
    
    //昵称
    UILabel * nickNameLabel = [[UILabel alloc] init];
    self.nickNameLabel = nickNameLabel;
    nickNameLabel.textColor = YZBlackTextColor;
    nickNameLabel.font = [UIFont systemFontOfSize:YZGetFontSize(28)];
    [self addSubview:nickNameLabel];
    
    UITapGestureRecognizer * userTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(userCircleDidClick)];
    [avatarImageView addGestureRecognizer:userTap];
    
    //时间
    UILabel * timeLabel = [[UILabel alloc] init];
    self.timeLabel = timeLabel;
    timeLabel.textColor = YZDrayGrayTextColor;
    timeLabel.font = [UIFont systemFontOfSize:YZGetFontSize(24)];
    [self addSubview:timeLabel];
    
    //玩法
    UILabel * communityLabel = [[UILabel alloc] init];
    self.communityLabel = communityLabel;
    communityLabel.textColor = YZDrayGrayTextColor;
    communityLabel.font = [UIFont systemFontOfSize:YZGetFontSize(26)];
    communityLabel.textAlignment = NSTextAlignmentRight;
    [self addSubview:communityLabel];
    
    //关注
    UIButton *attentionButon = [UIButton buttonWithType:UIButtonTypeCustom];
    self.attentionButon = attentionButon;
    attentionButon.frame = CGRectMake(screenWidth - YZMargin - 70, (60 - 30) / 2, 70, 30);
    [attentionButon setBackgroundImage:[UIImage ImageFromColor:YZBaseColor] forState:UIControlStateNormal];
    [attentionButon setTitle:@"关注" forState:UIControlStateNormal];
    [attentionButon setBackgroundImage:[UIImage ImageFromColor:[UIColor lightGrayColor]] forState:UIControlStateDisabled];
    [attentionButon setTitle:@"已关注" forState:UIControlStateDisabled];
    [attentionButon setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    attentionButon.titleLabel.font = [UIFont systemFontOfSize:YZGetFontSize(26)];
    attentionButon.layer.masksToBounds = YES;
    attentionButon.layer.cornerRadius = 3;
    [attentionButon addTarget:self action:@selector(attentionButonDidClick) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:attentionButon];
    
    //内容
    UILabel * detailLabel = [[UILabel alloc] init];
    self.detailLabel = detailLabel;
    detailLabel.textColor = YZBlackTextColor;
    detailLabel.font = [UIFont systemFontOfSize:YZGetFontSize(24)];
    detailLabel.numberOfLines = 0;
    [self addSubview:detailLabel];
    
    //彩票信息
    UIView * lotteryView = [[UIView alloc] init];
    self.lotteryView = lotteryView;
    lotteryView.backgroundColor = YZColor(255, 251, 243, 1);
    [self addSubview:lotteryView];
    
    for(NSUInteger i = 0; i < 6; i++)
    {
        UILabel *label = [[UILabel alloc] init];
        label.font = [UIFont systemFontOfSize:YZGetFontSize(24)];
        label.textColor = YZDrayGrayTextColor;
        label.numberOfLines = 0;
        [self.labels addObject:label];
        [lotteryView addSubview:label];
    }
    
    //logo
    UIImageView * logoImageView = [[UIImageView alloc] init];
    self.logoImageView = logoImageView;
    logoImageView.backgroundColor = [UIColor redColor];
    logoImageView.layer.masksToBounds = YES;
    logoImageView.layer.cornerRadius = 30;
    [lotteryView addSubview:logoImageView];
    
    //图片
    UIView * lastView = detailLabel;
    for (int i = 0; i < 3; i++) {
        UIImageView * imageView = [[UIImageView alloc] init];
        imageView.tag = i;
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        imageView.layer.masksToBounds = YES;
        imageView.hidden = YES;
        [self addSubview:imageView];
        [self.imageViews addObject:imageView];
        lastView = imageView;
        
        UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageViewDidClick:)];
        imageView.userInteractionEnabled = YES;
        [imageView addGestureRecognizer:tap];
    }
    
    CGFloat buttonW = 40;
    CGFloat buttonH = 26;
    //点赞
    UIButton * praiseButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.praiseButton = praiseButton;
    praiseButton.frame = CGRectMake(screenWidth - 2 * YZMargin - buttonW * 2, CGRectGetMaxY(lastView.frame), buttonW, buttonH);
    [praiseButton setImage:[UIImage imageNamed:@"show_praise_gray"] forState:UIControlStateNormal];
    [praiseButton setTitleColor:YZGrayTextColor forState:UIControlStateNormal];
    praiseButton.titleLabel.font = [UIFont systemFontOfSize:YZGetFontSize(22)];
    [self addSubview:praiseButton];
    
    //评论
    UIButton * commentButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.commentButton = commentButton;
    commentButton.frame = CGRectMake(screenWidth - YZMargin - buttonW, CGRectGetMaxY(lastView.frame), buttonW, buttonH);
    [commentButton setImage:[UIImage imageNamed:@"show_comment"] forState:UIControlStateNormal];
    [commentButton setTitleColor:YZGrayTextColor forState:UIControlStateNormal];
    commentButton.titleLabel.font = [UIFont systemFontOfSize:YZGetFontSize(22)];
    [self addSubview:commentButton];
    
    //跟单
    YZBottomButton * followtButton = [YZBottomButton buttonWithType:UIButtonTypeCustom];
    self.followtButton = followtButton;
    [followtButton setTitle:@"我要跟单" forState:UIControlStateNormal];
    followtButton.titleLabel.font = [UIFont systemFontOfSize:YZGetFontSize(26)];
    [followtButton addTarget:self action:@selector(followtButtonDidClick) forControlEvents:UIControlEventTouchUpInside];
    [self.lotteryView addSubview:followtButton];
}

- (void)userCircleDidClick
{
    YZUserCircleViewController * userCircleVC = [[YZUserCircleViewController alloc] init];
    userCircleVC.circleModel = self.circleModel;
    [self.viewController.navigationController pushViewController:userCircleVC animated:YES];
}

- (void)circleDetailDidClick
{
    YZCircleDetailViewController * circleDetailVC = [[YZCircleDetailViewController alloc] init];
    circleDetailVC.topicId = self.circleModel.topicId;
    [self.viewController.navigationController pushViewController:circleDetailVC animated:YES];
}

- (void)followtButtonDidClick
{
    YZUnionBuyDetailViewController *unionBuyDetailVC = [[YZUnionBuyDetailViewController alloc] initWithUnionBuyUserId:self.circleModel.extInfo.unionBuyUserId unionBuyPlanId:self.circleModel.extInfo.orderId gameId:self.circleModel.extInfo.gameId];
    [self.viewController.navigationController pushViewController:unionBuyDetailVC animated:YES];
}

- (void)attentionButonDidClick
{
    NSDictionary *dict = @{
                           @"userId": UserId,
                           @"byConcernUserId": _circleModel.userId,
                           };
    [[YZHttpTool shareInstance] postWithURL:BaseUrlInformation(@"/userConcern") params:dict success:^(id json) {
        YZLog(@"userConcern:%@",json);
        if (SUCCESS){
            self.attentionButon.enabled = NO;
        }else
        {
            ShowErrorView
        }
    }failure:^(NSError *error)
    {
         YZLog(@"error = %@",error);
    }];
}

- (void)imageViewDidClick:(UIGestureRecognizer *)ges
{
    
}

- (void)setCircleModel:(YZCircleModel *)circleModel
{
    _circleModel = circleModel;
    
    [self.avatarImageView sd_setImageWithURL:[NSURL URLWithString:_circleModel.headPortraitUrl] placeholderImage:[UIImage imageNamed:@"avatar_zc"]];
    self.nickNameLabel.text = _circleModel.nickname ? _circleModel.nickname : _circleModel.userName;
    self.timeLabel.text = _circleModel.timeStr;
    self.communityLabel.text = _circleModel.communityName;
    self.attentionButon.enabled = ![_circleModel.concernStatus boolValue];
#if JG
    self.logoImageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"icon_%@", _circleModel.extInfo.gameId]];
#elif ZC
    self.logoImageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"icon_%@_zc", _circleModel.extInfo.gameId]];
#elif CS
    self.logoImageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"icon_%@_zc", _circleModel.extInfo.gameId]];
#endif
    self.detailLabel.attributedText = _circleModel.detailAttStr;
    [self.praiseButton setTitle:[NSString stringWithFormat:@"%@", _circleModel.likeNumber] forState:UIControlStateNormal];
    [self.commentButton setTitle:[NSString stringWithFormat:@"%@", _circleModel.concernNumber] forState:UIControlStateNormal];
    [self.praiseButton setButtonTitleWithImageAlignment:UIButtonTitleWithImageAlignmentLeft imgTextDistance:2];
    [self.commentButton setButtonTitleWithImageAlignment:UIButtonTitleWithImageAlignmentLeft imgTextDistance:2];
    for (int i = 0; i < _circleModel.lotteryMessages.count; i++) {
        UILabel * label = self.labels[i];
        if (i == 5) {
            if (_circleModel.isDetail) {
                label.attributedText = _circleModel.lotteryMessages[i];
            }
        }else
        {
            label.text = _circleModel.lotteryMessages[i];
        }
    }
    
    //frame
    self.avatarImageView.frame = _circleModel.avatarImageViewF;
    self.nickNameLabel.frame = _circleModel.nickNameLabelF;
    self.timeLabel.frame = _circleModel.timeLabelF;
    self.communityLabel.frame = _circleModel.communityLabelF;
    self.attentionButon.frame = _circleModel.attentionButonF;
    self.detailLabel.frame = _circleModel.detailLabelF;
    self.lotteryView.frame = _circleModel.lotteryViewF;
    self.lotteryView.hidden = YZStringIsEmpty(_circleModel.extInfo.userId);
    for (int i = 0; i < self.labels.count; i++) {
        UILabel * label = self.labels[i];
        label.hidden = YES;
        if (i < _circleModel.labelFs.count) {
            label.hidden = NO;
            label.frame = [_circleModel.labelFs[i] CGRectValue];
        }
    }
    self.followtButton.frame = _circleModel.followtButtonF;
    self.logoImageView.frame = _circleModel.logoImageViewF;
    UIView * lastView = self.lotteryView;
    for (int i = 0; i < self.imageViews.count; i++) {
        UIImageView * imageView = self.imageViews[i];
        imageView.hidden = YES;
        if (i < _circleModel.imageViewFs.count) {
            NSDictionary * imageDic = _circleModel.topicAlbumList[i];
            [imageView sd_setImageWithURL:[NSURL URLWithString:imageDic[@"breviaryUrl"]] placeholderImage:[UIImage ImageFromColor:YZLightDrayColor]];
            CGRect imageViewF = [_circleModel.imageViewFs[i] CGRectValue];
            imageView.hidden = NO;
            imageView.frame = imageViewF;
            lastView = imageView;
        }
    }
    self.praiseButton.y = CGRectGetMaxY(lastView.frame) + 5;
    self.commentButton.y = CGRectGetMaxY(lastView.frame) + 5;
}

#pragma mark - 初始化
- (NSMutableArray *)labels
{
    if(_labels == nil)
    {
        _labels = [NSMutableArray array];
    }
    return  _labels;
}

- (NSMutableArray *)imageViews
{
    if (!_imageViews) {
        _imageViews = [NSMutableArray array];
    }
    return _imageViews;
}


@end
