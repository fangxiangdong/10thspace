package com.tenth.space.ui.activity;

import android.app.Activity;
import android.content.Intent;
import android.os.Bundle;
import android.view.View;
import android.widget.ListView;

import com.tenth.space.DB.DBInterface;
import com.tenth.space.DB.entity.RequesterEntity;
import com.tenth.space.R;
import com.tenth.space.imservice.event.PriorityEvent;
import com.tenth.space.imservice.manager.FriendManager;
import com.tenth.space.imservice.manager.IMLoginManager;
import com.tenth.space.imservice.manager.IMSocketManager;
import com.tenth.space.protobuf.IMBaseDefine;
import com.tenth.space.protobuf.IMBuddy;
import com.tenth.space.ui.adapter.NewFriendAdapter;
import com.tenth.space.ui.widget.DrawableCenterEditText;

import org.json.JSONException;
import org.json.JSONObject;

import java.util.List;

import de.greenrobot.event.EventBus;

public class NewFriendsActivity extends Activity{

    private List<RequesterEntity> requesterEntities;
    private NewFriendAdapter adapter;
    private DrawableCenterEditText inputText;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_new_friends);
        //已读添加好友消息
        FriendManager.instance().readAddFriendDate(IMLoginManager.instance().getLoginId());
        initView();
        getOutLineFriendRequest();
        EventBus.getDefault().register(this);
    }

    private void getOutLineFriendRequest() {
        //获取离线好友请求
        int unreadcnt = getIntent().getIntExtra("unreadcnt", 0);
        if (unreadcnt > 0) {
            IMBuddy.IMGetAddFriendDataReq msg = IMBuddy.IMGetAddFriendDataReq.newBuilder()
                    .setUserId(IMLoginManager.instance().getLoginId())
                    .setMsgCnt(unreadcnt)
                    .build();
            int sid = IMBaseDefine.ServiceID.SID_BUDDY_LIST_VALUE;
            int cid = IMBaseDefine.BuddyListCmdID.CID_BUDDY_LIST_GET_ADD_FRIEND_DATA_REQUEST_VALUE;
            IMSocketManager.instance().sendRequest(msg,sid,cid);
        }
    }
    public void onEventMainThread(PriorityEvent event){
        switch (event.event){
            case MSG_UNREAD_DATA_ADD_RSP:
                IMBuddy.IMGetAddFriendDataRsp imGetAddFriendDataRsp = (IMBuddy.IMGetAddFriendDataRsp) event.object;
                List<IMBuddy.IMAddFriendData> dataListList = imGetAddFriendDataRsp.getDataListList();
                JSONObject infoObj;
                for(IMBuddy.IMAddFriendData data:dataListList){
                    String info = data.getAddFriendData().toStringUtf8();
                    try {
                        infoObj= new JSONObject(info);
                        int userId = data.getUserId();
                        //保存到本地数据库
                        RequesterEntity requesterEntity= new RequesterEntity();
                        requesterEntity.setFromUserId(userId);
                        requesterEntity.setAddition_msg(infoObj.optString("addition_msg"));
                        requesterEntity.setAvatar_url(infoObj.optString("avatar_url"));
                        requesterEntity.setNick_name(infoObj.optString("nick_name"));
                        requesterEntity.setCreated(System.currentTimeMillis());
                        requesterEntity.setIsRead(true);
                        requesterEntity.setAgree_states(1);
                        requesterEntities.add(0,requesterEntity);
                        DBInterface.instance().batchInsertOrUpdateRquest(requesterEntity);
                    } catch (JSONException e) {
                        e.printStackTrace();
                    }
                }
                adapter.notifyDataSetChanged();
                //通知已读离线好友请求
                FriendManager.instance().AddFriendReadDataAck();
                break;
        }
    }
    private void initView() {
        findViewById(R.id.text_search).setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                Intent intent = new Intent(NewFriendsActivity.this,FriendsActivity.class);
                startActivity(intent);
            }
        });
        findViewById(R.id.go_add).setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                Intent intent = new Intent(NewFriendsActivity.this,FriendsActivity.class);
                startActivity(intent);
            }
        });
        findViewById(R.id.go_back).setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                finish();
            }
        });
        ListView listView=(ListView)findViewById(R.id.friends_list);
        requesterEntities = DBInterface.instance().setAllRequestIsRead();
        inputText=(DrawableCenterEditText) findViewById(R.id.search_input);
        adapter=new NewFriendAdapter(requesterEntities,this);
        listView.setAdapter(adapter);
    }

    public void setUserInfo(RequesterEntity entity) {
        Intent intent = new Intent();
        intent.putExtra("entity",entity);
        setResult(201,intent);
        this.finish();
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();
        EventBus.getDefault().unregister(this);
    }
}
