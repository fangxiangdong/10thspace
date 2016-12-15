package com.tenth.space.ui.adapter;

import android.content.Context;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.BaseAdapter;
import android.widget.EditText;
import android.widget.ImageView;
import android.widget.TextView;

import com.tenth.space.DB.entity.UserEntity;
import com.tenth.space.R;
import com.tenth.space.app.IMApplication;
import com.tenth.space.imservice.manager.FriendManager;
import com.tenth.space.imservice.manager.IMContactManager;
import com.tenth.space.protobuf.IMBaseDefine;
import com.tenth.space.ui.activity.FriendsActivity;
import com.tenth.space.utils.IMUIHelper;
import com.tenth.space.utils.ImageLoaderUtil;

import java.util.List;

/**
 * Created by Administrator on 2016/11/9.
 */

public class SearchResultAdapter extends BaseAdapter{
    private  List<IMBaseDefine.UserInfo> list;
    private  Context context;
    public SearchResultAdapter(Context context, List<IMBaseDefine.UserInfo> list){
        this.context=context;
        this.list=list;
    }
    @Override
    public int getCount() {
        return list.size();
    }

    @Override
    public Object getItem(int position) {
        return null;
    }

    @Override
    public long getItemId(int position) {
        return position;
    }

    @Override
    public View getView(final int position, View convertView, ViewGroup parent) {
        final ViewHolder viewHolder;
        if(convertView==null){
            convertView = LayoutInflater.from(context).inflate(R.layout.item_search_result,null);
            viewHolder=new ViewHolder();
            viewHolder.name= (TextView) convertView.findViewById(R.id.name);
            viewHolder.add= (TextView) convertView.findViewById(R.id.add);
            viewHolder.msg= (EditText) convertView.findViewById(R.id.msg);
            viewHolder.chat= (TextView) convertView.findViewById(R.id.chat);
            viewHolder.photo= (ImageView) convertView.findViewById(R.id.image);
            convertView.setTag(viewHolder);
        }else {
            viewHolder= (ViewHolder) convertView.getTag();
        }
        final IMBaseDefine.UserInfo info = list.get(position);
        ImageLoaderUtil.instance().displayImage(IMApplication.app.UrlFormat(info.getAvatarUrl()),viewHolder.photo,ImageLoaderUtil.getAvatarOptions(0,0));
        viewHolder.name.setText(info.getUserRealName());
        List<UserEntity> contactSortedList = IMContactManager.instance().getContactSortedList();
        final UserEntity contact = IMContactManager.instance().findContact(info.getUserId());
        if(contactSortedList.contains(contact)){
            viewHolder.add.setVisibility(View.GONE);
            viewHolder.msg.setVisibility(View.GONE);
            viewHolder.chat.setVisibility(View.VISIBLE);
        }else {
            viewHolder.add.setVisibility(View.VISIBLE);
            viewHolder.msg.setVisibility(View.VISIBLE);
            viewHolder.chat.setVisibility(View.GONE);
        }
        viewHolder.add.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                int friendId = info.getUserId();
                String addMsg=viewHolder.msg.getText().toString();
                FriendManager.instance().addFriend(addMsg,friendId);
            }
        });
        viewHolder.chat.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                String sessionKey = contact.getSessionKey();
                IMUIHelper.openChatActivity(context, sessionKey);
                ((FriendsActivity)context).finish();
            }
        });

        return convertView;
    }

    public static class ViewHolder
    {   TextView add;
        TextView chat;
        EditText msg;
        TextView name;
        ImageView photo;
    }
}
