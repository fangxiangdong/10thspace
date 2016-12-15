/************************************************************
 * @file         TcpProtocolHeader.h
 * @author       快刀<kuaidao@mogujie.com>
 * summery       tcp服务器协议头，包括每个service下的command Id定义
 *
     packet data unit header format:
     length     -- 4 byte
     version    -- 2 byte
     flag       -- 2 byte
     service_id -- 2 byte
     command_id -- 2 byte
     error      -- 2 byte
     reserved   -- 2 byte
 ************************************************************/

#import <Foundation/Foundation.h>
#import <stdint.h>

//SID
enum
{
    SID_LOGIN                                   = 0x0001,
    SID_BUDDY_LIST                              = 0x0002,
    SID_MSG                                     = 0x0003,
    SID_GROUP                                   = 0x0004,
    SID_SWITCH_SERVICE                          = 0x0006,
    SID_OTHER                                   = 0x0007,
    SID_INTERNAL                                = 0x0008,
    SID_REGISTER                                = 0x0009,
    SID_BLOG                                    = 0x000A,            //下一步把blog从msg中独立出来
    SID_SYSTEM                                  = 0x000B,
};

//SID_LOGIN
enum{
    IM_LOGIN_REQ                                = 0x0103,
    IM_LOGIN_RES                                = 0x0104,
    IM_LOGOUT_REQ                               = 0x0105,
    IM_LOGOUT_RES                               = 0x0106,
    IM_KICK_USER                                = 0x0107,
    IM_DEVICE_TOKEN_REQ                         = 0x0108,
    IM_DEVICE_TOKEN_RES                         = 0x0109,
    IM_KICK_PC_CLIENT_REQ                       = 0x010a,
    IM_KICK_PC_CLIENT_RES                       = 0x010b,
    IM_PUSH_SHIELD_REQ                          = 0x010c,
    IM_PUSH_SHIELD_RES                          = 0x010d,
    IM_QUERY_PUSH_SHIELD_REQ                    = 0x010e,
    IM_QUERY_PUSH_SHIELD_RES                    = 0x010f,
};

//SID_BUDDY_LIST
enum{
    IM_RECENT_CCONTACT_SESSION_REQ              = 0x0201,
    IM_RECENT_CCONTACT_SESSION_RES              = 0x0202,
    IM_USERS_INFO_REQ                           = 0x0204,
    IM_USERS_INFO_RES                           = 0x0205,
    IM_REMOVE_SESSION_REQ                       = 0x0206,
    IM_REMOVE_SESSION_RES                       = 0x0207,
    IM_ALL_USER_REQ                             = 0x0208,
    IM_ALL_USER_RES                             = 0x0209,
    IM_USERS_STAT_REQ                           = 0x020a,
    IM_USERS_STAT_RSP                           = 0x020b,
    IM_PC_LOGIN_STATUS_NOTIFY                   = 0x020e,
    IM_CHANGE_SIGN_INFO_REQ                     = 0x0213,
    IM_CHANGE_SIGN_INFO_RES                     = 0x0214,
    IM_SIGN_INFO_CHANGED_NOTIFY                 = 0x0215,
    
};

//SID_MSG
enum
{
    IM_MSG_DATA                                 = 0x0301,
    IM_MSG_DATA_ACK                             = 0x0302,
    IM_MSG_DATA_READ_ACK                        = 0x0303,
    IM_MSG_DATA_READ_NOTIFY                     = 0x0304,
    IM_UNREAD_MSG_CNT_REQ                       = 0x0307,
    IM_UNREAD_MSG_CNT_RSP                       = 0x0308,
    IM_GET_MSG_LIST_REQ                         = 0x0309,
    IM_GET_MSG_LIST_RSP                         = 0x030a,
    IM_GET_LASTEST_MSGID_REQ                    = 0x030b,
    IM_GET_LASTEST_MSGID_RES                    = 0x030c,
    IM_GET_MSG_BY_ID_REQ                        = 0x030d,
    IM_GET_MSG_BY_ID_RES                        = 0x030e,
};

//SID_GROUP
enum
{
    IM_NORMAL_GROUP_LIST_REQ                    = 0x0401,
    IM_NORMAL_GROUP_LIST_RES                    = 0x0402,
    IM_GROUP_INFO_LIST_REQ                      = 0x0403,
    IM_GROUP_INFO_LIST_RES                      = 0x0404,
    IM_GROUP_CREATE_REQ                         = 0x0405,
    IM_GROUP_CREATE_RES                         = 0x0406,
    IM_GROUP_CHANGE_MEMBER_REQ                  = 0x0407,
    IM_GROUP_CHANGE_MEMBER_RES                  = 0x0408,
    IM_GROU_SHIELD_REQ                          = 0x0409,
    IM_GROU_SHIELD_RES                          = 0x040a,
    
};

// SID_SWITCH_SERVICE
enum
{
    IM_P2P_CMD_MSG                              = 0x0601,
};


// SID_OTHER
enum
{
    IM_HEART_BEAT                               = 0x0701
};

//friend
enum
{
    CID_BUDDY_LIST_SEARCH_USER_REQUEST                  = 0x0216,
    CID_BUDDY_LIST_SEARCH_USER_RESPONSE                 = 0x0217,
    CID_BUDDY_LIST_ADD_FRIEND_REQUEST                   = 0x0218,
    CID_BUDDY_LIST_ADD_FRIEND_RESPONSE                  = 0x0219,
    CID_BUDDY_LIST_AGREE_ADD_FRIEND_REQUEST             = 0x021e,
    CID_BUDDY_LIST_AGREE_ADD_FRIEND_RESPONSE            = 0x021f,
    CID_BUDDY_LIST_DEL_FRIEND_REQUEST                   = 0x0222,
    CID_BUDDY_LIST_DEL_FRIEND_RESPONSE                  = 0x0223,
    ID_BUDDY_LIST_DEL_FOLLOW_USER_REQUEST               = 0x0224,
    ID_BUDDY_LIST_DEL_FOLLOW_USER_RESPONSE              = 0x0225,
    CID_BUDDY_LIST_ADD_FRIEND_DATA                      = 0x021a,  // 推送的，不需请求
    CID_BUDDY_LIST_ADD_FRIEND_READ_DATA_ACK             = 0x021b,
    CID_BUDDY_LIST_ADD_FRIEND_UNREAD_CNT_REQUEST        = 0x021c,
    CID_BUDDY_LIST_ADD_FRIEND_UNREAD_CNT_RESPONSE       = 0x021d,
    CID_BUDDY_LIST_GET_ADD_FRIEND_DATA_REQUEST          = 0x0226,
    CID_BUDDY_LIST_GET_ADD_FRIEND_DATA_RESPONSE         = 0x0227,
    CID_BUDDY_LIST_ALL_ONLINE_USER_CNT_REQUEST          = 0x0228,  // 所有在线用户
    CID_BUDDY_LIST_ALL_ONLINE_USER_CNT_RESPONSE         = 0x0229,
    CID_BUDDY_LIST_UPDATE_USER_INFO_REQUEST             = 0x022a,
    CID_BUDDY_LIST_UPDATE_USER_INFO_RESPONSE            = 0x022b
};

//blog
enum
{
    CID_MSG_BLOG			               = 0x030f,
    CID_MSG_BLOG_ACK			           = 0x0310,
    CID_MSG_BLOG_LIST_REQUEST              = 0x0311,    //获取指定队列消息
    CID_MSG_BLOG_LIST_RESPONSE             = 0x0312,
    CID_MSG_ADD_BLOG_COMMENT_REQUEST       = 0x0313,    //添加评论
    CID_MSG_ADD_BLOG_COMMENT_RESPONSE      = 0x0314,
    CID_MSG_GET_BLOG_COMMENT_REQUEST       = 0x0315,    //取评论
    CID_MSG_GET_BLOG_COMMENT_RESPONSE      = 0x0316,
};

// NEW BLOG
enum
{
    CID_BLOG_SEND			           = 0x0A01,	//发blog
    CID_BLOG_SEND_ACK			       = 0x0A02,
    CID_BLOG_GET_LIST_REQUEST          = 0x0A03,    //获取blog列表
    CID_BLOG_GET_LIST_RESPONSE         = 0x0A04,
    CID_BLOG_ADD_COMMENT_REQUEST       = 0x0A05,    //添加评论
    CID_BLOG_ADD_COMMENT_RESPONSE      = 0x0A06,
    CID_BLOG_GET_COMMENT_REQUEST       = 0x0A07,    //取评论
    CID_BLOG_GET_COMMENT_RESPONSE      = 0x0A08,
};

//AVATAR
enum
{
    CID_BUDDY_LIST_CHANGE_AVATAR_REQUEST            = 0x020c,
    CID_BUDDY_LIST_CHANGE_AVATAR_RESPONSE           = 0x020d,
};

//关注
enum
{
    CID_BUDDY_LIST_FOLLOW_USER_REQUEST              = 0x0220,
    CID_BUDDY_LIST_FOLLOW_USER_RESPONSE             = 0x0221
};

// 取消关注
enum
{
    CID_BUDDY_LIST_DEL_FOLLOW_USER_REQUEST          = 0x0224,
    CID_BUDDY_LIST_DEL_FOLLOW_USER_RESPONSE         = 0x0225,
};

// SID_SYSTEM
enum
{
    CID_SYS_USER_ONLINE                = 0x0B01,
    CID_SYS_USER_OFFLINE               = 0x0B02,
    CID_SYS_CHANGE_CAMERA_STATUS       = 0x0B03,
    CID_SYS_CAMERA_STATUS_CHANGED      = 0x0B04,
};

@interface DDTcpProtocolHeader : NSObject

@property (nonatomic,assign) UInt16 version;
@property (nonatomic,assign) UInt16 flag;
@property (nonatomic,assign) UInt16 serviceId;
@property (nonatomic,assign) UInt16 commandId;
@property (nonatomic,assign) UInt16 reserved;
@property (nonatomic,assign) UInt16 error;

@end
