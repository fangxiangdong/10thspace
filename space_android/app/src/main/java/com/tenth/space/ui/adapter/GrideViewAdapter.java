package com.tenth.space.ui.adapter;

import android.graphics.Bitmap;
import android.graphics.Color;
import android.support.v4.app.FragmentActivity;
import android.util.Log;
import android.view.View;
import android.view.ViewGroup;
import android.widget.AbsListView;
import android.widget.BaseAdapter;
import android.widget.GridView;
import android.widget.ImageView;
import android.widget.TextView;

import com.nostra13.universalimageloader.core.ImageLoader;
import com.nostra13.universalimageloader.core.listener.SimpleImageLoadingListener;
import com.tenth.space.DB.entity.UserEntity;
import com.tenth.space.R;
import com.tenth.space.aliyun.Config;
import com.tenth.space.app.IMApplication;
import com.tenth.space.ui.fragment.HomeFragment;
import com.tenth.space.ui.fragment.HomeItemFragment2;
import com.tenth.space.utils.ImageLoaderUtil;
import com.tenth.space.utils.ScreenUtil;
import com.tenth.space.utils.Utils;

import java.util.ArrayList;
import java.util.HashMap;

/**
 * Created by Administrator on 2016/11/28.
 */

public class GrideViewAdapter extends BaseAdapter {
    private final int currentWidth;
    private  GridView gv;
    private ArrayList<UserEntity> lists;
    private  FragmentActivity context;
    private  HomeFragment frgemntparents;

    public GrideViewAdapter(FragmentActivity activity, ArrayList<UserEntity> friendsList, HomeFragment frgemntparents,GridView gv) {
        this.context=activity;
        this.lists=friendsList;
        this.frgemntparents=frgemntparents;
        currentWidth=ScreenUtil.instance(context).getScreenWidth()/2-Utils.dip2px(activity,5f);
        this.gv=gv;
    }
    public  void SetList(ArrayList<UserEntity> lists){
        this.lists=lists;
        notifyDataSetChanged();
    }
    @Override
    public int getCount() {
        return lists.size();
    }

    @Override
    public Object getItem(int position) {
        return lists.get(position);
    }

    @Override
    public long getItemId(int position) {
        return position;
    }
    private HashMap<Integer, View> viewMap=new HashMap<>();//放置图片错位
    @Override
    public View getView(final int position, View convertView, ViewGroup parent) {
        final ViewHolder viewHolder;
        if(!viewMap.containsKey(position) || viewMap.get(position) == null){
            convertView = View.inflate(context,R.layout.item_imgeview_layout, null);
            viewHolder = new ViewHolder();
            //item的layoutparams用GridView.LayoutParams或者  AbsListView.LayoutParams设置，不能用LinearLayout.LayoutParams
            //convertView.setLayoutParams(new    GridView.LayoutParams(width,height));
            convertView.setLayoutParams(new AbsListView.LayoutParams(currentWidth, (int) ((currentWidth/0.648))) );
            viewHolder.image = (ImageView) convertView.findViewById(R.id.iiiiii);
            viewHolder.cb = (ImageView) convertView.findViewById(R.id.cb);
            viewHolder.tv_nikeName = (TextView) convertView.findViewById(R.id.tv_nikeName);
            convertView.setTag(viewHolder);
            viewMap.put(position, convertView);
        } else
        {
            convertView = viewMap.get(position);
            viewHolder = (ViewHolder) convertView.getTag();
        }
//防止内存溢出
        if(viewMap.size() > 12){synchronized (convertView) {
                for(int i = 1;i < gv.getFirstVisiblePosition() - 3;i ++){
                    viewMap.remove(i);
                }
                for(int i = gv.getLastVisiblePosition() + 3;i < getCount();i ++){
                    viewMap.remove(i);
                }
            }
        }
        viewHolder.image.setScaleType(ImageView.ScaleType.FIT_XY);
         if (position==0&&frgemntparents!=null){
            viewHolder.tv_nikeName.setVisibility(View.GONE);
            if (frgemntparents.cusbitmap!=null){
                viewHolder.image.setImageBitmap(frgemntparents.cusbitmap);
                viewHolder.cb.setVisibility(View.VISIBLE);
            }else {
                viewHolder.image.setScaleType(ImageView.ScaleType.CENTER_INSIDE);
                viewHolder.image.setBackgroundColor(Color.parseColor("#4d4d4d"));
                viewHolder.image.setImageResource(R.mipmap.my_photo);
                viewHolder.cb.setVisibility(View.GONE);
            }
        } else if (position!=0&&position<=lists.size()){
            viewHolder.tv_nikeName.setVisibility(View.VISIBLE);
            viewHolder.tv_nikeName.setText(lists.get(position).getMainName()+"");
            viewHolder.cb.setVisibility(View.GONE);
            //判断是否在滑动，滑动就加载默认图片，不是滑动就不加载默认图片
            try {
                if (HomeItemFragment2.isFling){//滑动过程中，加载一张默认图片
                    ImageLoaderUtil.instance(). displayImage(IMApplication.app.PrivateUrlFormat(Config.pictrueUrl+lists.get(position).getPeerId()+Utils.PNG), viewHolder.image, ImageLoaderUtil.getNoCacheUseDrawable(), null);
                }else {//静止状态下，
                    ImageLoaderUtil.instance(). displayImage(IMApplication.app.PrivateUrlFormat(Config.pictrueUrl+lists.get(position).getPeerId()+Utils.PNG), viewHolder.image, ImageLoaderUtil.getNoCache(), null);
                }
            }catch (Exception e){
                //加载失败抛出异常后，显示默认图片
                viewHolder.image.setImageResource(R.drawable.tt_message_image_error);
            }
        }

        return convertView;
    }
    class ViewHolder
    {
        public ImageView image;
        public ImageView cb;
        public TextView tv_nikeName;
    }
}
