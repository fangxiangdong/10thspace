package com.tenth.space.moments;

import android.content.Context;
import android.content.Intent;
import android.support.v7.widget.CardView;
import android.support.v7.widget.RecyclerView;
import android.view.View;
import android.view.ViewGroup;
import android.widget.AdapterView;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.TextView;

import com.tenth.space.DB.entity.BlogEntity;
import com.tenth.space.R;
import com.tenth.space.app.IMApplication;
import com.tenth.space.config.IntentConstant;
import com.tenth.space.imservice.entity.BlogMessage;
import com.tenth.space.imservice.event.BlogInfoEvent;
import com.tenth.space.imservice.manager.IMBuddyManager;
import com.tenth.space.ui.activity.DetailPortraitActivity;
import com.tenth.space.utils.IMUIHelper;
import com.tenth.space.utils.ImageLoaderUtil;
import com.tenth.space.utils.LogUtils;
import com.tenth.space.utils.Utils;

import org.json.JSONArray;

import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;

import butterknife.BindView;
import butterknife.ButterKnife;
import cn.sharesdk.onekeyshare.OnekeyShare;
import de.greenrobot.event.EventBus;

/**
 * Created by wsq on 2016/11/2.
 */

public class MomentsAdapter extends RecyclerView.Adapter {
    private final boolean IsShowFlow;
    Context context;
    private List<BlogEntity> mData = new ArrayList<>();

    public void setData(List<BlogEntity> data) {
        mData = data;
        this.notifyDataSetChanged();
    }

    public Context getContext() {
        return context;
    }

    public List<BlogEntity> getData() {
        return mData;
    }

    public MomentsAdapter(Context context,boolean IsShowFlow) {
        this.context = context;
        this.IsShowFlow=IsShowFlow;
        EventBus.getDefault().register(this);
    }

    @Override
    public RecyclerView.ViewHolder onCreateViewHolder(ViewGroup parent, int viewType) {
        View inflate = View.inflate(context, R.layout.item_moments_adapter, null);

        CardView cardView = new CardView(context);

//        FrameLayout.LayoutParams layoutParams = new FrameLayout.LayoutParams(FrameLayout.LayoutParams.MATCH_PARENT, FrameLayout.LayoutParams.WRAP_CONTENT);
//        layoutParams.bottomMargin = Utils.dip2px(context, 10);
//        layoutParams.topMargin = Utils.dip2px(context, 10);
//        cardView.setLayoutParams(layoutParams);
//        cardView.setRadius(Utils.dip2px(context, 5));

        cardView.setCardElevation(1);
        cardView.addView(inflate);

        return new MyViewHolder(cardView);
    }

    @Override
    public void onBindViewHolder(final RecyclerView.ViewHolder holder, final int position) {
        if (holder instanceof MyViewHolder) {
            JSONArray jsonArray = null;
            String blogText = "";

            //根据数据类型(BlogMessage/BlogEntity)，解析数据
            if (mData.get(position) instanceof BlogMessage) {
                BlogMessage blogMessage = (BlogMessage) mData.get(position);

                blogText = blogMessage.getBlogText();
                jsonArray = new JSONArray(blogMessage.getUrlList());
            } else {
                blogText = mData.get(position).getBlogText();
                jsonArray = Utils.string2JsonArray(mData.get(position).getBlogImages());
            }
            //评论，点赞数
            ((MyViewHolder) holder).mCommentCnt.setText(mData.get(position).getCommentCnt() + "");
            ((MyViewHolder) holder).mZanCnt.setText(mData.get(position).getLikeCnt() + "");
            //设置头像(暂时无头像url)好友、推荐、关注的头像
           ImageLoaderUtil.instance().displayImage(mData.get(position).getAvatarUrl()+"?x-oss-process=image/resize,m_fill,h_100,w_100", ((MyViewHolder) holder).mIvHeadIcon, ImageLoaderUtil.getAvatarOptions(10, 0));
           // ImageLoaderUtil.instance().displayImage(IMApplication.app.UrlFormat(mData.get(position).getAvatarUrl()), ((MyViewHolder) holder).mIvHeadIcon, ImageLoaderUtil.getAvatarOptions(10, 0));
            //名称
            ((MyViewHolder) holder).mTvName.setText(mData.get(position).getNickName());
            //手机型号
            String model = Utils.getPhoneModel();
            ((MyViewHolder) holder).mTvMyPhone.setText("来自" + model + "用户");
            //时间
            long created = mData.get(position).getCreated();
            Date date = new Date(created * 1000);
            LogUtils.d("date:" + date.toString());
            SimpleDateFormat simpleDateFormat = new SimpleDateFormat("MM-dd HH:mm");//yyyy-MM-dd HH:mm:ss
            String format = simpleDateFormat.format(date);
            ((MyViewHolder) holder).mTvTime.setText(format);
            //内容
            ((MyViewHolder) holder).mTvContent.setText(blogText);

            //显示图片GridView(控制 快速/猛速滑动 不加载图片)
           /// ((MyViewHolder) holder).mGvImages.setOnScrollListener(ImageLoaderUtil.getPauseOnScrollLoader());
            if (jsonArray != null) {
                if (jsonArray.length() > 0) {
                    ((MyViewHolder) holder).mGvImages.setVisibility(View.VISIBLE);
                } else {
                    ((MyViewHolder) holder).mGvImages.setVisibility(View.GONE);
                }
                NineGridLrvAdapter2 nineGridLrvAdapter2 = new NineGridLrvAdapter2(context, jsonArray);
                ((MyViewHolder) holder).mGvImages.setAdapter(nineGridLrvAdapter2);
                final JSONArray finalJsonArray = jsonArray;
                ((MyViewHolder) holder).mGvImages.setOnItemClickListener(new AdapterView.OnItemClickListener() {
                    @Override
                    public void onItemClick(AdapterView<?> parent, View view, int position, long id) {
                        //点击预览大图
                        Intent intent = new Intent(context, DetailPortraitActivity.class);
                        intent.putExtra(IntentConstant.KEY_AVATAR_URL, finalJsonArray.optString(position));
                        intent.putExtra(IntentConstant.KEY_IS_IMAGE_CONTACT_AVATAR, true);
                        context.startActivity(intent);
                    }
                });

            }
            if(IsShowFlow){
                ((MyViewHolder) holder).mtvPulldown.setVisibility(View.VISIBLE);
                //设置是否关注
                if (mData.get(position).isFollow == 1) {
                    ((MyViewHolder) holder).mtvPulldown.setSelected(true);
                    ((MyViewHolder) holder).mtvPulldown.setText("已关注");
                } else {
                    ((MyViewHolder) holder).mtvPulldown.setSelected(false);
                    ((MyViewHolder) holder).mtvPulldown.setText("+关注");
                }
            }else {
                ((MyViewHolder) holder).mtvPulldown.setVisibility(View.INVISIBLE);
            }

            final Long writerUserId = mData.get(position).getWriterUserId();
            ((MyViewHolder) holder).mtvPulldown.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View v) {
                    if (mData.get(position).isFollow == 0) {
                        IMBuddyManager.instance().reqFollowUser(writerUserId, position);
                    } else {
                        IMBuddyManager.instance().reqDelFollowUser(writerUserId, position);
                    }
                }
            });

            //打开评论页
            ((MyViewHolder) holder).mComment.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View v) {
                    Intent intent = new Intent(context, CommentActivity.class);
                    intent.putExtra("BlogEntity", mData.get(position));
                    intent.putExtra("position", position);
                    intent.putExtra("IsShowFlow", IsShowFlow);
                    context.startActivity(intent);
                }
            });
            //转发
            ((MyViewHolder) holder).mTranspond.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View v) {
                  //  ToastUtils.show("转发");
                    showShare();
                }
            });
            //点赞
            ((MyViewHolder) holder).mZan.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View v) {
//                    ToastUtils.show("点赞");
                    int cnt = mData.get(position).getLikeCnt() + 1;
                    mData.get(position).setLikeCnt(cnt);
                    MomentsAdapter.this.notifyItemChanged(position);
                }
            });

            ((MyViewHolder) holder).mIvHeadIcon.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View v) {
                    long writerUserId1 = mData.get(position).getWriterUserId();
                    IMUIHelper.openUserProfileActivity(context, (int) writerUserId1);
                }
            });
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
        oks.show(context);
    }
    public void onEventMainThread(BlogInfoEvent event) {
        switch (event.getEvent()) {
            case FOLLOW_SUCCESS:
                mData.get(event.position).isFollow = 1;
//                this.notifyDataSetChanged();
                this.notifyItemChanged(event.position);
                LogUtils.d("关注成功，更新UI");
                break;

            case DEL_FOLLOW_SUCCESS:
                mData.get(event.position).isFollow = 0;
//                this.notifyDataSetChanged();
                this.notifyItemChanged(event.position);
                LogUtils.d("取消关注成功，更新UI");
                break;
        }
    }

    @Override
    public int getItemCount() {
        return mData.size();
    }

    static class MyViewHolder extends RecyclerView.ViewHolder {
        @BindView(R.id.iv_head_icon)
        ImageView mIvHeadIcon;
        @BindView(R.id.tv_name)
        TextView mTvName;
        @BindView(R.id.tv_time)
        TextView mTvTime;
        @BindView(R.id.tv_my_phone)
        TextView mTvMyPhone;

        @BindView(R.id.tv_pulldown)
        TextView mtvPulldown;
        @BindView(R.id.tv_content)
        TextView mTvContent;
        @BindView(R.id.gv_images)
        MyGridView mGvImages;
        @BindView(R.id.transpond)
        LinearLayout mTranspond;
        @BindView(R.id.comment)
        LinearLayout mComment;
        @BindView(R.id.comment_cnt)
        TextView mCommentCnt;
        @BindView(R.id.zan)
        LinearLayout mZan;
        @BindView(R.id.zan_cnt)
        TextView mZanCnt;

        MyViewHolder(View view) {
            super(view);
            ButterKnife.bind(this, view);
        }
    }
}
