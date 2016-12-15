package com.tenth.space.imservice.event;

/**
 * Created by Administrator on 2016/11/29.
 */

public class CountEvent {

    private CountEvent.Event event;
    private int count;

    /**很多的场景只是关心改变的类型以及change的Ids*/

    public CountEvent(Event event,int count){
        this.event = event;
        this.count=count;
    }

//    public CountEvent(GroupEvent.Event event, GroupEntity groupEntity){
//        this.groupEntity = groupEntity;
//        this.event = event;
//    }

    public enum Event{
        UPDATACOUNT
    }

    public Event getEvent() {
        return event;
    }

    public void setEvent(Event event) {
        this.event = event;
    }

    public int getCount() {
        return this.count;
    }
}
