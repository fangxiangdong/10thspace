package com.tenth.space.moments;

import android.content.Context;
import android.support.v7.widget.CardView;
import android.support.v7.widget.RecyclerView;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageView;
import android.widget.TextView;

import com.tenth.space.DB.entity.CommentEntity;
import com.tenth.space.R;
import com.tenth.space.app.IMApplication;
import com.tenth.space.imservice.event.BlogInfoEvent;
import com.tenth.space.ui.widget.CircleImageView;
import com.tenth.space.utils.IMUIHelper;
import com.tenth.space.utils.ImageLoaderUtil;
import com.tenth.space.utils.LogUtils;
import com.tenth.space.utils.Utils;

import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;

import butterknife.BindView;
import butterknife.ButterKnife;

/**
 * Created by Administrator on 2016/11/16.
 */
public class CommentAdapter extends RecyclerView.Adapter {
    Context context;

    private List<CommentEntity> mData = new ArrayList<>();

    public void setData(List<CommentEntity> data) {
        mData = data;
    }

    public List<CommentEntity> getData() {
        return mData;
    }

    public CommentAdapter(Context context) {
        this.context = context;
    }

    @Override
    public RecyclerView.ViewHolder onCreateViewHolder(ViewGroup parent, int viewType) {
        View inflate = View.inflate(context, R.layout.item_comment_blog, null);

        //包装cardview
        CardView cardView = new CardView(context);
        cardView.addView(inflate);
        cardView.setCardElevation(5);
        cardView.setRadius(15);
//        cardView.setZ(-1);
//        cardView.setTranslationZ(-10);

        return new CommentHolder(cardView);
    }

    @Override
    public void onBindViewHolder(RecyclerView.ViewHolder holder, final int position) {
        if (holder instanceof CommentHolder) {
            //内容
            ((CommentHolder) holder).mTvContent.setText(mData.get(position).getMsgData());
            //用户昵称
            ((CommentHolder) holder).mTvName.setText(mData.get(position).getNickName());
            //头像
            ImageLoaderUtil.instance().displayImage(mData.get(position).getAvatarUrl()+"?x-oss-process=image/resize,m_fill,h_50,w_50",
           // ImageLoaderUtil.instance().displayImage(IMApplication.app.UrlFormat(mData.get(position).getAvatarUrl()),
                    ((CommentHolder) holder).mIvHeadIcon,
                    ImageLoaderUtil.getAvatarOptions(5, 0));
            ((CommentHolder) holder).mIvHeadIcon.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View v) {
                    long writerUserId = mData.get(position).getWriter_user_id();
                    IMUIHelper.openUserProfileActivity(context, (int) writerUserId);
                }
            });
            //手机型号
            String model = Utils.getPhoneModel();
            ((CommentHolder) holder).mTvPhoneModel.setText("来自" + model + "用户");
            //时间
            int created = mData.get(position).getCreated();
            Date date = new Date(created * 1000);
            LogUtils.d("date:" + date.toString());
            SimpleDateFormat simpleDateFormat = new SimpleDateFormat("MM-dd HH:mm");//yyyy-MM-dd HH:mm:ss
            String format = simpleDateFormat.format(date);
            ((CommentHolder) holder).mTvTime.setText(format);
        }
    }

    public void onEventMainThread(BlogInfoEvent event) {

    }

    @Override
    public int getItemCount() {
        return mData.size();
    }

    static class CommentHolder extends RecyclerView.ViewHolder {
        @BindView(R.id.iv_head_icon)
        ImageView mIvHeadIcon;
        @BindView(R.id.tv_name)
        TextView mTvName;
        @BindView(R.id.tv_time)
        TextView mTvTime;
        @BindView(R.id.tv_phone_model)
        TextView mTvPhoneModel;
        @BindView(R.id.tv_content)
        TextView mTvContent;

        CommentHolder(View view) {
            super(view);
            ButterKnife.bind(this, view);
        }
    }
}
