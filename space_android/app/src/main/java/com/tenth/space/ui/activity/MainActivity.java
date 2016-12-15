package com.tenth.space.ui.activity;

import android.content.Intent;
import android.os.Bundle;
import android.support.v4.app.Fragment;
import android.support.v4.app.FragmentActivity;
import android.view.Window;

import com.tenth.space.R;
import com.tenth.space.config.IntentConstant;
import com.tenth.space.imservice.event.LoginEvent;
import com.tenth.space.imservice.event.UnreadEvent;
import com.tenth.space.imservice.service.IMService;
import com.tenth.space.imservice.support.IMServiceConnector;
import com.tenth.space.ui.fragment.ChatFragment;
import com.tenth.space.ui.fragment.ContactsFragment;
import com.tenth.space.ui.fragment.HomeFragment;
import com.tenth.space.ui.widget.NaviTabButton;
import com.tenth.space.utils.Logger;

import de.greenrobot.event.EventBus;



public class MainActivity extends FragmentActivity {
    private Fragment[] mFragments;
    private NaviTabButton[] mTabButtons;
    private Logger logger = Logger.getLogger(MainActivity.class);
    private IMService imService;
    private int lastWitch=0;
    private IMServiceConnector imServiceConnector = new IMServiceConnector() {
        @Override
        public void onIMServiceConnected() {
            imService = imServiceConnector.getIMService();
        }

        @Override
        public void onServiceDisconnected() {
        }
    };

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        logger.i("MainActivity#savedInstanceState:%s", savedInstanceState);
        //todo eric when crash, this will be called, why?
        if (savedInstanceState != null) {
            logger.w("MainActivity#crashed and restarted, just exit");
            jumpToLoginPage();
            finish();
        }

        // 在这个地方加可能会有问题吧
        EventBus.getDefault().register(this);
        imServiceConnector.connect(this);

        requestWindowFeature(Window.FEATURE_NO_TITLE);
        setContentView(R.layout.tt_activity_main);

        initTab();
        initFragment();
        setFragmentIndicator(0);
    }

    @Override
    public void onBackPressed() {
        //don't let it exit
        //super.onBackPressed();

        //nonRoot	If false then this only works if the activity is the root of a task; if true it will work for any activity in a task.
        //document http://developer.android.com/reference/android/app/Activity.html

        //moveTaskToBack(true);

        Intent intent = new Intent(Intent.ACTION_MAIN);
        intent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
        intent.addCategory(Intent.CATEGORY_HOME);
        startActivity(intent);

    }


    private void initFragment() {
        mFragments = new Fragment[5];
        mFragments[0] = getSupportFragmentManager().findFragmentById(R.id.fragment_home);
        mFragments[1] = getSupportFragmentManager().findFragmentById(R.id.fragment_chat);
        mFragments[2] = getSupportFragmentManager().findFragmentById(R.id.fragment_contact);
        mFragments[3] = getSupportFragmentManager().findFragmentById(R.id.fragment_blog);
        mFragments[4] = getSupportFragmentManager().findFragmentById(R.id.fragment_my);
    }

    private void initTab() {
        mTabButtons = new NaviTabButton[5];

        mTabButtons[0] = (NaviTabButton) findViewById(R.id.tabbutton_home);
        mTabButtons[1] = (NaviTabButton) findViewById(R.id.tabbutton_chat);
        mTabButtons[2] = (NaviTabButton) findViewById(R.id.tabbutton_contact);
        mTabButtons[3] = (NaviTabButton) findViewById(R.id.tabbutton_internal);
        mTabButtons[4] = (NaviTabButton) findViewById(R.id.tabbutton_my);

        mTabButtons[0].setTitle(getString(R.string.main_home));
        mTabButtons[0].setIndex(0);
        mTabButtons[0].setSelectedImage(getResources().getDrawable(R.drawable.tt_tab_first_sel));
        mTabButtons[0].setUnselectedImage(getResources().getDrawable(R.drawable.tt_tab_first_nor));

        mTabButtons[1].setTitle(getString(R.string.main_chat));
        mTabButtons[1].setIndex(1);
        mTabButtons[1].setSelectedImage(getResources().getDrawable(R.drawable.tt_tab_chat_sel));
        mTabButtons[1].setUnselectedImage(getResources().getDrawable(R.drawable.tt_tab_chat_nor));

        mTabButtons[2].setTitle(getString(R.string.main_contact));
        mTabButtons[2].setIndex(2);
        mTabButtons[2].setSelectedImage(getResources().getDrawable(R.drawable.tt_tab_contact_sel));
        mTabButtons[2].setUnselectedImage(getResources().getDrawable(R.drawable.tt_tab_contact_nor));

        mTabButtons[3].setTitle(getString(R.string.main_innernet));
        mTabButtons[3].setIndex(3);
        mTabButtons[3].setSelectedImage(getResources().getDrawable(R.drawable.tt_tab_blog_select));
        mTabButtons[3].setUnselectedImage(getResources().getDrawable(R.drawable.tt_tab_blog_nor));

        mTabButtons[4].setTitle(getString(R.string.main_me_tab));
        mTabButtons[4].setIndex(4);
        mTabButtons[4].setSelectedImage(getResources().getDrawable(R.drawable.tt_tab_me_sel));
        mTabButtons[4].setUnselectedImage(getResources().getDrawable(R.drawable.tt_tab_me_nor));
    }

    public void setFragmentIndicator(int which) {
        //此处是开启与关闭定时器，开启关闭摄像头
        HomeFragment currentFramgent = (HomeFragment)mFragments[0];
        if (which==0){
            if (lastWitch!=0){
                currentFramgent.doOpenCamare();
                //currentFramgent.customadapter.startTimer();
            }
        }else {
            currentFramgent.doCloseCamare();
           // currentFramgent.customadapter.stopTimer();
        }
        getSupportFragmentManager().beginTransaction().hide(mFragments[0]).hide(mFragments[1]).hide(mFragments[2]).hide(mFragments[3]).hide(mFragments[4]).show(mFragments[which]).commit();
        mTabButtons[0].setSelectedButton(false);
        mTabButtons[1].setSelectedButton(false);
        mTabButtons[2].setSelectedButton(false);
        mTabButtons[3].setSelectedButton(false);
        mTabButtons[4].setSelectedButton(false);

        mTabButtons[which].setSelectedButton(true);
        lastWitch=which;
    }

    public void setUnreadMessageCnt(int unreadCnt) {
        mTabButtons[1].setUnreadNotify(unreadCnt);
    }
    public void setNewContact(int total) {
        mTabButtons[2].setUnreadNotify(total);
    }
    public int getLocalUreadCnt(){
      return mTabButtons[2].getLocalUnreadCnt();
    }


    /**
     * 双击事件
     */
    public void chatDoubleListener() {
        setFragmentIndicator(1);
        ((ChatFragment) mFragments[1]).scrollToUnreadPosition();
    }

    @Override
    protected void onNewIntent(Intent intent) {
        super.onNewIntent(intent);
        handleLocateDepratment(intent);
    }


    @Override
    protected void onResume() {
        super.onResume();
    }

    private void handleLocateDepratment(Intent intent) {
        int departmentIdToLocate = intent.getIntExtra(IntentConstant.KEY_LOCATE_DEPARTMENT, -1);
        if (departmentIdToLocate == -1) {
            return;
        }

        logger.i("department#got department to locate id:%d", departmentIdToLocate);
        setFragmentIndicator(2);
        ContactsFragment fragment = (ContactsFragment) mFragments[2];
        if (fragment == null) {
            logger.e("department#fragment is null");
            return;
        }
        fragment.locateDepartment(departmentIdToLocate);
    }

    @Override
    protected void onPause() {
        super.onPause();
    }

    @Override
    protected void onDestroy() {
        logger.i("mainactivity#onDestroy");
        EventBus.getDefault().unregister(this);
        imServiceConnector.disconnect(this);
        super.onDestroy();
    }


    public void onEventMainThread(UnreadEvent event) {
        switch (event.event) {
            case SESSION_READED_UNREAD_MSG:
            case UNREAD_MSG_LIST_OK:
            case UNREAD_MSG_RECEIVED:
                showUnreadMessageCount();
                break;
        }
    }

    private void showUnreadMessageCount() {
        //todo eric when to
        if (imService != null) {
            int unreadNum = imService.getUnReadMsgManager().getTotalUnreadCount();
            mTabButtons[1].setUnreadNotify(unreadNum);
        }

    }

    public void onEventMainThread(LoginEvent event) {
        switch (event) {
            case LOGIN_OUT:
                handleOnLogout();
                break;
        }
    }

    private void handleOnLogout() {
        logger.i("mainactivity#login#handleOnLogout");
        finish();
        logger.i("mainactivity#login#kill self, and start login activity");
        jumpToLoginPage();

    }

    private void jumpToLoginPage() {
        Intent intent = new Intent(this, LoginActivity.class);
        intent.putExtra(IntentConstant.KEY_LOGIN_NOT_AUTO, true);
        startActivity(intent);
    }
}
