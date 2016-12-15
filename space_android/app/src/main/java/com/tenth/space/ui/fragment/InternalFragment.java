package com.tenth.space.ui.fragment;

import android.content.Intent;
import android.os.Bundle;
import android.os.Handler;
import android.os.Message;
import android.support.v4.app.Fragment;
import android.support.v7.widget.LinearLayoutManager;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.TextView;

import com.github.jdsjlzx.interfaces.OnItemClickListener;
import com.github.jdsjlzx.interfaces.OnLoadMoreListener;
import com.github.jdsjlzx.interfaces.OnRefreshListener;
import com.github.jdsjlzx.recyclerview.LRecyclerView;
import com.github.jdsjlzx.recyclerview.LRecyclerViewAdapter;
import com.github.jdsjlzx.util.RecyclerViewStateUtils;
import com.github.jdsjlzx.view.LoadingFooter;
import com.tenth.space.DB.DBInterface;
import com.tenth.space.DB.entity.BlogEntity;
import com.tenth.space.DB.entity.UserEntity;
import com.tenth.space.R;
import com.tenth.space.app.IMApplication;
import com.tenth.space.imservice.entity.BlogMessage;
import com.tenth.space.imservice.event.BlogInfoEvent;
import com.tenth.space.imservice.manager.IMBlogManager;
import com.tenth.space.imservice.manager.IMLoginManager;
import com.tenth.space.imservice.service.IMService;
import com.tenth.space.imservice.support.IMServiceConnector;
import com.tenth.space.moments.CommentActivity;
import com.tenth.space.moments.MomentsAdapter;
import com.tenth.space.moments.MomentsItemDecoration;
import com.tenth.space.protobuf.IMBaseDefine;
import com.tenth.space.utils.LogUtils;
import com.tenth.space.utils.Utils;

import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;

import butterknife.BindView;
import butterknife.ButterKnife;
import cn.sharesdk.onekeyshare.OnekeyShare;
import de.greenrobot.event.EventBus;

public class InternalFragment extends Fragment {

    @BindView(R.id.lrv_internal)
    LRecyclerView mLrvInternal;
    @BindView(R.id.ll_progress_bar)
    LinearLayout ll_progress_bar;
    private View curView = null;
    IMService imService;
    private MomentsAdapter mMomentsAdapter;
   // private UserEntity mLoginInfo;
    private TextView mUser_name_head;
    private ImageView mUser_bgpic_head;
    private ImageView mUser_icon_head;
    public List<BlogEntity> globalList=new ArrayList<>();
    public int pager=0;
    private List<UserEntity> DBlists;//查询本地数据库中关注，好友列表
//    Handler mHandler = new Handler() {
//        @Override
//        public void handleMessage(Message msg) {
//            super.handleMessage(msg);
//            switch (msg.what) {
//                case 0:
//                    if (mLoginInfo != null) {
//                        mUser_name_head.setText(mLoginInfo.getMainName());
//                    }
//                    break;
//                case 1://查询数据库
//                   //  DBlists = (List<UserEntity>) msg.obj;
//                  //  Log.i("GTAG","Dblist.size="+DBlists.size());
//                  //  IMBlogManager.instance().reqBlogList(IMBaseDefine.BlogType.BLOG_TYPE_RCOMMEND,pager);
//                    break;
//
//                default:
//                    break;
//            }
//        }
//    };

//    private IMServiceConnector imServiceConnector = new IMServiceConnector() {
//        @Override
//        public void onIMServiceConnected() {
//            LogUtils.d("InternalFragment----->onIMServiceConnected，链接，并注册EventBus，再重新取值");
//            imService = imServiceConnector.getIMService();//链接时获取服务的实例
//            /** 注意此处需要冲洗再取值，应为EventBus注册的时候，IMBlogManager中的返回已经在登录时执行过了 */
//           // EventBus.getDefault().postSticky(new BlogInfoEvent(BlogInfoEvent.Event.GET_BLOG_OK));
//            //设置head的user信息
//            mLoginInfo = imService.getLoginManager().getLoginInfo();
//            Message message = new Message();
//            message.what = 0;
//            mHandler.handleMessage(message);
//
//        }
//
//        @Override
//        public void onServiceDisconnected() {
//            if (EventBus.getDefault().isRegistered(InternalFragment.this)) {
//                EventBus.getDefault().unregister(InternalFragment.this);
//            }
//        }
//    };
    private int mTag;
    private List<BlogEntity> mBlogList = null;
    private boolean IsShowFlow;

    public static InternalFragment newInstance(int arg) {
        InternalFragment fragment = new InternalFragment();
        Bundle bundle = new Bundle();
        bundle.putInt("TAG", arg);
        fragment.setArguments(bundle);
        return fragment;
    }
    public InternalFragment(){
        //注册
        EventBus.getDefault().registerSticky(this);//链接时注册EventBus事件订阅者
    }

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {
        if (null != curView) {
            return curView;
        }
        mTag = getArguments().getInt("TAG", -1);
        curView = inflater.inflate(R.layout.tt_fragment_internal, null);
        ButterKnife.bind(this, curView);
        ll_progress_bar.setVisibility(View.VISIBLE);
        initData();
        //绑定IMService.class
       // imServiceConnector.connect(getActivity());
        //查询

//请求服务器
        getData(pager);
        return curView;
    }

    private void getData(final int pager) {
        switch (mTag){
            case 0://请求推荐
                //查询数据库
                IMApplication.app.getThreadPool().execute(new Runnable() {
                    @Override
                    public void run() {
                        //查询数据库
                        DBlists = DBInterface.instance().loadAllUsers();
                        IMBlogManager.instance().reqBlogList(IMBaseDefine.BlogType.BLOG_TYPE_RCOMMEND,pager);
                        if (DBlists==null){
                            return;
                        }

                    }});

                break;
            case 1://请求好友
                IMBlogManager.instance().reqBlogList(IMBaseDefine.BlogType.BLOG_TYPE_FRIEND,pager);
                break;
            case 2://请求关注
                IMBlogManager.instance().reqBlogList(IMBaseDefine.BlogType.BLOG_TYPE_FOLLOWUSER,pager);
                break;
        }
    }

    private void initData() {
        final LinearLayoutManager manager = new LinearLayoutManager(getContext(), LinearLayoutManager.VERTICAL, false);
        mLrvInternal.setLayoutManager(manager);
        //条目设置间距
        int topSpace = Utils.dip2px(getActivity(), 5);
        int bottomSpace = Utils.dip2px(getActivity(), 5);
        int leftSpace = Utils.dip2px(getActivity(), 0);
        int rightSpace = Utils.dip2px(getActivity(), 0);
        MomentsItemDecoration decoration = new MomentsItemDecoration(topSpace, bottomSpace, leftSpace, rightSpace);
        decoration.setTag(mTag);
        mLrvInternal.addItemDecoration(decoration);
        //是否显示关注按钮
         IsShowFlow = false;
        if (mTag==0||mTag==2){
            IsShowFlow=true;
        }
        mMomentsAdapter = new MomentsAdapter(getContext(),IsShowFlow);
        LRecyclerViewAdapter lRecyclerViewAdapter = new LRecyclerViewAdapter(mMomentsAdapter);
        mLrvInternal.setAdapter(lRecyclerViewAdapter);

        //不需要微信样式的头布局
      //  View inflate = View.inflate(getActivity(), R.layout.item_blog_head, null);
      //  initInflate(inflate);
        mLrvInternal.setOnRefreshListener(new OnRefreshListener() {
            @Override
            public void onRefresh() {//下拉刷新
                RecyclerViewStateUtils.setFooterViewState(mLrvInternal, LoadingFooter.State.Normal);
                //globalList.clear();
                pager=0;
                getData(pager);
            }
        });
        lRecyclerViewAdapter.setOnItemClickListener(new OnItemClickListener() {
            @Override
            public void onItemClick(View view, int position) {
                Intent intent = new Intent(getActivity(), CommentActivity.class);
                intent.putExtra("BlogEntity", globalList.get(position));
                intent.putExtra("position", position);
                intent.putExtra("IsShowFlow", IsShowFlow);
                getActivity().startActivity(intent);
            }

            @Override
            public void onItemLongClick(View view, int position) {

            }
        });

        mLrvInternal.setOnLoadMoreListener(new OnLoadMoreListener() {
            @Override
            public void onLoadMore() {
                //加载更多
                pager++;
                getData(pager);
                int position = manager.findFirstVisibleItemPosition();
                if (position > 1) {
                    RecyclerViewStateUtils.setFooterViewState(mLrvInternal, LoadingFooter.State.TheEnd);
                }
            }
        });
    }

    //----------------------------event 事件驱动----------------------------
    public void onEventMainThread(BlogInfoEvent event) {
        int tags = event.position;
        if (ll_progress_bar!=null){
            ll_progress_bar.setVisibility(View.GONE);
        }

        switch (event.getEvent()) {
            case GET_BLOG_OK://获取博客列表（一般只在第一次执行）//获取临时文件
                switch (mTag) {
                    case 0://推荐
                       // Log.i("gTAG")
                        if (tags==-1){
                            mBlogList = IMBlogManager.instance().getRecommendBlogList();
                            //临时文件，对比数据库，是否包含好友和关注，有就删除不显示
                            checkAndDelete(mBlogList,DBlists);
                            mLrvInternal.refreshComplete();
                            if(pager==0){
                                globalList.clear();
                            }
                            if (mBlogList.size()>0) {
                                globalList.addAll(mBlogList);
                                mMomentsAdapter.setData(globalList);
                            }
                        }
                        break;

                    case 1://好友
                        if (tags==-2) {
                            mBlogList = IMBlogManager.instance().getFridendBlogList();
                            mLrvInternal.refreshComplete();
                            if(pager==0){
                                globalList.clear();
                            }
                            if (mBlogList.size()>0) {
                                globalList.addAll(mBlogList);
                                mMomentsAdapter.setData(globalList);
                            }
                        }
                        break;

                    case 2://关注
                        if (tags==-3){
                            mBlogList = IMBlogManager.instance().getFollowBlogList();
                            for (BlogEntity blogEntity:mBlogList){
                                //标示已经全部关注了的
                                blogEntity.isFollow=1;
                            }
                            mLrvInternal.refreshComplete();
                            if(pager==0){
                                globalList.clear();
                            }
                            if (mBlogList.size()>0) {
                                globalList.addAll(mBlogList);
                                mMomentsAdapter.setData(globalList);
                            }
                        }

                        break;
                }

                break;

            case ADD_BLOG_UPDATE_OK://发表新博客刷新列表
                if (mTag == 1) {//发表的新的博客默认添加在好友博客页
                    BlogMessage blogMessage = event.getBlogMessage();
                    mMomentsAdapter.getData().add(0, blogMessage);//插入数据
                    mMomentsAdapter.notifyDataSetChanged();
                }
                break;
        }
    }

    private void checkAndDelete(List<BlogEntity> mBlogList, List<UserEntity> DBlists) {
        //对比判断是否有自己的id（首）
        if (mBlogList.size()>0&&DBlists.size()>0){
            //对比
            Iterator<BlogEntity> mBlogListIterator = mBlogList.iterator();
           while (mBlogListIterator.hasNext()){
               Long friendId = mBlogListIterator.next().getWriterUserId();
               for (UserEntity userEntity:DBlists){
                   if (userEntity.getPeerId()==friendId||friendId== IMLoginManager.instance().getLoginId()){
                       mBlogListIterator.remove();
                       break;
                   }
               }
           }
        }
    }
//
//    private void initInflate(View inflate) {
//        mUser_name_head = (TextView) inflate.findViewById(R.id.user_name_head);
//        mUser_bgpic_head = (ImageView) inflate.findViewById(R.id.user_bgpic_head);
//        mUser_icon_head = (ImageView) inflate.findViewById(R.id.user_icon_head);
//    }

    @Override
    public void onDestroy() {
        super.onDestroy();
        EventBus.getDefault().unregister(this);
       // imServiceConnector.disconnect(getActivity());
    }

}
