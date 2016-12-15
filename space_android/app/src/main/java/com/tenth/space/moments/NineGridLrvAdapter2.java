package com.tenth.space.moments;

import android.content.Context;
import android.util.Log;
import android.view.View;
import android.view.ViewGroup;
import android.widget.BaseAdapter;
import android.widget.ImageView;

import com.tenth.space.R;
import com.tenth.space.app.IMApplication;
import com.tenth.space.utils.ImageLoaderUtil;

import org.json.JSONArray;

/**
 * Created by wsq on 2016/11/2.
 */
public class NineGridLrvAdapter2 extends BaseAdapter {
    private final JSONArray blogImages;
    private final Context context;

    public NineGridLrvAdapter2(Context context, JSONArray blogImages) {
        this.blogImages = blogImages;
        this.context = context;
    }

    @Override
    public int getCount() {
        if (blogImages == null) {
            return 0;
        } else {
            return blogImages.length();
        }
    }

    @Override
    public Object getItem(int position) {
        return null;
    }

    @Override
    public long getItemId(int position) {
        return 0;
    }

    @Override
    public View getView(int position, View convertView, ViewGroup parent) {

        View inflate = View.inflate(context, R.layout.item_images_moments, null);
        ImageView imageView = (ImageView) inflate.findViewById(R.id.iv_image_images);
        //获取缩略图
            ImageLoaderUtil.instance().displayImage(blogImages.optString(position)+"?x-oss-process=image/resize,h_200", imageView, ImageLoaderUtil.getBlogOptions());
           // ImageLoaderUtil.instance().displayImage(IMApplication.app.UrlFormat(blogImages.optString(position)), imageView, ImageLoaderUtil.getBlogOptions());
            //ImageLoaderUtil.instance().displayImage(blogImages.optString(position), imageView, ImageLoaderUtil.getBlogOptions());
        return imageView;
    }
}
