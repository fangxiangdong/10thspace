package com.tenth.space.ui.fragment;

import android.os.Bundle;
import android.os.Message;
import android.support.v4.app.Fragment;
import android.support.v4.app.FragmentManager;
import android.support.v4.app.FragmentPagerAdapter;
import android.support.v4.view.ViewPager;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;

import com.tenth.space.R;
import com.tenth.space.app.IMApplication;
import com.tenth.space.imservice.service.IMService;
import com.tenth.space.imservice.support.IMServiceConnector;
import com.tenth.space.ui.base.TTBaseFragment;
import com.tenth.space.ui.widget.MyIndicator;

import java.util.ArrayList;

import butterknife.BindView;
import butterknife.ButterKnife;
import de.greenrobot.event.EventBus;

/**
 * Created by Administrator on 2016/11/11.
 */

public class BlogFragment extends TTBaseFragment {

    @BindView(R.id.indicator_blog)
    MyIndicator mIndicatorBlog;
    @BindView(R.id.vp_blog)
    ViewPager mVpBlog;

    private View mView;
    private BlogFragmentPagerAdapter mAdapter;
    private ArrayList<Fragment> mBlogFragments = new ArrayList<>();
    private ArrayList<String> mTypeList = new ArrayList<>();
    IMService imService;

    private IMServiceConnector imServiceConnector = new IMServiceConnector() {
        @Override
        public void onIMServiceConnected() {
            imService = imServiceConnector.getIMService();//链接时获取服务的实例
//            EventBus.getDefault().registerSticky(BlogFragment.this);//链接时注册EventBus事件订阅者

//            mLoginInfo = imService.getLoginManager().getLoginInfo();

            //设置head的user信息
//            LogUtils.d("mLoginInfo.toString():" + mLoginInfo.toString());
            Message message = new Message();
            message.what = 0;
//            mHandler.handleMessage(message);

        }

        @Override
        public void onServiceDisconnected() {
            if (EventBus.getDefault().isRegistered(BlogFragment.this)) {
                EventBus.getDefault().unregister(BlogFragment.this);
            }
        }
    };

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {
        mView = inflater.inflate(R.layout.fragment_blog, null);
//        mView = View.inflate(getActivity(), R.layout.fragment_blog, null);
        ButterKnife.bind(this, mView);

        imServiceConnector.connect(IMApplication.app);

        setTopTitle(getActivity().getString(R.string.main_innernet));
        initRigthButton();
        topBar.setVisibility(View.GONE);

        initData();
        initView();

        return mView;
    }

    @Override
    protected void initHandler() {

    }

    private void initData() {
        mTypeList.add("推荐");
        mTypeList.add("好友");
        mTypeList.add("关注");

        /**
         * fragment 对应关系
         * 0，推荐
         * 1，朋友
         * 2，关注
         */
        for (int i = 0; i < mTypeList.size(); i++) {
            mBlogFragments.add(InternalFragment.newInstance(i));
        }

    }

    private void initView() {
        mAdapter = new BlogFragmentPagerAdapter(getFragmentManager());
        mVpBlog.setAdapter(mAdapter);

        mVpBlog.addOnPageChangeListener(new ViewPager.OnPageChangeListener() {
            @Override
            public void onPageScrolled(int position, float positionOffset, int positionOffsetPixels) {

            }

            @Override
            public void onPageSelected(int position) {
//                secondlist = firstlist.get(position).getSecondlist();
                mAdapter.notifyDataSetChanged();
            }

            @Override
            public void onPageScrollStateChanged(int state) {

            }
        });

        mIndicatorBlog.setViewPager(mVpBlog);
    }

    class BlogFragmentPagerAdapter extends FragmentPagerAdapter {

        private final FragmentManager fm;

        public BlogFragmentPagerAdapter(FragmentManager fm) {
            super(fm);
            this.fm = fm;
        }

        @Override
        public Fragment getItem(int position) {
//            return newFragment(position + 1);
            return mBlogFragments.get(position);
        }

        @Override
        public int getCount() {
            return mTypeList.size();
        }

        @Override
        public CharSequence getPageTitle(int position) {
            return mTypeList.get(position);
        }

//        @Override
//        public Object instantiateItem(ViewGroup container, int position) {
//            return super.instantiateItem(container, position);
//        }
//
//        @Override
//        public void destroyItem(ViewGroup container, int position, Object object) {
//            super.destroyItem(container, position, object);
//        }
    }
}
