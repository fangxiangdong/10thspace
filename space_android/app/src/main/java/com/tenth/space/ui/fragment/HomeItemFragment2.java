package com.tenth.space.ui.fragment;

import android.annotation.SuppressLint;
import android.os.Bundle;
import android.os.Handler;
import android.os.Message;
import android.support.annotation.NonNull;
import android.support.annotation.Nullable;
import android.support.v4.app.Fragment;
import android.support.v4.view.PagerAdapter;
import android.support.v4.view.ViewPager;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.AbsListView;
import android.widget.AdapterView;
import android.widget.Button;
import android.widget.FrameLayout;
import android.widget.GridView;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.TextView;

import com.tenth.space.DB.DBInterface;
import com.tenth.space.DB.entity.UserEntity;
import com.tenth.space.R;
import com.tenth.space.aliyun.Config;
import com.tenth.space.app.IMApplication;
import com.tenth.space.imservice.event.CountEvent;
import com.tenth.space.imservice.manager.IMLoginManager;
import com.tenth.space.imservice.manager.IMonLineCountManager;
import com.tenth.space.protobuf.IMBaseDefine;
import com.tenth.space.ui.adapter.CustomPrePagerAdapter;
import com.tenth.space.ui.adapter.GrideViewAdapter;
import com.tenth.space.ui.adapter.ViewPageAdapter;
import com.tenth.space.ui.adapter.album.OnItemClickListener;
import com.tenth.space.utils.IMUIHelper;
import com.tenth.space.utils.NetworkUtil;
import com.tenth.space.utils.Utils;

import java.net.HttpURLConnection;
import java.net.URL;
import java.util.ArrayList;
import java.util.List;
import java.util.Timer;
import java.util.TimerTask;

import de.greenrobot.event.EventBus;


/**
 * Created by Administrator on 2016/11/15.
 */

public class HomeItemFragment2 extends Fragment implements AdapterView.OnItemClickListener  {
    public int globlePosition=0;
    private  IMBaseDefine.UserRelationType state;
    private  HomeFragment frgemntparents;
    private View view;
    private final int UpDateDB=1;
    private  final int UpDateTime=0;
    private  final int UpDateMySelfOpen=2;
    private  final int BINEARTIEMR=3;
    public TextView tv_total_count;
    ArrayList<UserEntity> pictureList=new ArrayList<>();
    private GridView gv;
    private GrideViewAdapter adapter;
    private LinearLayout ll_progress_bar;
    private ViewPager binear_vp;
    private Timer timer;
    private CustomTimerTask timetask;
    public Handler handler=new Handler(){
        @Override
        public void handleMessage(Message msg) {
            super.handleMessage(msg);
            switch (msg.what){
                case UpDateTime:
                    //adapter更新数据
                    ll_progress_bar.setVisibility(View.GONE);
                    pictureList = (ArrayList<UserEntity>) msg.obj;
                    initRecycleView(pictureList);
                    break;
                case UpDateDB:
                    //查询网络，查询数据库
                    queryDB(state);
                    //当前在线好友数量
                    IMonLineCountManager.instance().getONlineCount(IMLoginManager.instance().getLoginId());
                    break;
                case UpDateMySelfOpen:
                    if (frgemntparents.cusbitmap!=null){
                        adapter.notifyDataSetChanged();
                    }else {
                        sendEmptyMessage(UpDateMySelfOpen);
                    }
                    break;
                case BINEARTIEMR:
                    //循环更新轮播
                    globlePosition++;
                    if (binearUrls.size()==globlePosition){
                        globlePosition=0;
                        binear_vp.setCurrentItem(globlePosition,false);
                    }else {
                        binear_vp.setCurrentItem(globlePosition,true);
                    }

                    this.sendEmptyMessageDelayed(BINEARTIEMR,2000);
                    break;
            }
        }
    };
    private LinearLayout ll_binear;
    private int lastPosition;
    private FrameLayout framelayout;
    public static boolean isFling=true;//采用那种方式加载图片（需要加载中图片，取消加载中图片）


    @Override
    public void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        EventBus.getDefault().registerSticky(this);

    }

    public void onEventMainThread(CountEvent event){
        switch (state){
            case RELATION_RECOMMEND:
                int counts = event.getCount();
                if (tv_total_count!=null){
                    tv_total_count.setText(getString(R.string.online_friends_count)+counts+"");
                }
                break;
            case RELATION_FRIEND:
                if (tv_total_count!=null&&pictureList.size()>0){
                    tv_total_count.setText(getString(R.string.online_friends_count)+(pictureList.size()-1)+"");
                }

                break;
            case RELATION_FOLLOW:
                if (tv_total_count!=null&&pictureList.size()>0){
                    tv_total_count.setText(getString(R.string.online_friends_count)+(pictureList.size()-1)+"");
                }
                break;
        }


    }

    @Nullable
    @Override
    public View onCreateView(LayoutInflater inflater, @Nullable ViewGroup container, @Nullable Bundle savedInstanceState) {
        view=inflater.inflate(R.layout.item_home_fragment_layout_2,container,false);
        gv=(GridView)view.findViewById(R.id.gv);
        tv_total_count=(TextView)view.findViewById(R.id.tv_total_count);
        ll_progress_bar=(LinearLayout)view.findViewById(R.id.ll_progress_bar);
        binear_vp=(ViewPager)view.findViewById(R.id.binear_vp);
        ll_binear=(LinearLayout)view.findViewById(R.id.ll_binear);
        framelayout=(FrameLayout)view.findViewById(R.id.framelayout);
        ll_progress_bar.setVisibility(View.VISIBLE);
        //判断网络是否正常
        if (!NetworkUtil.isNetWorkAvalible(getActivity())){
            ll_progress_bar.setVisibility(View.GONE);
        }
        //推荐页面添加广告binear
        if (state==IMBaseDefine.UserRelationType.RELATION_RECOMMEND){
            framelayout.setVisibility(View.VISIBLE);
            initBinear(binear_vp);
        }

        //添加第一张自己的图片占位用的
       pictureList.add(0,new UserEntity(Long.valueOf( IMLoginManager.instance().getLoginId())));
        handler.sendEmptyMessage(UpDateDB);
        return view;
    }
public ArrayList<String> binearUrls;
    private void initBinear(ViewPager binear_vp) {
        //加载广告循环页面http://img1.imgtn.bdimg.com/it/u=2710984090,618232935&fm=15&gp=0.jpg
        String url="http://img1.imgtn.bdimg.com/it/u=2710984090,618232935&fm=15&gp=0.jpg";
         binearUrls=new ArrayList<>();
        binearUrls.add(url);
        binearUrls.add(url);
        binearUrls.add(url);
        binearUrls.add(url);
        for (int i=0;i<binearUrls.size();i++){
            Button button=new Button(getActivity());
            if (i==0){
                button.setEnabled(true);
            }else {
                button.setEnabled(false);
            }
            button.setBackgroundDrawable(getResources().getDrawable(R.drawable.selector_binear));
            LinearLayout.LayoutParams layoutParams = new LinearLayout.LayoutParams(LinearLayout.LayoutParams.MATCH_PARENT, LinearLayout.LayoutParams.MATCH_PARENT);
            layoutParams.width=10;
            layoutParams.height=10;
            layoutParams.leftMargin=20;
            button.setLayoutParams(layoutParams);
            ll_binear.addView(button);
        }
        CustomPrePagerAdapter adapters = new CustomPrePagerAdapter(getActivity(), binearUrls);
        binear_vp.setAdapter(adapters);
        adapters.setOnItemClickListener(new OnItemClickListener() {
            @Override
            public void onItemClick(ImageView imageView, int position) {
                //广告点击事件
            }
        });
        binear_vp.addOnPageChangeListener(new ViewPager.OnPageChangeListener() {
            @Override
            public void onPageScrolled(int position, float positionOffset, int positionOffsetPixels) {

            }

            @Override
            public void onPageSelected(int position) {
                globlePosition=position;
                //上一个button置为不可用
                Button lastButton = (Button) ll_binear.getChildAt(lastPosition);
                lastButton.setEnabled(false);
                //下一个为选中状态
                Button currentButton = (Button) ll_binear.getChildAt(position);
                currentButton.setEnabled(true);
                lastPosition=position;
            }

            @Override
            public void onPageScrollStateChanged(int state) {

            }
        });
        //设置定时器，定时自动滚动viewpager
        handler.sendEmptyMessageDelayed(BINEARTIEMR,2000);
        //binear_vp.setCurrentItem(0,false);

    }

    public HomeItemFragment2(){

    }
    @SuppressLint("ValidFragment")
    public HomeItemFragment2(IMBaseDefine.UserRelationType state, HomeFragment frgemntparents){
        this.state=state;
        this.frgemntparents=frgemntparents;
    }

    private void queryDB(final IMBaseDefine.UserRelationType state) {
                //查询好友数据库，返回集合列表，查询完成后，更新adapter,显示在线好友数量
                IMApplication.app.getThreadPool().execute(new Runnable() {
                    @Override
                    public void run() {
                        //查询数据库
                       // pictureList.clear();//添加自己的头像
                       // pictureList.add(0,new UserEntity(Long.valueOf( IMLoginManager.instance().getLoginId())));//按照构造方法中状态查询数据库
                        List<UserEntity> DBfriendsList=DBInterface.instance().LoadUserFromType(state);
                        if (DBfriendsList==null){
                            return;
                        }
                        //遍历请求网路，是否有图片
                        for (UserEntity entity:DBfriendsList){
                        if (entity.getPeerId()!=IMLoginManager.instance().getLoginId()){//过滤数据库中自己的头像
                            try {
                                //判断阿里云是否有图片，即好友是否在线
                                boolean  isAlyunExist=IMApplication.app.GetGlobleOSSClent().doesObjectExist(Config.privateBucketName, Config.livePicsPath+entity.getPeerId()+Utils.PNG);
                                //思考：需不需要，本地pictureList有图片就不管他，没有就添加
                               boolean isExist = checkList(entity.getPeerId(), pictureList);
                                if (isAlyunExist){
                                    //标示有网络图片,
                                    if (!isExist){
                                        pictureList.add(entity);//ok
                                    }
                                }else {
                                    if (isExist){
                                        pictureList.remove(entity);//待测
                                    }
                                }
                            } catch (Exception e) {
                                e.printStackTrace();
                                continue;

                            }
                        }
                            }
                        Message customMessage = handler.obtainMessage();
                        customMessage.what=UpDateTime;
                        customMessage.obj=pictureList;
                        handler.sendMessage(customMessage);
                    }
                });
    }

    private boolean checkList(int peerId, ArrayList<UserEntity> pictureList) {
        for (int i=0;i<pictureList.size();i++){
            int id=pictureList.get(i).getPeerId();
            if (id == peerId) {
                return true;
            }
        }
        return false;
    }

    private void initRecycleView(ArrayList<UserEntity> pictureList) {
        if (adapter==null){
            adapter=new GrideViewAdapter(getActivity(),pictureList,frgemntparents,gv);
            gv.setAdapter(adapter);
            gv.setOnItemClickListener(this);
            gv.setOnScrollListener(new AbsListView.OnScrollListener() {
                @Override
                public void onScrollStateChanged(AbsListView view, int scrollState) {
                    //在滑动过程中添加加载中图片
                    switch (scrollState){
                        case SCROLL_STATE_FLING:
                        case SCROLL_STATE_TOUCH_SCROLL:
                            isFling=true;
                            break;
                        case SCROLL_STATE_IDLE:
                            isFling=false;
                            break;
                    }
                }

                @Override
                public void onScroll(AbsListView view, int firstVisibleItem, int visibleItemCount, int totalItemCount) {

                }
            });
        }else {
            adapter.SetList(pictureList);
        }

    }

    @Override
    public void setUserVisibleHint(final boolean isVisibleToUser) {
        super.setUserVisibleHint(isVisibleToUser);
        handler.post(new Runnable() {
            @Override
            public void run() {
                if (isVisibleToUser){
                    startTimer();
                }else {
                    stopTimer();
                }
            }
        });

    }

    @Override
    public void onDestroy() {
        super.onDestroy();
        stopTimer();
        if (EventBus.getDefault().isRegistered(this)) {
            EventBus.getDefault().unregister(this);
        }
    }

    public void startTimer() {
        stopTimer();
        if (timer == null) {
            timer = new Timer();
        }
        if (timetask == null) {
            timetask = new CustomTimerTask();
        }

        if (timer != null && timetask != null)
            timer.schedule(timetask, 0, 10000);
    }

    @Override
    public void onItemClick(AdapterView<?> parent, View view, int position, long id) {
        if (position==0){
            if (frgemntparents.globleCheckState){
                //点击关闭相机
                frgemntparents.globleCheckState=false;
                frgemntparents.doCloseCamare();
                HomeFragment.CamareStateOpened=false;
                frgemntparents.cusbitmap=null;
                adapter.notifyDataSetChanged();
                //关闭摄像头，上传用户默认头像
                Utils.checkAndUpLoadPicture(getActivity());
            }else {
                //点击打开相机
                frgemntparents.globleCheckState=true;
                HomeFragment.CamareStateOpened=true;
                frgemntparents.doOpenCamare();
                handler.sendEmptyMessage(UpDateMySelfOpen);
            }
        }else {
            //显示好友详细资料
            IMUIHelper.openUserProfileActivity(getActivity(), pictureList.get(position).getPeerId());
        }

    }

    public class CustomTimerTask extends TimerTask {
        @Override
        public void run() {
            isFling=false;
            handler.sendEmptyMessage(UpDateDB);
            //网络获取图片，并且展示，保存于本地
        }
    }
    public void stopTimer() {
        if (timer != null) {
            timer.cancel();
            timer = null;
        }

        if (timetask != null) {
            timetask.cancel();
            timetask = null;
        }
    }

}
