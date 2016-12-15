package com.tenth.space.ui.adapter;

import android.content.Context;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.AdapterView;
import android.widget.BaseAdapter;
import android.widget.TextView;

import com.tenth.space.DB.entity.BlogEntity;
import com.tenth.space.R;
import com.tenth.space.imservice.service.IMService;

import java.util.ArrayList;
import java.util.List;

/**
 * Created by neil.yi on 2016/9/21.
 */

public class BlogAdapter extends BaseAdapter implements
        AdapterView.OnItemClickListener,
        AdapterView.OnItemLongClickListener{

    private List<BlogEntity> blogList = new ArrayList<>();
    private Context ctx;
    private IMService imService;

    public BlogAdapter(Context context,IMService pimService){
        this.ctx = context;
        this.imService = pimService;
    }

    public static class ViewHolder
    {
        TextView tv_name,tv_phone;
    }

    @Override
    public View getView(int position, View convertView, ViewGroup parent)
    {
        View view = convertView;
        ViewHolder holder;
        if(view == null){
            view= LayoutInflater.from(ctx).inflate(R.layout.tt_item_internalitem,null);
            holder=new ViewHolder();
            holder.tv_name=(TextView)view.findViewById(R.id.tt_internal_item_title);
            //holder.tv_phone=(TextView)view.findViewById(R.id.contact_realname_title);
            view.setTag(holder);
        } else {
            holder=(ViewHolder)view.getTag();
        }

        BlogEntity blogEntity= (BlogEntity)getItem(position);
        if(blogEntity != null){ //to set every item's text
            holder.tv_name.setText(blogEntity.getBlogId());
            //holder.tv_phone.setText(blogEntity.getBlog());
        }
        return view;
    }

    @Override
    public Object getItem(int position) {
        return blogList.get(position);
    }

    @Override
    public long getItemId(int position) {
        return position;
    }

    @Override
    public void onItemClick(AdapterView<?> parent, View view, int position, long id) {
    }

    @Override
    public boolean onItemLongClick(AdapterView<?> parent, View view, int position, long id) {
        /*Object object =  getItem(position);
        if(object instanceof UserEntity){
            UserEntity userEntity = (UserEntity) object;
            IMUIHelper.handleContactItemLongClick(userEntity, ctx);
        }else{
        }*/
        return true;
    }

    @Override
    public int getCount() {
        return blogList==null?0:blogList.size();
    }

    public void putBlogList(List<BlogEntity> pBlogList){
        this.blogList.clear();
        if(pBlogList == null || pBlogList.size() <=0){
            return;
        }
        this.blogList = pBlogList;
        notifyDataSetChanged();
    }

}
