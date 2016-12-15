package com.tenth.space.ui.activity;

import android.os.Bundle;

import com.tenth.space.R;
import com.tenth.space.imservice.manager.IMStackManager;
import com.tenth.space.imservice.service.IMService;
import com.tenth.space.ui.base.TTBaseFragmentActivity;

public class SearchActivity extends   TTBaseFragmentActivity {

	private IMService imService;

	@Override
	protected void onCreate(Bundle savedInstanceState) {
		// TODO Auto-generated method stub
		super.onCreate(savedInstanceState);
        IMStackManager.getStackManager().pushActivity(this);
		setContentView(R.layout.tt_fragment_activity_search);
	}

	@Override
	protected void onDestroy() {
		// TODO Auto-generated method stub
        IMStackManager.getStackManager().popActivity(this);
		super.onDestroy();
	}


}
