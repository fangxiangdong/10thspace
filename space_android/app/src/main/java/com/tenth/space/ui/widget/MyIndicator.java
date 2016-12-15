package com.tenth.space.ui.widget;

import android.content.Context;
import android.content.Intent;
import android.graphics.drawable.Drawable;
import android.support.v4.view.PagerAdapter;
import android.support.v4.view.ViewPager;
import android.util.AttributeSet;
import android.view.View;
import android.view.ViewGroup;
import android.widget.HorizontalScrollView;
import android.widget.ImageView;
import android.widget.LinearLayout;

import com.tenth.space.R;
import com.tenth.space.app.IMApplication;
import com.tenth.space.ui.activity.AddBlogActivity;
import com.tenth.space.utils.Utils;

public class MyIndicator extends HorizontalScrollView implements ViewPager.OnPageChangeListener {
    private ViewPager mViewPager;
    private MyLinearLayout myLinearLayout;
    ViewPager.OnPageChangeListener mListener;

    private final OnClickListener mTabClickListener = new OnClickListener() {
        public void onClick(View view) {
            TabView tabView = (TabView) view;
            final int oldSelected = mViewPager.getCurrentItem();
            final int newSelected = tabView.index;
            setCurrentItem(newSelected);
        }
    };
    private int RIGHT_BTN_WIDTH_DP = 50;//最右边按钮的宽度
    private int TAB_CONT = 4;//Tab最多可显示几个标签

    public MyIndicator(Context context) {
        super(context);
        init(context);
    }

    public MyIndicator(Context context, AttributeSet attrs) {
        super(context, attrs);
        init(context);
    }

    public MyIndicator(Context context, AttributeSet attrs, int defStyleAttr) {
        super(context, attrs, defStyleAttr);
        init(context);
    }

    private void init(final Context mcontext) {
        setHorizontalScrollBarEnabled(false);//隐藏自带的滚动条

        View inflate = View.inflate(mcontext, R.layout.tab_blog, null);
        ImageView iv_add_blog = (ImageView) inflate.findViewById(R.id.iv_add_blog);
        iv_add_blog.setOnClickListener(new OnClickListener() {
            @Override
            public void onClick(View v) {
                mcontext.startActivity(new Intent(mcontext, AddBlogActivity.class));
            }
        });
        myLinearLayout = (MyLinearLayout) inflate.findViewById(R.id.mll_tab_bar);

        int i = Utils.dip2px(IMApplication.app.getApplicationContext(), RIGHT_BTN_WIDTH_DP);
        LinearLayout.LayoutParams params = new LinearLayout.LayoutParams((Utils.getDisplayInfo()[0] - i), LinearLayout.LayoutParams.MATCH_PARENT);
        myLinearLayout.setLayoutParams(params);

        addView(inflate, new ViewGroup.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.WRAP_CONTENT));
    }

    public void setViewPager(ViewPager viewPager) {
        setViewPager(viewPager, 0);
    }

    public void setViewPager(ViewPager viewPager, int initPos) {
        if (mViewPager == viewPager) {
            return;
        }
        if (mViewPager != null) {
            mViewPager.setOnPageChangeListener(null);
        }
        final PagerAdapter adapter = viewPager.getAdapter();
        if (adapter == null) {
            throw new IllegalStateException("ViewPager does not have adapter instance.");
        }
        mViewPager = viewPager;
        viewPager.setOnPageChangeListener(this);
        notifyDataSetChanged();
        setCurrentItem(initPos);
    }

    private void notifyDataSetChanged() {
        myLinearLayout.removeAllViews();
        PagerAdapter mAdapter = mViewPager.getAdapter();
        int count = mAdapter.getCount();
        for (int i = 0; i < count; i++) {
            addTab(i, mAdapter.getPageTitle(i), count);
        }
        requestLayout();
    }

    private void addTab(int index, CharSequence text, int count) {
//        View inflate = View.inflate(IMApplication.app.getApplicationContext(), R.layout.tab_blog, null);
//        myLinearLayout = (MyLinearLayout) inflate.findViewById(R.id.mll_tab_bar);

        View inflate = View.inflate(IMApplication.app.getApplicationContext(), R.layout.tab_blog_item, null);
        TabView tabView = (TabView) inflate.findViewById(R.id.tabv);
        LinearLayout parent = (LinearLayout) tabView.getParent();
        parent.removeAllViews();

        int i = Utils.dip2px(IMApplication.app.getApplicationContext(), RIGHT_BTN_WIDTH_DP);
        LinearLayout.LayoutParams params = new LinearLayout.LayoutParams(
                //减去最后的button宽度，并且每行最多需要放置4个按钮，多的实现滑动
                (Utils.getDisplayInfo()[0] - i) / TAB_CONT,
                ViewGroup.LayoutParams.MATCH_PARENT);
        params.bottomMargin=2;
        tabView.setLayoutParams(params);

        tabView.index = index;
        tabView.setFocusable(true);
        tabView.setOnClickListener(mTabClickListener);
        tabView.setText(text);
        tabView.setTextSize(16);
        tabView.setPadding(10, 0, 10, 0);

//        TabView tabView = new TabView(getContext());
//        LinearLayout.LayoutParams params = new LinearLayout.LayoutParams((Utils.getDisplayInfo()[0] - 80) / 3, ViewGroup.LayoutParams.MATCH_PARENT, 1);
//        tabView.setLayoutParams(params);
//        tabView.index = index;
//        tabView.setGravity(Gravity.CENTER);
//        tabView.setFocusable(true);
//        tabView.setOnClickListener(mTabClickListener);
//        tabView.setText(text);
//        tabView.setTextSize(13);
//        tabView.setPadding(10, 0, 10, 0);

        myLinearLayout.addView(tabView);
    }

    public void setCurrentItem(int item) {
        if (mViewPager == null) {
            throw new IllegalStateException("ViewPager has not been bound.");
        }
        int mSelectedTabIndex = item;
        mViewPager.setCurrentItem(item);

        final int tabCount = myLinearLayout.getChildCount();
        for (int i = 0; i < tabCount; i++) {//遍历标题，改变选中的背景
            final View child = myLinearLayout.getChildAt(i);
            final boolean isSelected = (i == item);
            child.setSelected(isSelected);
            if (isSelected) {
                if (child instanceof TabView) {
                    ((TabView) child).setTextColor(getResources().getColor(R.color.blog_tab_text_color));
                    Drawable drawable = getResources().getDrawable(R.drawable.underline);
//                    这一步必须要做, 否则不会显示.
                    drawable.setBounds(0, 0, drawable.getMinimumWidth(), drawable.getMinimumHeight());
                    ((TabView) child).setCompoundDrawables(null, null, null, drawable);
                }
                animateToTab(item);//动画效果
            } else {
                if (child instanceof TabView) {
                    ((TabView) child).setTextColor(getResources().getColor(R.color.blog_tab_text_color));
                    Drawable drawable = getResources().getDrawable(R.drawable.online);
//                    这一步必须要做, 否则不会显示.
                    drawable.setBounds(0, 0, drawable.getMinimumWidth(), drawable.getMinimumHeight());
                    ((TabView) child).setCompoundDrawables(null, null, null, drawable);
                }
                animateToTab(item);//动画效果
              //  ((TabView) child).setCompoundDrawables(null, null, null, null);

            }
        }
    }

    private Runnable mTabSelector;

    private void animateToTab(final int position) {
        final View tabView = myLinearLayout.getChildAt(position);
        if (mTabSelector != null) {
            removeCallbacks(mTabSelector);
        }
        mTabSelector = new Runnable() {
            public void run() {
                final int scrollPos = tabView.getLeft() - (getWidth() - tabView.getWidth()) / 2;
                smoothScrollTo(scrollPos, 0);
                mTabSelector = null;
            }
        };
        post(mTabSelector);
    }

    public void setOnPageChangeListener(ViewPager.OnPageChangeListener listener) {
        mListener = listener;
    }

    @Override
    public void onPageScrolled(int position, float positionOffset, int positionOffsetPixels) {
        if (mListener != null)
            mListener.onPageScrolled(position, positionOffset, positionOffsetPixels);
    }

    @Override
    public void onPageSelected(int position) {
        setCurrentItem(position);
        if (mListener != null)
            mListener.onPageSelected(position);
    }

    @Override
    public void onPageScrollStateChanged(int state) {
        if (mListener != null)
            mListener.onPageScrollStateChanged(state);
    }
}