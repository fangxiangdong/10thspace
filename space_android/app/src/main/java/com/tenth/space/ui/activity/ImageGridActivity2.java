package com.tenth.space.ui.activity;

import android.app.Activity;
import android.graphics.Color;
import android.graphics.drawable.ColorDrawable;
import android.os.Bundle;
import android.os.Handler;
import android.os.Message;
import android.view.View;
import android.view.View.OnClickListener;
import android.widget.AdapterView;
import android.widget.AdapterView.OnItemClickListener;
import android.widget.Button;
import android.widget.GridView;
import android.widget.TextView;
import android.widget.Toast;

import com.tenth.space.R;
import com.tenth.space.app.ActivityManager;
import com.tenth.space.ui.activity.ImageGridAdapter.TextCallback;
import com.tenth.space.utils.Bimp;
import com.tenth.space.utils.LogUtils;

import java.util.ArrayList;
import java.util.Collection;
import java.util.Iterator;
import java.util.List;

public class ImageGridActivity2 extends Activity implements OnClickListener {
    public static final String EXTRA_IMAGE_LIST = "imagelist";

    // ArrayList<Entity> dataList;//鐢ㄦ潵瑁呰浇鏁版嵁婧愮殑鍒楄〃
    List<ImageItem> dataList;
    GridView gridView;
    ImageGridAdapter adapter;// 鑷畾涔夌殑閫傞厤鍣�
    AlbumHelper helper;
    Button mSubmit;

    Handler mHandler = new Handler() {
        @Override
        public void handleMessage(Message msg) {
            switch (msg.what) {
                case 0:
                    Toast.makeText(ImageGridActivity2.this, "最多选择9张图片", Toast.LENGTH_SHORT).show();
                    break;

                default:
                    break;
            }
        }
    };

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_image_grid);

        helper = AlbumHelper.getHelper();
        helper.init(getApplicationContext());

        dataList = (List<ImageItem>) getIntent().getSerializableExtra(EXTRA_IMAGE_LIST);

        initView();

        TextView cancel = (TextView) findViewById(R.id.album_sub_cancel);
        cancel.setOnClickListener(this);
        mSubmit = (Button) findViewById(R.id.bt);
        mSubmit.setOnClickListener(new OnClickListener() {
            public void onClick(View v) {
                //定义集合
                ArrayList<String> list = new ArrayList<>();
                //获取选中的图
                Collection<String> c = adapter.map.values();
                LogUtils.d("ImageGridActivity2-----选图片时，点击完成:adapter.map.values().size():" + c.size());
                Iterator<String> it = c.iterator();

                //存储在定义的集合中
                for (; it.hasNext(); ) {
                    list.add(it.next());
                }

                //遍历集合，添加到BimP中
                for (int i = 0; i < list.size(); i++) {
                    if (Bimp.bmpPaths.size() < 9) {
                        Bimp.bmpPaths.add(list.get(i));
                        Bimp.cnt++;
                        LogUtils.d("Bimp.bmpPaths.size():" + Bimp.bmpPaths.size() + "---Bimp.cnt:" + Bimp.cnt);
                    }
                }

                addPicsFinish();

//                if (Bimp.act_bool) {
////                    //此处不重启activity，只是把当前的关闭，之前的AddBlogActivity界面刷新数据即可
////                    addPicsFinish();
//                    Intent intent = new Intent(ImageGridActivity2.this, AddBlogActivity.class);
//                    startActivity(intent);
//                    Bimp.act_bool = false;
//                }
            }

        });
    }

    @Override
    public void onClick(View v) {
        if (v.getId() == R.id.album_sub_cancel) {
            finish();
        }
    }

    //完成，则同时finish上一个页面
    private void addPicsFinish() {
        ActivityManager.getAppManager().finishActivity(PickPicActivity.class);
        finish();
    }

    private void initView() {
        gridView = (GridView) findViewById(R.id.gridview);
        gridView.setSelector(new ColorDrawable(Color.TRANSPARENT));
        adapter = new ImageGridAdapter(ImageGridActivity2.this, dataList, mHandler);
        gridView.setAdapter(adapter);
        adapter.setTextCallback(new TextCallback() {
            public void onListen(int count) {
                mSubmit.setText("完成" + "(" + count + ")");
            }
        });

        gridView.setOnItemClickListener(new OnItemClickListener() {
            @Override
            public void onItemClick(AdapterView<?> parent, View view, int position, long id) {
                adapter.notifyDataSetChanged();
            }

        });

    }
}
