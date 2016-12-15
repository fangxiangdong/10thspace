package com.tenth.space.imservice.manager;

import com.google.protobuf.CodedInputStream;
import com.tenth.space.protobuf.IMBaseDefine;
import com.tenth.space.protobuf.IMBlog;
import com.tenth.space.protobuf.IMBuddy;
import com.tenth.space.protobuf.IMGroup;
import com.tenth.space.protobuf.IMLogin;
import com.tenth.space.protobuf.IMMessage;
import com.tenth.space.utils.LogUtils;
import com.tenth.space.utils.Logger;

import java.io.IOException;

import static android.os.Build.VERSION_CODES.M;

/**
 * yingmu
 * 消息分发中心，处理消息服务器返回的数据包
 * 1. decode  header与body的解析
 * 2. 分发
 */
public class IMPacketDispatcher {
    private static Logger logger = Logger.getLogger(IMPacketDispatcher.class);

    /**
     * @param commandId
     * @param buffer    有没有更加优雅的方式
     */
    public static void loginPacketDispatcher(int commandId, CodedInputStream buffer) {
        try {
            switch (commandId) {
                case IMBaseDefine.LoginCmdID.CID_LOGIN_RES_LOGINOUT_VALUE:
                    IMLogin.IMLogoutRsp imLogoutRsp = IMLogin.IMLogoutRsp.parseFrom(buffer);
                    IMLoginManager.instance().onRepLoginOut(imLogoutRsp);
                    return;

                case IMBaseDefine.LoginCmdID.CID_LOGIN_KICK_USER_VALUE:
                    IMLogin.IMKickUser imKickUser = IMLogin.IMKickUser.parseFrom(buffer);
                    IMLoginManager.instance().onKickout(imKickUser);
            }
        } catch (IOException e) {
            logger.e("loginPacketDispatcher# error,cid:%d", commandId);
        }
    }

    public static void buddyPacketDispatcher(int commandId, CodedInputStream buffer) {
        try {//541
            switch (commandId) {
                case IMBaseDefine.BuddyListCmdID.CID_BUDDY_LIST_AVATAR_CHANGED_NOTIFY_VALUE:
                    IMBuddy.IMAvatarChangedNotify avatarChangedNotify = IMBuddy.IMAvatarChangedNotify.parseFrom(buffer);
                    IMBuddyManager.instance().onChangeAvatarNotify(avatarChangedNotify);
                    return;

                case IMBaseDefine.BuddyListCmdID.CID_BUDDY_LIST_FOLLOW_USER_RESPONSE_VALUE:
                    IMBuddy.IMFollowUserRsp followUserRsp = IMBuddy.IMFollowUserRsp.parseFrom(buffer);
                    IMBuddyManager.instance().onReqFollowUser(followUserRsp);
                    return;

                case IMBaseDefine.BuddyListCmdID.CID_BUDDY_LIST_DEL_FOLLOW_USER_RESPONSE_VALUE:
                    IMBuddy.IMDelFollowUserRsp delFollowUserRsp = IMBuddy.IMDelFollowUserRsp.parseFrom(buffer);
                    IMBuddyManager.instance().onReqDelFollowUser(delFollowUserRsp);
                    return;

                case IMBaseDefine.BuddyListCmdID.CID_BUDDY_LIST_ALL_USER_RESPONSE_VALUE:
                    IMBuddy.IMAllUserRsp imAllUserRsp = IMBuddy.IMAllUserRsp.parseFrom(buffer);
                    IMContactManager.instance().onRepAllUsers(imAllUserRsp);
                    return;

                case IMBaseDefine.BuddyListCmdID.CID_BUDDY_LIST_USER_INFO_RESPONSE_VALUE:
                    IMBuddy.IMUsersInfoRsp imUsersInfoRsp = IMBuddy.IMUsersInfoRsp.parseFrom(buffer);
                    IMContactManager.instance().onRepDetailUsers(imUsersInfoRsp);
                    return;
                case IMBaseDefine.BuddyListCmdID.CID_BUDDY_LIST_RECENT_CONTACT_SESSION_RESPONSE_VALUE:
                    IMBuddy.IMRecentContactSessionRsp recentContactSessionRsp = IMBuddy.IMRecentContactSessionRsp.parseFrom(buffer);
                    IMSessionManager.instance().onRepRecentContacts(recentContactSessionRsp);
                    return;

                case IMBaseDefine.BuddyListCmdID.CID_BUDDY_LIST_REMOVE_SESSION_RES_VALUE:
                    IMBuddy.IMRemoveSessionRsp removeSessionRsp = IMBuddy.IMRemoveSessionRsp.parseFrom(buffer);
                    IMSessionManager.instance().onRepRemoveSession(removeSessionRsp);
                    return;

                case IMBaseDefine.BuddyListCmdID.CID_BUDDY_LIST_PC_LOGIN_STATUS_NOTIFY_VALUE:
                    IMBuddy.IMPCLoginStatusNotify statusNotify = IMBuddy.IMPCLoginStatusNotify.parseFrom(buffer);
                    IMLoginManager.instance().onLoginStatusNotify(statusNotify);
                    return;

                case IMBaseDefine.BuddyListCmdID.CID_BUDDY_LIST_DEPARTMENT_RESPONSE_VALUE:
                    IMBuddy.IMDepartmentRsp departmentRsp = IMBuddy.IMDepartmentRsp.parseFrom(buffer);
                    IMContactManager.instance().onRepDepartment(departmentRsp);
                    return;
                case IMBaseDefine.BuddyListCmdID.CID_BUDDY_LIST_SEARCH_USER_RESPONSE_VALUE:
                    IMBuddy.IMSearchUserRsp searchUserRsp = IMBuddy.IMSearchUserRsp.parseFrom(buffer);
                    FriendManager.instance().onReqFriendsList(searchUserRsp);
                    return;
                case IMBaseDefine.BuddyListCmdID.CID_BUDDY_LIST_ADD_FRIEND_RESPONSE_VALUE:
                    IMBuddy.IMAddFriendRsp imAddFriendRsp1 = IMBuddy.IMAddFriendRsp.parseFrom(buffer);
                    FriendManager.instance().onOperateFriendRsp(imAddFriendRsp1);
                    return;
                case IMBaseDefine.BuddyListCmdID.CID_BUDDY_LIST_ADD_FRIEND_DATA_VALUE:
                    IMBuddy.IMAddFriendData imAddFriendData = IMBuddy.IMAddFriendData.parseFrom(buffer);
                    FriendManager.instance().onOperateFriendRsp(imAddFriendData);
                    return;
                case IMBaseDefine.BuddyListCmdID.CID_BUDDY_LIST_AGREE_ADD_FRIEND_RESPONSE_VALUE:
                    IMBuddy.IMAgreeAddFriendRsp imAgreeAddFriendRsp = IMBuddy.IMAgreeAddFriendRsp.parseFrom(buffer);
                    FriendManager.instance().onOperateFriendRsp(imAgreeAddFriendRsp);
                    return;
                case IMBaseDefine.BuddyListCmdID.CID_BUDDY_LIST_DEL_FRIEND_RESPONSE_VALUE:
                    IMBuddy.IMDelFriendRsp imDelFriendRsp = IMBuddy.IMDelFriendRsp.parseFrom(buffer);
                    FriendManager.instance().onOperateFriendRsp(imDelFriendRsp);
                    break;
                case IMBaseDefine.BuddyListCmdID.CID_BUDDY_LIST_ADD_FRIEND_UNREAD_CNT_RESPONSE_VALUE:
                    IMBuddy.IMAddFriendUnreadCntRsp imAddFriendUnreadCntRsp = IMBuddy.IMAddFriendUnreadCntRsp.parseFrom(buffer);
                    FriendManager.instance().onOperateFriendRsp(imAddFriendUnreadCntRsp);
                    break;
                case IMBaseDefine.BuddyListCmdID.CID_BUDDY_LIST_GET_ADD_FRIEND_DATA_RESPONSE_VALUE:
                    IMBuddy.IMGetAddFriendDataRsp imGetAddFriendDataRsp = IMBuddy.IMGetAddFriendDataRsp.parseFrom(buffer);
                    FriendManager.instance().onOperateFriendRsp(imGetAddFriendDataRsp);
                    break;
                case IMBaseDefine.BuddyListCmdID.CID_BUDDY_LIST_ALL_ONLINE_USER_CNT_RESPONSE_VALUE:
                    //返回请求人数
                    IMBuddy.IMALLOnlineUserCntRsp imallOnlineUserCntReq = IMBuddy.IMALLOnlineUserCntRsp.parseFrom(buffer);
                    IMonLineCountManager.instance().onOperateGetCount(imallOnlineUserCntReq);
                    break;
                case IMBaseDefine.BuddyListCmdID.CID_BUDDY_LIST_UPDATE_USER_INFO_RESPONSE_VALUE:
                    IMBuddy.IMUpdateUsersInfoRsp imUpdateUsersInfoRsp = IMBuddy.IMUpdateUsersInfoRsp.parseFrom(buffer);
                    FriendManager.instance().onOperateFriendRsp(imUpdateUsersInfoRsp);
                    break;
                default:
                    int i = commandId;
                    return;
            }
        } catch (IOException e) {
            logger.e("buddyPacketDispatcher# error,cid:%d", commandId);
        }
    }

    public static void msgPacketDispatcher(int commandId, CodedInputStream buffer) {
        try {
            switch (commandId) {
                case IMBaseDefine.MessageCmdID.CID_MSG_DATA_ACK_VALUE:
                    // have some problem  todo
                    return;

                case IMBaseDefine.MessageCmdID.CID_MSG_LIST_RESPONSE_VALUE:
                    IMMessage.IMGetMsgListRsp rsp = IMMessage.IMGetMsgListRsp.parseFrom(buffer);
                    IMMessageManager.instance().onReqHistoryMsg(rsp);
                    return;

                case IMBaseDefine.MessageCmdID.CID_MSG_DATA_VALUE:
                    IMMessage.IMMsgData imMsgData = IMMessage.IMMsgData.parseFrom(buffer);
                    IMMessageManager.instance().onRecvMessage(imMsgData);
                    return;

                case IMBaseDefine.MessageCmdID.CID_MSG_READ_NOTIFY_VALUE:
                    IMMessage.IMMsgDataReadNotify readNotify = IMMessage.IMMsgDataReadNotify.parseFrom(buffer);
                    IMUnreadMsgManager.instance().onNotifyRead(readNotify);
                    return;
                case IMBaseDefine.MessageCmdID.CID_MSG_UNREAD_CNT_RESPONSE_VALUE:
                    IMMessage.IMUnreadMsgCntRsp unreadMsgCntRsp = IMMessage.IMUnreadMsgCntRsp.parseFrom(buffer);
                    IMUnreadMsgManager.instance().onRepUnreadMsgContactList(unreadMsgCntRsp);
                    return;

                case IMBaseDefine.MessageCmdID.CID_MSG_GET_BY_MSG_ID_RES_VALUE:
                    IMMessage.IMGetMsgByIdRsp getMsgByIdRsp = IMMessage.IMGetMsgByIdRsp.parseFrom(buffer);
                    IMMessageManager.instance().onReqMsgById(getMsgByIdRsp);
                    break;

                default:
                    LogUtils.e(commandId + "");
                    break;
            }
        } catch (IOException e) {
            logger.e("msgPacketDispatcher# error,cid:%d", commandId);
        }
    }

    public static void groupPacketDispatcher(int commandId, CodedInputStream buffer) {
        try {
            switch (commandId) {
                case IMBaseDefine.GroupCmdID.CID_GROUP_NORMAL_LIST_RESPONSE_VALUE:
                    IMGroup.IMNormalGroupListRsp normalGroupListRsp = IMGroup.IMNormalGroupListRsp.parseFrom(buffer);
                    IMGroupManager.instance().onRepNormalGroupList(normalGroupListRsp);
                    return;

                case IMBaseDefine.GroupCmdID.CID_GROUP_INFO_RESPONSE_VALUE:
                    IMGroup.IMGroupInfoListRsp groupInfoListRsp = IMGroup.IMGroupInfoListRsp.parseFrom(buffer);
                    IMGroupManager.instance().onRepGroupDetailInfo(groupInfoListRsp);
                    return;

                case IMBaseDefine.GroupCmdID.CID_GROUP_CHANGE_MEMBER_NOTIFY_VALUE:
                    IMGroup.IMGroupChangeMemberNotify notify = IMGroup.IMGroupChangeMemberNotify.parseFrom(buffer);
                    IMGroupManager.instance().receiveGroupChangeMemberNotify(notify);
                case IMBaseDefine.GroupCmdID.CID_GROUP_SHIELD_GROUP_RESPONSE_VALUE:
                    //todo
                    return;
            }
        } catch (IOException e) {
            logger.e("groupPacketDispatcher# error,cid:%d", commandId);
        }
    }


    public static void onBlogDispatcher(int commandId, CodedInputStream buffer) {
        try {
            switch (commandId) {

                case IMBaseDefine.BlogCmdID.CID_BLOG_GET_LIST_RESPONSE_VALUE:
                    IMBlog.IMBlogGetListRsp getBlogListRsp = IMBlog.IMBlogGetListRsp.parseFrom(buffer);
                    IMBlogManager.instance().onReqBlogList(getBlogListRsp);
                    break;

                case IMBaseDefine.BlogCmdID.CID_BLOG_GET_COMMENT_RESPONSE_VALUE:
                    IMBlog.IMBlogGetCommentRsp getCommentRsp = IMBlog.IMBlogGetCommentRsp.parseFrom(buffer);
                    IMBlogManager.instance().onRspGetComment(getCommentRsp);
                    break;
            }
        } catch (IOException e) {
            logger.e("groupPacketDispatcher# error,cid:%d", commandId);
        }
    }
}
