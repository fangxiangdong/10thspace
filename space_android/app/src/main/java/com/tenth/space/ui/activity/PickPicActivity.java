package com.tenth.space.ui.activity;

import android.app.Activity;
import android.content.Intent;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.os.Bundle;
import android.util.Log;
import android.view.View;
import android.widget.AdapterView;
import android.widget.AdapterView.OnItemClickListener;
import android.widget.GridView;
import android.widget.TextView;

import com.tenth.space.R;
import com.tenth.space.app.ActivityManager;

import java.io.Serializable;
import java.util.List;


public class PickPicActivity extends Activity implements View.OnClickListener {
    // ArrayList<Entity> dataList;//用来装载数据源的列表
    List<ImageBucket> dataList;
    GridView gridView;
    ImageBucketAdapter adapter;// 自定义的适配器
    AlbumHelper helper;
    public static final String EXTRA_IMAGE_LIST = "imagelist";
    public static Bitmap bimap;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        // TODO Auto-generated method stub
        Log.i("PickPicActivity", "create");
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_image_bucket);

        //加入activity栈
        ActivityManager.getAppManager().addActivity(this);

        helper = AlbumHelper.getHelper();
        helper.init(getApplicationContext());

        initData();
        initView();
    }

    /**
     * 初始化数据
     */
    private void initData() {
        dataList = helper.getImagesBucketList(false);
        bimap = BitmapFactory.decodeResource(getResources(), R.drawable.icon_addpic_unfocused);
    }

    /**
     * 初始化view视图
     */
    private void initView() {
        gridView = (GridView) findViewById(R.id.gridview);
        TextView cancel = (TextView) findViewById(R.id.cancel_aldum);
        cancel.setOnClickListener(this);
        adapter = new ImageBucketAdapter(PickPicActivity.this, dataList);
        gridView.setAdapter(adapter);

        gridView.setOnItemClickListener(new OnItemClickListener() {
            @Override
            public void onItemClick(AdapterView<?> parent, View view, int position, long id) {
                Intent intent = new Intent(PickPicActivity.this, ImageGridActivity2.class);
                intent.putExtra(PickPicActivity.EXTRA_IMAGE_LIST, (Serializable) dataList.get(position).imageList);
                startActivity(intent);

                //放在下一个页面完成时，再finish()
//                finish();
            }

        });
    }

    @Override
    public void onClick(View v) {
        if(v.getId() == R.id.cancel_aldum){
            finish();
        }
    }
}
