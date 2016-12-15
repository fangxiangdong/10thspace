package com.tenth.space.ui.fragment;

import android.content.Intent;
import android.os.Bundle;
import android.support.annotation.Nullable;
import android.support.v4.app.Fragment;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.AdapterView;
import android.widget.ListView;

import com.tenth.space.DB.entity.UserEntity;
import com.tenth.space.R;
import com.tenth.space.imservice.manager.IMContactManager;
import com.tenth.space.protobuf.IMBaseDefine;
import com.tenth.space.ui.activity.UserActivity;
import com.tenth.space.ui.adapter.ContactAdapter;

import java.util.Iterator;
import java.util.List;

/**
 * Created by Administrator on 2016/11/28.
 */

public class AttentionFragment extends Fragment implements AdapterView.OnItemClickListener{

    private View mcurView;
    private ContactAdapter contactAdapter;
    private ListView attentionUsers;
    private List<UserEntity> contactList;

    @Nullable
    @Override
    public View onCreateView(LayoutInflater inflater,ViewGroup container,Bundle savedInstanceState) {
        if (null != mcurView) {
            ((ViewGroup) mcurView.getParent()).removeView(mcurView);
            return mcurView;
        }
        mcurView = inflater.inflate(R.layout.fragments_contact, null);
        initView();
        return mcurView;
    }
    private void initView(){
        contactAdapter = new ContactAdapter(getActivity());
        mcurView.findViewById(R.id.new_friends).setVisibility(View.GONE);
        attentionUsers = (ListView) mcurView.findViewById(R.id.all_contact_list);
        attentionUsers.setOnItemClickListener(this);
        attentionUsers.setAdapter(contactAdapter);
        renderUserList();
    }
    private void renderUserList() {
        contactList = IMContactManager.instance().getContactSortedList();
        for (Iterator<UserEntity> userEntitys = contactList.iterator(); userEntitys.hasNext();) {
            UserEntity userEntity = userEntitys.next();
            if(! userEntity.getRelation().equals(IMBaseDefine.UserRelationType.RELATION_FOLLOW.name())){
                userEntitys.remove();
            }
        }
        // 没有任何的联系人数据
        if (contactList.size() <= 0) {
            mcurView.findViewById(R.id.contact).setVisibility(View.GONE);
            mcurView.findViewById(R.id.no_attention).setVisibility(View.VISIBLE);
            return;
        }
        contactAdapter.putUserList(contactList);
        contactAdapter.notifyDataSetChanged();
    }

    @Override
    public void onItemClick(AdapterView<?> parent, View view, int position, long id) {
        UserEntity userEntity = contactList.get(position);
        String avatar = userEntity.getAvatar();
        int peerId = userEntity.getPeerId();
        Intent intent = new Intent(getActivity(), UserActivity.class);
        intent.putExtra("avatar",avatar);
        intent.putExtra("peerId",peerId);
        intent.putExtra("main_name",userEntity.getMainName());
        startActivity(intent);
    }
}
