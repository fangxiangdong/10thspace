package com.tenth.space.imservice.event;

/**
 * @author : yingmu on 15-1-19.
 * @email : yingmu@mogujie.com.
 *
 * 临时解决
 * 背景: 1.EventBus的cancelEventDelivery的只能在postThread中运行，而且没有办法绕过这一点
 * 2. onEvent(A a)  onEventMainThread(A a) 这个两个是没有办法共存的
 * 解决: 抽离出那些需要优先级的event，在onEvent通过handler调用主线程，
 * 然后cancelEventDelivery
 */
public class PriorityEvent {

    public Object object;
    public Event event;
    public enum  Event{
        MSG_SYSTEM,
        MSG_GET_ADD_FRIEND_RSQ,
        MSG_RECEIVED_MESSAGE,
        MSG_ADD_FRIEND_RSP,
        MSG_DEL_FRIEND_RSP,
        MSG_ADD_AGREE_FRIEND_RSP,
        MSG_ADD_AGREE_FRIEND_RSQ,
        MSG_AGREE_OR_DISGREE_ADD_FRIEND_RSP,
        MSG_UNREAD_CNT_ADD_RSP,
        MSG_UNREAD_DATA_ADD_RSP,
        MSG_UPDATE_USERINFO_SUCEED,
    }
}
