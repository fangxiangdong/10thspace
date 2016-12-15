package com.tenth.space.ui.adapter;

import android.content.Context;
import android.graphics.BitmapFactory;
import android.graphics.drawable.BitmapDrawable;
import android.support.v4.view.PagerAdapter;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageView;


import com.tenth.space.R;
import com.tenth.space.app.IMApplication;
import com.tenth.space.ui.adapter.album.OnItemClickListener;
import com.tenth.space.utils.ImageLoaderUtil;

import java.util.ArrayList;

/**
 * Created by wsq on 2016/9/29.
 */
public class CustomPrePagerAdapter extends PagerAdapter {

    private final Context context;
    private final ArrayList<String> paths;
    private OnItemClickListener onItemClickListener;

    public CustomPrePagerAdapter(Context context, ArrayList<String> paths) {
        this.context = context;
        this.paths = paths;
    }

    @Override
    public int getCount() {
        return paths.size();
    }

    @Override
    public boolean isViewFromObject(View view, Object object) {
        return object == view;
    }

    @Override
    public Object instantiateItem(ViewGroup container, final int position) {
        View inflate = View.inflate(context, R.layout.item_vp_pre, null);
        final ImageView imageView = (ImageView) inflate.findViewById(R.id.iv_pre);
        ImageLoaderUtil.instance().displayImage(IMApplication.app.UrlFormat(paths.get(position)),imageView,ImageLoaderUtil.getBlogOptions());
       // imageView.setBackground(new BitmapDrawable(BitmapUtils.getSquareBitmap2(BitmapFactory.decodeFile(paths.get(position)))));
        imageView.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                onItemClickListener.onItemClick(imageView, position);
            }
        });
        container.addView(inflate);
        return inflate;
    }

    @Override
    public void destroyItem(ViewGroup container, int position, Object object) {
//        super.destroyItem(container, position, object);
        container.removeView((View)object);
    }

    public void setOnItemClickListener(OnItemClickListener onItemClickListener) {
        this.onItemClickListener = onItemClickListener;
    }
}
