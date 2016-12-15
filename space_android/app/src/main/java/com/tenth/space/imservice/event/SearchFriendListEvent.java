package com.tenth.space.imservice.event;

import com.tenth.space.protobuf.IMBaseDefine;

import java.util.List;

/**
 * Created by neil.yi on 2016/9/23.
 */

public class SearchFriendListEvent {

    private Event event;
    private List<IMBaseDefine.UserInfo> searchUserList = null;

    public List<IMBaseDefine.UserInfo> getSearchUserList() {
        return searchUserList;
    }

    public void setSearchUserList(List<IMBaseDefine.UserInfo> searchUserList) {
        this.searchUserList = searchUserList;
    }

    public Event getEvent() {
        return event;
    }

    public void setEvent(Event event) {
        this.event = event;
    }

    public enum Event {
        SEARCH,ADD
    }
}
