package com.tenth.space.ui.fragment;

import android.view.View;


import android.annotation.SuppressLint;
import android.content.Intent;
import android.os.Bundle;
import android.os.Handler;
import android.os.Message;
import android.view.LayoutInflater;
import android.view.ViewGroup;
import android.widget.Button;
import android.widget.ImageView;
import android.widget.ListView;
import android.widget.TextView;
import android.widget.Toast;

import com.tenth.space.DB.DBInterface;
import com.tenth.space.DB.entity.DepartmentEntity;
import com.tenth.space.DB.entity.GroupEntity;
import com.tenth.space.DB.entity.RequesterEntity;
import com.tenth.space.DB.entity.UserEntity;
import com.tenth.space.R;
import com.tenth.space.config.HandlerConstant;
import com.tenth.space.imservice.event.GroupEvent;
import com.tenth.space.imservice.event.PriorityEvent;
import com.tenth.space.imservice.event.UserInfoEvent;
import com.tenth.space.imservice.support.IMServiceConnector;
import com.tenth.space.imservice.manager.IMContactManager;
import com.tenth.space.imservice.service.IMService;
import com.tenth.space.protobuf.IMBaseDefine;
import com.tenth.space.protobuf.IMBuddy;
import com.tenth.space.ui.activity.MainActivity;
import com.tenth.space.ui.activity.NewFriendsActivity;
import com.tenth.space.ui.adapter.ContactAdapter;
import com.tenth.space.ui.adapter.DeptAdapter;
import com.tenth.space.ui.widget.SortSideBar;
import com.tenth.space.ui.widget.SortSideBar.OnTouchingLetterChangedListener;
import com.tenth.space.utils.pinyin.PinYin;
import com.nostra13.universalimageloader.core.ImageLoader;
import com.nostra13.universalimageloader.core.listener.PauseOnScrollListener;

import org.json.JSONException;
import org.json.JSONObject;

import java.util.Iterator;
import java.util.List;
import de.greenrobot.event.EventBus;

/**
 * 通讯录 （全部、部门）
 */
public class ContactsFragment extends MainFragment implements OnTouchingLetterChangedListener{
    private View curView = null;
    private static Handler uiHandler = null;
    private ListView allContactListView;
    private ListView departmentContactListView;
    private SortSideBar sortSideBar;
    private TextView dialog;

    private ContactAdapter contactAdapter;
    private DeptAdapter departmentAdapter;

    private IMService imService;
    private IMContactManager contactMgr;
    private int curTabIndex = 0;
    @SuppressLint("ValidFragment")
    public ContactsFragment(int unreadAddCnt){
        this.unreadAddCnt = unreadAddCnt;
    }

    public ContactsFragment(){

    }
    private IMServiceConnector imServiceConnector = new IMServiceConnector() {
        @Override
        public void onIMServiceConnected() {
            imService = imServiceConnector.getIMService();
            if (imService == null) {
                logger.e("ContactFragment#onIMServiceConnected# imservice is null!!");
                return;
            }
            contactMgr = imService.getContactManager();

            // 初始化视图
            initAdapter();
            renderEntityList();
            EventBus.getDefault().registerSticky(ContactsFragment.this);
        }

        @Override
        public void onServiceDisconnected() {
            if (EventBus.getDefault().isRegistered(ContactsFragment.this)) {
                EventBus.getDefault().unregister(ContactsFragment.this);
            }
        }
    };
//    private Button add;
    private TextView count_notify;
//    private RequesterEntity requesterEntity;
    private View newFriendsView;
    private ImageView avator;
    private TextView Nick_Name;
    private TextView Addition_Msg;
    private int unreadAddCnt;
    private TextView text_new_friend;


    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        imServiceConnector.connect(getActivity());
        initHandler();
        //查找最后一条好友请求
//        requesterEntity =DBInterface.instance().getReqestLastTime();
    }
    public void onDestroy() {
        super.onDestroy();
        if (EventBus.getDefault().isRegistered(this)) {
            EventBus.getDefault().unregister(this);
        }
        imServiceConnector.disconnect(getActivity());
    }
    @SuppressLint("HandlerLeak")
    @Override
    protected void initHandler() {
        uiHandler = new Handler() {
            @Override
            public void handleMessage(Message msg) {
                super.handleMessage(msg);
                switch (msg.what) {
                    case HandlerConstant.HANDLER_CHANGE_CONTACT_TAB:
                        if (null != msg.obj) {
                            curTabIndex = (Integer) msg.obj;
                            if (0 == curTabIndex) {
                                allContactListView.setVisibility(View.VISIBLE);
                                departmentContactListView.setVisibility(View.GONE);
                            } else {
                                departmentContactListView.setVisibility(View.VISIBLE);
                                allContactListView.setVisibility(View.GONE);
                            }
                        }
                        break;
                }
            }
        };
    }

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container,
                             Bundle savedInstanceState) {

        if (null != curView) {
            ((ViewGroup) curView.getParent()).removeView(curView);
            return curView;
        }
        curView = inflater.inflate(R.layout.fragments_contact, topContentView);
        initRes();
        return curView;
    }

    /**
     * @Description 初始化界面资源
     */
    private void initRes() {
        // 设置顶部标题栏
        setTopTitle(getActivity().getString(R.string.contact_title));
        showContactTopBar();

        hideTopBar();

        super.init(curView);
        showProgressBar();

        count_notify = (TextView) curView.findViewById(R.id.message_count_notify);
        avator = (ImageView) curView.findViewById(R.id.contact_portrait);
        Nick_Name = (TextView) curView.findViewById(R.id.shop_name);
        Addition_Msg=(TextView)curView.findViewById(R.id.message_body);
        text_new_friend=(TextView)curView.findViewById(R.id.text_new_friend);

        sortSideBar = (SortSideBar) curView.findViewById(R.id.sidrbar);
        dialog = (TextView) curView.findViewById(R.id.dialog);
        sortSideBar.setTextView(dialog);
        sortSideBar.setOnTouchingLetterChangedListener(this);

        allContactListView = (ListView) curView.findViewById(R.id.all_contact_list);
        departmentContactListView = (ListView) curView.findViewById(R.id.department_contact_list);

        //this is critical, disable loading when finger sliding, otherwise you'll find sliding is not very smooth
        allContactListView.setOnScrollListener(new PauseOnScrollListener(ImageLoader.getInstance(), true, true));
        departmentContactListView.setOnScrollListener(new PauseOnScrollListener(ImageLoader.getInstance(), true, true));
        // todo eric
        // showLoadingProgressBar(true);
        newFriendsView = curView.findViewById(R.id.new_friends);
        newFriendsView.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                count_notify.setText("");
                count_notify.setVisibility(View.GONE);
                ((MainActivity) getActivity()).setNewContact(0);
                Intent intent = new Intent(getActivity(), NewFriendsActivity.class);
                intent.putExtra("unreadcnt",unreadAddCnt);
                startActivityForResult(intent,200);
                unreadAddCnt=0;
            }
        });
//        if(requesterEntity==null){
           count_notify.setVisibility(View.GONE);
           avator.setImageResource(R.drawable.icon_head);
            Nick_Name.setVisibility(View.GONE);
            Addition_Msg.setVisibility(View.GONE);
            text_new_friend.setVisibility(View.VISIBLE);
//        }else if(requesterEntity.getIsRead()) {
//            count_notify.setVisibility(View.GONE);
//            avator.setImageResource(R.drawable.icon_head);
//            Nick_Name.setVisibility(View.GONE);
//            Addition_Msg.setVisibility(View.GONE);
//            text_new_friend.setVisibility(View.VISIBLE);
//        }else {
//            Nick_Name.setText(requesterEntity.getNick_name());
//            Addition_Msg.setText(requesterEntity.getAddition_msg());
//            text_new_friend.setVisibility(View.GONE);
//            ImageLoader.getInstance().displayImage(requesterEntity.getAvatar_url(),avator,ImageLoaderUtil.getAvatarOptions(0,0));
//        }
    }

    @Override
    public void onActivityResult(int requestCode, int resultCode, Intent data) {
        super.onActivityResult(requestCode, resultCode, data);
        if(resultCode==201){
            RequesterEntity entity= (RequesterEntity) data.getSerializableExtra("entity");
            UserEntity userEntity =new UserEntity();
            userEntity.setId((long) entity.getFromUserId());
            userEntity.setMainName(entity.getNick_name());
            userEntity.setAvatar(entity.getAvatar_url());
            userEntity.setPeerId(entity.getFromUserId());
            userEntity.setRelation(IMBaseDefine.UserRelationType.RELATION_FRIEND.name());
            contactMgr.addFriend(userEntity);
            PinYin.getPinYin(userEntity.getMainName(),userEntity.getPinyinElement());
            renderUserList();
            contactAdapter.notifyDataSetChanged();
            count_notify.setVisibility(View.GONE);
            avator.setImageResource(R.drawable.icon_head);
            Nick_Name.setVisibility(View.GONE);
            Addition_Msg.setVisibility(View.GONE);
            text_new_friend.setVisibility(View.VISIBLE);
        }
    }

    private void initAdapter() {
        contactAdapter = new ContactAdapter(getActivity(), imService);
        departmentAdapter = new DeptAdapter(getActivity(), imService);
        allContactListView.setAdapter(contactAdapter);
        departmentContactListView.setAdapter(departmentAdapter);

        // 单击视图事件
        allContactListView.setOnItemClickListener(contactAdapter);
        allContactListView.setOnItemLongClickListener(contactAdapter);

        departmentContactListView.setOnItemClickListener(departmentAdapter);
        departmentContactListView.setOnItemLongClickListener(departmentAdapter);
    }

    public void locateDepartment(int departmentId) {
        logger.i("department#locateDepartment id:%s", departmentId);

        if (topContactTitle == null) {
            logger.e("department#TopTabButton is null");
            return;
        }
        Button tabDepartmentBtn = topContactTitle.getTabDepartmentBtn();
        if (tabDepartmentBtn == null) {
            return;
        }
        tabDepartmentBtn.performClick();
        locateDepartmentImpl(departmentId);
    }

    private void locateDepartmentImpl(int departmentId) {
        if (imService == null) {
            return;
        }
        DepartmentEntity department = imService.getContactManager().findDepartment(departmentId);
        if (department == null) {
            logger.e("department#no such id:%s", departmentId);
            return;
        }

        logger.i("department#go to locate department:%s", department);
        final int position = departmentAdapter.locateDepartment(department.getDepartName());
        logger.i("department#located position:%d", position);

        if (position < 0) {
            logger.i("department#locateDepartment id:%s failed", departmentId);
            return;
        }
        //the first time locate works
        //from the second time, the locating operations fail ever since
        departmentContactListView.post(new Runnable() {

            @Override
            public void run() {
                departmentContactListView.setSelection(position);
            }
        });
    }


    /**
     * 刷新单个entity
     * 很消耗性能
     */
    private void renderEntityList() {
        hideProgressBar();
        logger.i("contact#renderEntityList");

        if (contactMgr.isUserDataReady()) {
            renderUserList();
            //没有部门了
            //renderDeptList();
        }
        if (imService.getGroupManager().isGroupReady()) {
            renderGroupList();
        }
        showSearchFrameLayout();
    }


    private void renderDeptList() {
        //neil
        /**---------------------部门数据的渲染------------------------------------------*/
        List<UserEntity> departmentList = contactMgr.getDepartmentTabSortedList();
        departmentAdapter.putUserList(departmentList);
    }

    private void renderUserList() {
        List<UserEntity> contactList = contactMgr.getContactSortedList();
        for (Iterator<UserEntity> userEntitys = contactList.iterator(); userEntitys.hasNext();) {
            UserEntity userEntity = userEntitys.next();
            if (!userEntity.getRelation().equals(IMBaseDefine.UserRelationType.RELATION_FRIEND.name())) {
                userEntitys.remove();
            }
        }
        // 没有任何的联系人数据
        if (contactList.size() <= 0) {
            return;
        }
        contactAdapter.putUserList(contactList);
    }

    private void renderGroupList() {
        logger.i("group#onGroupReady");
        List<GroupEntity> originList = imService.getGroupManager().getNormalGroupSortedList();
        if (originList.size() <= 0) {
            return;
        }
        contactAdapter.putGroupList(originList);
    }

    private ListView getCurListView() {
        if (0 == curTabIndex) {
            return allContactListView;
        } else {
            return departmentContactListView;
        }
    }

    @Override
    public void onTouchingLetterChanged(String s) {
        int position = -1;
        if (0 == curTabIndex) {
            position = contactAdapter.getPositionForSection(s.charAt(0));
        } else {
            position = departmentAdapter.getPositionForSection(s.charAt(0));
        }
        if (position != -1) {
            getCurListView().setSelection(position);
        }
    }

    public static Handler getHandler() {
        return uiHandler;
    }

    @Override
    public void onActivityCreated(Bundle savedInstanceState) {
        super.onActivityCreated(savedInstanceState);
    }

    public void onEventMainThread(GroupEvent event) {
        switch (event.getEvent()) {
            case GROUP_INFO_UPDATED:
            case GROUP_INFO_OK:
                renderGroupList();
                searchDataReady();
                break;
        }
    }
    public void onEventMainThread(PriorityEvent event) {
        switch (event.event) {
            case MSG_SYSTEM:
                try {
                    IMBuddy.IMAddFriendData obj1 = (IMBuddy.IMAddFriendData) event.object;
                    switch (obj1.getType()){
                        case ADD_FRIEND_REQUEST:
                            final int fromUserId=obj1.getUserId();
                            String date = obj1.getAddFriendData().toStringUtf8();
                            final JSONObject  object = new JSONObject(date);
                            //保存到本地数据库
                            RequesterEntity requesterEntity= new RequesterEntity();
                            requesterEntity.setFromUserId(fromUserId);
                            requesterEntity.setAddition_msg(object.optString("addition_msg"));
                            requesterEntity.setAvatar_url(object.optString("avatar_url"));
                            requesterEntity.setNick_name(object.optString("nick_name"));
                            requesterEntity.setCreated(System.currentTimeMillis());
                            requesterEntity.setIsRead(false);
                            requesterEntity.setAgree_states(1);
                            DBInterface.instance().batchInsertOrUpdateRquest(requesterEntity);
//                            Nick_Name.setText(requesterEntity.getNick_name());
//                            Addition_Msg.setText(requesterEntity.getAddition_msg());
//                            ImageLoader.getInstance().displayImage(requesterEntity.getAvatar_url(),avator,ImageLoaderUtil.getAvatarOptions(0,0));
                            String text = count_notify.getText().toString();

                            if("".equals(text)){
                              text="0";
                            }
                            int total = Integer.parseInt(text) + 1;
                            count_notify.setText(total+"");
                            if( count_notify.getVisibility()==View.GONE){
                                count_notify.setVisibility(View.VISIBLE);
                            }
                            //通知服务器已读添加好友请求
//                            FriendManager.instance().readAddFriendDate(obj1.getUserId());

                            break;
//                        case ADD_FRIEND_DISAGREE:
//
//                            break;
                        case ADD_FRIEND_AGREE:
                            String addFriendData = obj1.getAddFriendData().toStringUtf8();
                            JSONObject addFriendObj = new JSONObject(addFriendData);
                            UserEntity userEntity=new UserEntity();
                            userEntity.setMainName(addFriendObj.optString("nick_name"));
                            userEntity.setRealName(addFriendObj.optString("nick_name"));
                            userEntity.setId((long) obj1.getUserId());
                            userEntity.setPeerId(obj1.getUserId());
                            userEntity.setAvatar(addFriendObj.optString("avatar_url"));
                            userEntity.setRelation(IMBaseDefine.UserRelationType.RELATION_FRIEND.name());
//                          contactAdapter.addFriend(userEntity);
                            contactMgr.addFriend(userEntity);
                            PinYin.getPinYin(userEntity.getMainName(),userEntity.getPinyinElement());
                            renderUserList();
                            contactAdapter.notifyDataSetChanged();
                            String cnt = count_notify.getText().toString();
                            if("".equals(cnt)){
                                cnt="0";
                            }
                            int CNT = Integer.parseInt(cnt) + 1;
                            count_notify.setText(CNT+"");
                            if( count_notify.getVisibility()==View.GONE){
                                count_notify.setVisibility(View.VISIBLE);
                            }
                            break;
                    }
                } catch (JSONException e) {
                    e.printStackTrace();
                }
                break;
            case MSG_ADD_AGREE_FRIEND_RSP:
                IMBuddy.IMAgreeAddFriendRsp obj = (IMBuddy.IMAgreeAddFriendRsp) event.object;
                IMBaseDefine.SystemMsgType agree = obj.getAgree();
                int resultCode = obj.getResultCode();
                if(resultCode==0){
                    if(IMBaseDefine.SystemMsgType.ADD_FRIEND_AGREE.equals(agree)) {
                        Toast.makeText(getActivity(), "已通知对方同意添加好友", Toast.LENGTH_LONG).show();
                    }
                }else {
                    Toast.makeText(getActivity(),resultCode+"",Toast.LENGTH_LONG).show();
                }
                break;
            case MSG_AGREE_OR_DISGREE_ADD_FRIEND_RSP:
//                JSONObject addFriendObj = (JSONObject) event.object;
//                String addition_msg = addFriendObj.optString("addition_msg");
//                if("同意加为好友".equals(addition_msg)){
//                    UserEntity userEntity=new UserEntity();
//                    userEntity.setMainName(addFriendObj.optString("nick_name"));
//                    userEntity.setId(addFriendObj.optLong("fromUserId"));
//                    userEntity.setAvatar(addFriendObj.optString("avatar_url"));
//                    contactAdapter.addFriend(userEntity);
                    UserEntity userEntity=(UserEntity) event.object;
                    contactMgr.addFriend(userEntity);
                    PinYin.getPinYin(userEntity.getMainName(),userEntity.getPinyinElement());
                    renderUserList();
                    contactAdapter.notifyDataSetChanged();
//                }
                break;
            case MSG_DEL_FRIEND_RSP:
                IMBuddy.IMDelFriendRsp delRsp = (IMBuddy.IMDelFriendRsp) event.object;
                int delResult = delRsp.getResultCode();
                int friendId = delRsp.getFriendId();
                if(delResult==0){
                    List<UserEntity> userList = contactAdapter.getUserList();
                    for(UserEntity entity:userList){
                        if (entity.getPeerId()==friendId){
                            userList.remove(entity);
                            contactAdapter.notifyDataSetChanged();
                            DBInterface dbInterface=DBInterface.instance();
                            dbInterface.deleteUserEntity(entity);
                        }
                    }

                }
                break;
            case MSG_UNREAD_CNT_ADD_RSP:
                //未读请求数
                IMBuddy.IMAddFriendUnreadCntRsp cntObj=(IMBuddy.IMAddFriendUnreadCntRsp)event.object;
                int unreadCnt = cntObj.getUnreadCnt();
                if(unreadCnt>0){
                    ((MainActivity) getActivity()).setNewContact(unreadCnt);
                    count_notify.setVisibility(View.VISIBLE);
                    count_notify.setText(unreadCnt+"");
                    unreadAddCnt=unreadCnt;
                }
                break;
            case MSG_ADD_FRIEND_RSP:
                IMBuddy.IMAddFriendRsp imAddFriendRsp = (IMBuddy.IMAddFriendRsp)event.object;
                int addCode = imAddFriendRsp.getResultCode();
                if(addCode==0){
                    Toast.makeText(getActivity(),"消息已发送成功，等待对方确认",Toast.LENGTH_LONG).show();
                }
                break;
        }
    }
//    private void readAddFriendDate(int Id){
//        IMBuddy.IMAddFriendReadDataAck msg = IMBuddy.IMAddFriendReadDataAck.newBuilder().setUserId(Id).build();
//        int sid = IMBaseDefine.ServiceID.SID_BUDDY_LIST_VALUE;
//        int cid = IMBaseDefine.BuddyListCmdID.CID_BUDDY_LIST_ADD_FRIEND_READ_DATA_ACK_VALUE;
//        IMSocketManager.instance().sendRequest(msg, sid, cid);
//    }
    public void onEventMainThread(UserInfoEvent event) {
        switch (event.event) {
            case USER_INFO_UPDATE:
            case USER_INFO_OK:
//              renderDeptList();
                renderUserList();
                searchDataReady();
                break;
        }
    }

    public void searchDataReady() {
        if (imService.getContactManager().isUserDataReady() &&
                imService.getGroupManager().isGroupReady()) {
            showSearchFrameLayout();
        }
    }

//    @Override
//    public void onClick(View v) {
//        switch (v.getId()){
//            case R.id.add_friends:
//                Intent intent =new Intent(getActivity(),FriendsActivity.class);
//                startActivity(intent);
//                break;
//        }
//
//    }
}
