package com.tenth.space.moments;

import android.content.Context;
import android.support.v7.widget.RecyclerView;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageView;

import com.tenth.space.R;

import butterknife.BindView;
import butterknife.ButterKnife;

/**
 * Created by wsq on 2016/11/2.
 */
public class NineGridLrvAdapter extends RecyclerView.Adapter {
    private final String blogImage1;
    private final Context context;

    public NineGridLrvAdapter(Context context, String blogImage1) {
        this.blogImage1 = blogImage1;
        this.context = context;
    }

    @Override
    public RecyclerView.ViewHolder onCreateViewHolder(ViewGroup parent, int viewType) {
        View inflate = View.inflate(context, R.layout.item_images_moments, null);
        return new Holder(inflate);
    }

    @Override
    public void onBindViewHolder(RecyclerView.ViewHolder holder, int position) {
        if (holder instanceof Holder) {
            ((Holder) holder).mIvImageImages.setImageResource(R.drawable.tt_yaya_e2);
        }
    }

    @Override
    public int getItemCount() {
        return 9;
    }

    class Holder extends RecyclerView.ViewHolder {
        @BindView(R.id.iv_image_images)
        ImageView mIvImageImages;

        public Holder(View itemView) {
            super(itemView);
            ButterKnife.bind(this, itemView);
        }
    }
}
