package com.tenth.space.moments;

import android.content.Intent;
import android.graphics.drawable.BitmapDrawable;
import android.os.Bundle;
import android.support.v7.widget.CardView;
import android.support.v7.widget.LinearLayoutManager;
import android.text.Editable;
import android.text.TextUtils;
import android.util.Log;
import android.view.Gravity;
import android.view.View;
import android.view.ViewGroup;
import android.view.WindowManager;
import android.view.animation.AnimationUtils;
import android.widget.AdapterView;
import android.widget.Button;
import android.widget.EditText;
import android.widget.FrameLayout;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.PopupWindow;
import android.widget.RelativeLayout;
import android.widget.TextView;

import com.github.jdsjlzx.interfaces.OnItemClickListener;
import com.github.jdsjlzx.interfaces.OnLoadMoreListener;
import com.github.jdsjlzx.interfaces.OnRefreshListener;
import com.github.jdsjlzx.recyclerview.LRecyclerView;
import com.github.jdsjlzx.recyclerview.LRecyclerViewAdapter;
import com.github.jdsjlzx.util.RecyclerViewStateUtils;
import com.github.jdsjlzx.view.LoadingFooter;
import com.tenth.space.DB.entity.BlogEntity;
import com.tenth.space.DB.entity.CommentEntity;
import com.tenth.space.R;
import com.tenth.space.app.IMApplication;
import com.tenth.space.config.IntentConstant;
import com.tenth.space.imservice.event.BlogInfoEvent;
import com.tenth.space.imservice.manager.IMBlogManager;
import com.tenth.space.imservice.manager.IMBuddyManager;
import com.tenth.space.ui.activity.DetailPortraitActivity;
import com.tenth.space.ui.widget.CircleImageView;
import com.tenth.space.utils.IMUIHelper;
import com.tenth.space.utils.ImageLoaderUtil;
import com.tenth.space.utils.LogUtils;
import com.tenth.space.utils.ToastUtils;
import com.tenth.space.utils.Utils;

import org.json.JSONArray;

import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;

import butterknife.BindView;
import butterknife.ButterKnife;
import cn.sharesdk.onekeyshare.OnekeyShare;
import de.greenrobot.event.EventBus;

/**
 * Created by Administrator on 2016/11/16.
 */
public class CommentActivity extends MomentsBaseActivity implements View.OnClickListener {
    @BindView(R.id.iv_back)
    ImageView mIvBack;
    @BindView(R.id.tv_title)
    TextView mTvTitle;
    @BindView(R.id.comment_title)
    RelativeLayout mCommentTitle;
    @BindView(R.id.lrv_comment)
    LRecyclerView mLrvComment;
    @BindView(R.id.transpond)
    LinearLayout mTranspond;
    @BindView(R.id.transpond_cnt)
    TextView mTranspondCnt;
    @BindView(R.id.comment_cnt)
    TextView mCommentCnt;
    @BindView(R.id.comment)
    LinearLayout mComment;
    @BindView(R.id.zan_cnt)
    TextView mZanCnt;
    @BindView(R.id.zan)
    LinearLayout mZan;
    @BindView(R.id.fl_hide)
    FrameLayout mFlHide;

    private HeadView mHeadHolder;
    private BlogEntity mBlogEntity;
    private View mHeadView;
    private int position;
    private View mInflate;
    private PopupWindow mCommentPopup;
    private CommentPopupHolder mPopupHolder;
    IMBlogManager mBlogManager = IMBlogManager.instance();
    private CommentAdapter mCommentAdapter;
    private boolean IsShowFlow;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_layout_comment);
        ButterKnife.bind(this);
        EventBus.getDefault().register(this);
        mInflate = View.inflate(this, R.layout.activity_layout_comment, null);

        mBlogEntity = (BlogEntity) getIntent().getSerializableExtra("BlogEntity");
        position = getIntent().getIntExtra("position", -2);
        IsShowFlow = getIntent().getBooleanExtra("IsShowFlow", false);

        initView();
        initData();
    }

    private void initView() {
        mHeadView = View.inflate(this, R.layout.head_comment, null);
        CardView cardView = new CardView(this);
        cardView.addView(mHeadView);
        cardView.setCardElevation(5);
        mHeadView = cardView;
        mHeadHolder = new HeadView(mHeadView);//==findViewById

        mTvTitle.setText("博客正文");

        mIvBack.setOnClickListener(this);
        mTranspond.setOnClickListener(this);
        mComment.setOnClickListener(this);
        mZan.setOnClickListener(this);

        initCommentPopup();
    }

    @Override
    public void onClick(View v) {
        switch (v.getId()) {
            case R.id.btn_submit_comment:
                Editable text = mPopupHolder.mEtComment.getText();
                if (TextUtils.isEmpty(text)) {
                    ToastUtils.show("还没有编辑哦");
                } else {
                    mBlogManager.reqAddComment(mBlogEntity.getBlogId(), text.toString());
                    mCommentPopup.dismiss();
                }
                break;

            case R.id.btn_cancel_comment:

                mCommentPopup.dismiss();
                break;

            case R.id.iv_back:
                finish();
                break;

            case R.id.transpond:
               // ToastUtils.show("转发");
                showShare();

                break;

            case R.id.comment:
                //ToastUtils.show("评论");
                mPopupHolder.mEtComment.setText("");//清空历史评论

                mFlHide.startAnimation(AnimationUtils.loadAnimation(this, R.anim.hide_bg));
                mFlHide.setVisibility(View.VISIBLE);
                mCommentPopup.showAtLocation(mInflate, Gravity.BOTTOM, 0, 0);

                break;

            case R.id.zan:
                //ToastUtils.show("点赞");

                break;
        }
    }
    private void showShare() {
        OnekeyShare oks = new OnekeyShare();
        //关闭sso授权
        oks.disableSSOWhenAuthorize();
        // title标题，印象笔记、邮箱、信息、微信、人人网、QQ和QQ空间使用
        oks.setTitle("标题");
        // titleUrl是标题的网络链接，仅在Linked-in,QQ和QQ空间使用
        oks.setTitleUrl("http://sharesdk.cn");
        // text是分享文本，所有平台都需要这个字段
        oks.setText("我是分享文本");
        //分享网络图片，新浪微博分享网络图片需要通过审核后申请高级写入接口，否则请注释掉测试新浪微博
        oks.setImageUrl("http://f1.sharesdk.cn/imgs/2014/02/26/owWpLZo_638x960.jpg");
        // imagePath是图片的本地路径，Linked-In以外的平台都支持此参数
        //oks.setImagePath("/sdcard/test.jpg");//确保SDcard下面存在此张图片
        // url仅在微信（包括好友和朋友圈）中使用
        oks.setUrl("http://sharesdk.cn");
        // comment是我对这条分享的评论，仅在人人网和QQ空间使用
        oks.setComment("我是测试评论文本");
        // site是分享此内容的网站名称，仅在QQ空间使用
        oks.setSite("ShareSDK");
        // siteUrl是分享此内容的网站地址，仅在QQ空间使用
        oks.setSiteUrl("http://sharesdk.cn");

// 启动分享GUI
        oks.show(this);
    }
    private void initCommentPopup() {
        View inflate = View.inflate(this, R.layout.comment_popup, null);
        mPopupHolder = new CommentPopupHolder(inflate);
        mPopupHolder.mBtnCancelComment.setOnClickListener(this);
        mPopupHolder.mBtnSubmitComment.setOnClickListener(this);

        mCommentPopup = new PopupWindow(inflate, ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.WRAP_CONTENT);
        mCommentPopup.setAnimationStyle(R.style.popwin_anim_style);
        //        设置可以获取焦点，否则弹出菜单中的EditText是无法获取输入的
        mCommentPopup.setFocusable(true);
        //        这句是为了防止弹出菜单获取焦点之后，点击activity的其他组件没有响应
        mCommentPopup.setBackgroundDrawable(new BitmapDrawable());
        //        设置软键盘调整位置，而不被弹窗挡住
        mCommentPopup.setSoftInputMode(WindowManager.LayoutParams.SOFT_INPUT_ADJUST_RESIZE);
//        commentPopup.setOutsideTouchable(true);

        //设置背景变暗
        mCommentPopup.setOnDismissListener(new PopupWindow.OnDismissListener() {
            @Override
            public void onDismiss() {
                mFlHide.setVisibility(View.GONE);
            }
        });
    }

    private void initData() {
        //获取评论(暂时取消)
        mBlogManager.reqCommentList(mBlogEntity.getBlogId());
        //初始化头布局
        initHeadData();

        /**配置recycler*/
        final LinearLayoutManager manager = new LinearLayoutManager(this, LinearLayoutManager.VERTICAL, false);
        mLrvComment.setLayoutManager(manager);
        //条目设置间距
        int topSpace = Utils.dip2px(this, 2);
        int bottomSpace = Utils.dip2px(this, 2);
        int leftSpace = Utils.dip2px(this, 5);
        int rightSpace = Utils.dip2px(this, 5);
        CommentItemDecoration decoration = new CommentItemDecoration(topSpace, bottomSpace, leftSpace, rightSpace);
        mLrvComment.addItemDecoration(decoration);
        //设置数据
        mCommentAdapter = new CommentAdapter(this);
        LRecyclerViewAdapter lRecyclerViewAdapter = new LRecyclerViewAdapter(mCommentAdapter);
        mLrvComment.setAdapter(lRecyclerViewAdapter);
        //添加头布局
        lRecyclerViewAdapter.addHeaderView(mHeadView);
//        //强制刷新
//        mLrvComment.forceToRefresh();

        //lRecyclerView事件处理
        mLrvComment.setOnRefreshListener(new OnRefreshListener() {
            @Override
            public void onRefresh() {
                RecyclerViewStateUtils.setFooterViewState(mLrvComment, LoadingFooter.State.Normal);
//                lRecyclerViewAdapter.clear();
//                mCurrentCounter = 0;
//                isRefresh = true;
                mBlogManager.reqCommentList(mBlogEntity.getBlogId());
            }
        });
        lRecyclerViewAdapter.setOnItemClickListener(new OnItemClickListener() {
            @Override
            public void onItemClick(View view, int position) {
            }

            @Override
            public void onItemLongClick(View view, int position) {
            }
        });

        mLrvComment.setOnLoadMoreListener(new OnLoadMoreListener() {
            @Override
            public void onLoadMore() {
                int position = manager.findFirstVisibleItemPosition();
                LogUtils.d("第一个显示的item=" + position);
                if (position > 1) {
                    RecyclerViewStateUtils.setFooterViewState(mLrvComment, LoadingFooter.State.TheEnd);
                }
            }
        });

    }

    private void initHeadData() {
        //头像，名称
        mHeadHolder.mTvName.setText(mBlogEntity.getNickName());
        ImageLoaderUtil.instance().displayImage(mBlogEntity.getAvatarUrl()+"?x-oss-process=image/resize,m_fill,h_100,w_100", mHeadHolder.mIvHeadIcon, ImageLoaderUtil.getAvatarOptions(10, 0));
       // ImageLoaderUtil.instance().displayImage(IMApplication.app.UrlFormat(mBlogEntity.getAvatarUrl()), mHeadHolder.mIvHeadIcon, ImageLoaderUtil.getAvatarOptions(10, 0));
        //ImageLoaderUtil.instance().displayImage(mBlogEntity.getAvatarUrl(), mHeadHolder.mIvHeadIcon);
        mHeadHolder.mIvHeadIcon.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                long writerUserId1 = mBlogEntity.getWriterUserId();
                IMUIHelper.openUserProfileActivity(CommentActivity.this, (int) writerUserId1);
            }
        });
        //手机型号
        String model = Utils.getPhoneModel();
        mHeadHolder.mTvMyPhone.setText("来自" + model + "用户");
        //正文
        mHeadHolder.mTvContent.setText(mBlogEntity.getBlogText());
        //显示图片GridView(控制 快速/猛速滑动 不加载图片)
        mHeadHolder.mGvImages.setOnScrollListener(ImageLoaderUtil.getPauseOnScrollLoader());
        JSONArray jsonArray = Utils.string2JsonArray(mBlogEntity.getBlogImages());
        //时间
        long created = mBlogEntity.getCreated();
        Date date = new Date(created * 1000);
        SimpleDateFormat simpleDateFormat = new SimpleDateFormat("MM-dd HH:mm");//yyyy-MM-dd HH:mm:ss
        String format = simpleDateFormat.format(date);
        mHeadHolder.mTvTime.setText(format);
        if (jsonArray != null) {
            if (jsonArray.length() > 0) {
                mHeadHolder.mGvImages.setVisibility(View.VISIBLE);
            } else {
                mHeadHolder.mGvImages.setVisibility(View.GONE);
            }
            NineGridLrvAdapter2 nineGridLrvAdapter2 = new NineGridLrvAdapter2(this, jsonArray);
            mHeadHolder.mGvImages.setAdapter(nineGridLrvAdapter2);
            //设置监听，点击进入查看大图
            final JSONArray finalJsonArray = jsonArray;
            mHeadHolder.mGvImages.setOnItemClickListener(new AdapterView.OnItemClickListener() {
                @Override
                public void onItemClick(AdapterView<?> parent, View view, int position, long id) {
                    //点击预览大图
                    Intent intent = new Intent(CommentActivity.this, DetailPortraitActivity.class);
                    intent.putExtra(IntentConstant.KEY_AVATAR_URL, finalJsonArray.optString(position));
                    intent.putExtra(IntentConstant.KEY_IS_IMAGE_CONTACT_AVATAR, true);
                    CommentActivity.this.startActivity(intent);
                }
            });
        }
        //评论点赞数
        mHeadHolder.mCommentCnt.setText(mBlogEntity.getCommentCnt() + "");
        mHeadHolder.mZanCnt.setText(mBlogEntity.getLikeCnt() + "");
        //设置是否关注
        if (IsShowFlow){
            mHeadHolder.mTvPulldown.setVisibility(View.VISIBLE);
            if (mBlogEntity.isFollow == 1) {
                mHeadHolder.mTvPulldown.setSelected(true);
                mHeadHolder.mTvPulldown.setText("已关注");
            } else {
                mHeadHolder.mTvPulldown.setSelected(false);
                mHeadHolder.mTvPulldown.setText("+关注");
            }
        }else {
            mHeadHolder.mTvPulldown.setVisibility(View.INVISIBLE);
        }

        final Long id = mBlogEntity.getWriterUserId();
        mHeadHolder.mTvPulldown.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                if (mBlogEntity.isFollow == 0) {
                    LogUtils.d("follow");
                    IMBuddyManager.instance().reqFollowUser(id, position);
                } else {
                    LogUtils.d("del_follow");
                    IMBuddyManager.instance().reqDelFollowUser(id, position);
                }
            }
        });
    }

    public void onEventMainThread(BlogInfoEvent event) {
        switch (event.getEvent()) {
            case FOLLOW_SUCCESS:
                mBlogEntity.isFollow = 1;
                LogUtils.d("关注成功，更新UI");

                mHeadHolder.mTvPulldown.setSelected(true);
                mHeadHolder.mTvPulldown.setText("已关注");
                break;

            case DEL_FOLLOW_SUCCESS:
                mBlogEntity.isFollow = 0;
                LogUtils.d("取消关注成功，更新UI");

                mHeadHolder.mTvPulldown.setSelected(false);
                mHeadHolder.mTvPulldown.setText("+关注");
                break;
            case GET_COMMENT_LIST_OK:
                ArrayList<CommentEntity> commentEntities = mBlogManager.getCommentEntities();
                LogUtils.d("获取评论成功，更新adapter:size=" + commentEntities.size());

                mLrvComment.refreshComplete();//刷新完成
                mCommentAdapter.setData(commentEntities);
                mCommentAdapter.notifyDataSetChanged();
                break;

            case ADD_COMMENT_OK:
                ArrayList<CommentEntity> commentEntities2 = mBlogManager.getCommentEntities();
                LogUtils.d("添加评论成功，更新adapter:size=" + commentEntities2.size());
                commentEntities2.add(event.mCommentEntity);

                mCommentAdapter.setData(commentEntities2);
                mCommentAdapter.notifyDataSetChanged();
                break;

        }
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();
        EventBus.getDefault().unregister(this);
    }

    static class HeadView {
        @BindView(R.id.iv_head_icon)
        ImageView mIvHeadIcon;
        @BindView(R.id.tv_name)
        TextView mTvName;
        @BindView(R.id.tv_time)
        TextView mTvTime;
        @BindView(R.id.tv_my_phone)
        TextView mTvMyPhone;
        //        @BindView(R.id.iv_pulldown)
//        ImageView mIvPulldown;
        @BindView(R.id.tv_pulldown)
        TextView mTvPulldown;
        //        @BindView(R.id.iv_add_follow)
//        ImageView mIvAddFollw;
        @BindView(R.id.tv_content)
        TextView mTvContent;
        @BindView(R.id.gv_images)
        MyGridView mGvImages;
        @BindView(R.id.transpond_cnt)
        TextView mTranspondCnt;
        @BindView(R.id.comment_cnt)
        TextView mCommentCnt;
        @BindView(R.id.zan_cnt)
        TextView mZanCnt;

        HeadView(View view) {
            ButterKnife.bind(this, view);
        }
    }

    static class CommentPopupHolder {
        @BindView(R.id.et_comment)
        EditText mEtComment;
        @BindView(R.id.btn_submit_comment)
        Button mBtnSubmitComment;
        @BindView(R.id.btn_cancel_comment)
        Button mBtnCancelComment;

        CommentPopupHolder(View view) {
            ButterKnife.bind(this, view);
        }
    }
}
