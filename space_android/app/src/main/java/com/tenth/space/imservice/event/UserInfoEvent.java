package com.tenth.space.imservice.event;

/**
 * @author : yingmu on 14-12-31.
 * @email : yingmu@mogujie.com.
 *
 * 用户信息事件
 * 1. 群组的信息
 * 2. 用户的信息
 */

public class UserInfoEvent {
    public Event event;
    int changedUserId;
    String avatarUrl;

    public UserInfoEvent(UserInfoEvent.Event event) {
        this.event = event;
    }

    public UserInfoEvent(Event event, int changedUserId, String avatarUrl) {
        this.event = event;
        this.changedUserId = changedUserId;
        this.avatarUrl = avatarUrl;
    }

    public enum Event {
        USER_INFO_OK,
        USER_INFO_UPDATE,
        USER_INFO_CHANGE_AVATAR,
        USER_INFO_CHANGED_NOTIFY
    }
}
