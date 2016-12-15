package com.tenth.space.imservice.manager;

import com.tenth.space.imservice.event.CountEvent;
import com.tenth.space.protobuf.IMBaseDefine;
import com.tenth.space.protobuf.IMBuddy;

import de.greenrobot.event.EventBus;

/**
 * Created by Administrator on 2016/11/29.
 */

public class IMonLineCountManager extends IMManager {
    private static IMonLineCountManager inst = new IMonLineCountManager();

    public static IMonLineCountManager instance() {
        return inst;
    }

    public IMonLineCountManager() {
    }

    // 依赖的服务管理
    private IMSocketManager imSocketManager = IMSocketManager.instance();

    public void  getONlineCount(int userId){
        imSocketManager.isSocketConnect();
        IMBuddy.IMALLOnlineUserCntReq req=  IMBuddy.IMALLOnlineUserCntReq.newBuilder()
                .setUserId(userId).build();
        int sid =IMBaseDefine.ServiceID.SID_BUDDY_LIST_VALUE;
        int cid = IMBaseDefine.BuddyListCmdID.CID_BUDDY_LIST_ALL_ONLINE_USER_CNT_REQUEST_VALUE;
        imSocketManager.sendRequest(req,sid,cid);

    }

    public void onOperateGetCount(IMBuddy.IMALLOnlineUserCntRsp imallOnlineUserCntRsp) {
        int userCnt = imallOnlineUserCntRsp.getOnlineUserCnt();
        triggerEvent(new CountEvent(CountEvent.Event.UPDATACOUNT,userCnt));
        //发送出去
    }
    public  synchronized void triggerEvent( CountEvent event) {
        switch (event.getEvent()){
            case UPDATACOUNT:
                EventBus.getDefault().postSticky(event);
                break;
        }

    }

    @Override
    public void doOnStart() {

    }

    @Override
    public void reset() {
        EventBus.getDefault().unregister(inst);
    }
}
