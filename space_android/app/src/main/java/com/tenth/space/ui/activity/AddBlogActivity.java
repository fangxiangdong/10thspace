package com.tenth.space.ui.activity;

import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.graphics.drawable.BitmapDrawable;
import android.net.Uri;
import android.os.Bundle;
import android.os.Environment;
import android.provider.MediaStore;
import android.util.Log;
import android.view.Gravity;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.ViewGroup.LayoutParams;
import android.view.animation.AnimationUtils;
import android.view.inputmethod.InputMethodManager;
import android.widget.AdapterView;
import android.widget.Button;
import android.widget.EditText;
import android.widget.GridView;
import android.widget.ImageButton;
import android.widget.LinearLayout;
import android.widget.PopupWindow;
import android.widget.TextView;
import android.widget.Toast;

import com.tenth.space.R;
import com.tenth.space.imservice.entity.BlogMessage;
import com.tenth.space.imservice.event.BlogInfoEvent;
import com.tenth.space.imservice.service.IMService;
import com.tenth.space.imservice.support.IMServiceConnector;
import com.tenth.space.moments.AddBlogPicsAdapter;
import com.tenth.space.utils.Bimp;
import com.tenth.space.utils.LogUtils;
import com.tenth.space.utils.Logger;
import com.tenth.space.utils.ToastUtils;
import com.tenth.space.utils.Utils;

import java.io.File;

import butterknife.BindView;
import butterknife.ButterKnife;
import de.greenrobot.event.EventBus;

import static com.tenth.space.R.id.activity_selectimg_send;
import static com.tenth.space.R.id.blog_content;
import static com.tenth.space.utils.Bimp.bmp;

public class AddBlogActivity extends Activity {

    @BindView(R.id.activity_selectimg_send)
    TextView mActivitySelectimgSend;
    @BindView(blog_content)
    EditText mBlogContent;
    @BindView(R.id.noScrollgridview)
    GridView mNoScrollgridview;
    @BindView(R.id.cancel)
    ImageButton mcancel;
    @BindView(R.id.ll_progress_bar)
    LinearLayout ll_progress_bar;
    private AddBlogPicsAdapter adapter;

    private IMService imService;

    private Logger logger = Logger.getLogger(AddBlogActivity.class);

    private IMServiceConnector imServiceConnector = new IMServiceConnector() {
        @Override
        public void onIMServiceConnected() {
            logger.i("message_activity#onIMServiceConnected");
            imService = imServiceConnector.getIMService();
        }

        @Override
        public void onServiceDisconnected() {
        }
    };
    private View mInflate;

    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_selectimg);
        ButterKnife.bind(this);

        initView();

        //数据更新放于onResume中
//        initData();

        EventBus.getDefault().register(this);
        imServiceConnector.connect(this);
    }

    private void initView() {
        mInflate = View.inflate(this, R.layout.activity_selectimg, null);
        mcancel.setOnClickListener(new OnClickListener() {
            @Override
            public void onClick(View v) {
                finish();
            }
        });

        adapter = new AddBlogPicsAdapter(this);
//        adapter.update();
        mNoScrollgridview.setAdapter(adapter);
        mNoScrollgridview.setOnItemClickListener(new AdapterView.OnItemClickListener() {

            public void onItemClick(AdapterView<?> parent, View view, int position, long id) {
                if (position == bmp.size()) {//最后一张，添加新图片
                    hideSoftInput();
                    new PopupWindows(AddBlogActivity.this, mInflate);
                } else {//点击查看大图
                    Intent intent = new Intent(AddBlogActivity.this, PhotoActivity.class);
                    intent.putExtra("ID", position);
                    startActivity(intent);
                }
            }
        });
        mActivitySelectimgSend = (TextView) findViewById(activity_selectimg_send);
        mActivitySelectimgSend.setOnClickListener(new OnClickListener() {
            public void onClick(View v) {
                /*List<String> list = new ArrayList<String>();
                for (int i = 0; i < Bimp.bmpPaths.size(); i++) {
					String Str = Bimp.bmpPaths.get(i).substring(
							Bimp.bmpPaths.get(i).lastIndexOf("/") + 1,
							Bimp.bmpPaths.get(i).lastIndexOf("."));
					list.add(FileUtils.SDPATH+Str+".JPEG");
				}*/
                // 高清的压缩图片全部就在  list 路径里面了
                // 高清的压缩过的 bmp 对象  都在 Bimp.bmp里面
                // 完成上传服务器后 .........

                String content = mBlogContent.getText().toString();
                LogUtils.d(content);

                BlogMessage blog = BlogMessage.buildForSend(content, Bimp.bmpPaths);
                if (!Utils.isStringEmpty(content) || !(Bimp.bmpPaths.size() == 0)) {
                    //显示加载进度
                    ll_progress_bar.setVisibility(View.VISIBLE);
                    mActivitySelectimgSend.setEnabled(false);//防止多次点击上传
                    imService.getBlogManager().sendBlogCmd(blog);
                    FileUtils.deleteDir();

//                暂时关闭
//                ToastUtils.show("");
                    LogUtils.d("开始发表:activity.AddBlogActivity");
//                finish();
                } else {
                    ToastUtils.show("还没有编辑内容哦");
                }
            }
        });
    }

    private void hideSoftInput() {
        InputMethodManager imm = (InputMethodManager) getSystemService(Context.INPUT_METHOD_SERVICE);
        imm.hideSoftInputFromWindow(mBlogContent.getWindowToken(), 0);
    }

    @Override
    protected void onResume() {
        super.onResume();

        LogUtils.d("AddBlogActivity------onResume:刷新添加的图片");
        initData();
    }

    public void initData() {
        adapter.update();
    }

    public String getString(String s) {
        String path = null;
        if (s == null)
            return "";
        for (int i = s.length() - 1; i > 0; i++) {
            s.charAt(i);
        }
        return path;
    }

    public class PopupWindows extends PopupWindow {

        public PopupWindows(Context mContext, View parent) {

            View view = View.inflate(mContext, R.layout.item_popupwindows, null);
            setContentView(view);
            setWidth(LayoutParams.MATCH_PARENT);
            setHeight(LayoutParams.MATCH_PARENT);

            view.startAnimation(AnimationUtils.loadAnimation(mContext, R.anim.fade_ins));
            LinearLayout ll_hide = (LinearLayout) view.findViewById(R.id.ll_hide);
            ll_hide.setOnClickListener(new OnClickListener() {
                @Override
                public void onClick(View v) {
                    dismiss();
                }
            });
            LinearLayout ll_popup = (LinearLayout) view.findViewById(R.id.ll_popup);
            ll_popup.startAnimation(AnimationUtils.loadAnimation(mContext, R.anim.push_bottom_in_2));

            setFocusable(true);
            setOutsideTouchable(true);
            setBackgroundDrawable(new BitmapDrawable());
            showAtLocation(parent, Gravity.BOTTOM, 0, 0);
            update();

            Button bt1 = (Button) view.findViewById(R.id.item_popupwindows_camera);
            Button bt2 = (Button) view.findViewById(R.id.item_popupwindows_Photo);
            Button bt3 = (Button) view.findViewById(R.id.item_popupwindows_cancel);
            bt1.setOnClickListener(new OnClickListener() {
                public void onClick(View v) {
                    photo();
                    dismiss();
                }
            });
            bt2.setOnClickListener(new OnClickListener() {
                public void onClick(View v) {
                    Intent intent = new Intent(AddBlogActivity.this, PickPicActivity.class);
                    startActivity(intent);
                    dismiss();
                }
            });
            bt3.setOnClickListener(new OnClickListener() {
                public void onClick(View v) {
                    dismiss();
                }
            });
        }
    }

    private static final int TAKE_PICTURE = 0x000000;
    private String path = "";

    //拍照
    public void photo() {
        Intent openCameraIntent = new Intent(MediaStore.ACTION_IMAGE_CAPTURE);
        File parentfile=new File(Environment.getExternalStorageDirectory()+"/IMimage/");
        if (!parentfile.exists()){
            parentfile.mkdirs();
        }
       File file = new File(parentfile, String.valueOf(System.currentTimeMillis()) + ".png");
        path = file.getPath();
        Uri imageUri = Uri.fromFile(file);
        openCameraIntent.putExtra(MediaStore.EXTRA_OUTPUT, imageUri);
        startActivityForResult(openCameraIntent, TAKE_PICTURE);
    }

    protected void onActivityResult(int requestCode, int resultCode, Intent data) {
        Log.i("GTAG","back");
        switch (requestCode) {
            case TAKE_PICTURE:
                if (Bimp.bmpPaths.size() < 9 && resultCode == -1) {
                    Bimp.bmpPaths.add(path);
                    Bimp.cnt++;
                }
                break;
        }
    }

    public void onEventMainThread(BlogInfoEvent event) {
        switch (event.getEvent()) {

            case HANDLER_IMAGE_UPLOAD_SUCCESS:
                //ImageMessage imageMessage = (ImageMessage) event.getMessageEntity();
                //adapter.updateItemState(imageMessage);
                break;

            case ACK_SEND_BLOG_OK:
                mActivitySelectimgSend.setEnabled(true);
                ll_progress_bar.setVisibility(View.GONE);
                Toast.makeText(this, "日志发送成功", Toast.LENGTH_SHORT).show();
////                每次发送完成清空Bimp数据
//                Bimp.cnt = 0;
//                Bimp.bmpPaths.clear();
//                Bimp.bmp.clear();
                finish();
                break;

            case ACK_SEND_BLOG_FAILURE:
                mActivitySelectimgSend.setEnabled(true);
                ll_progress_bar.setVisibility(View.GONE);
                Toast.makeText(this, "发送失败，查看你的账号是否掉线", Toast.LENGTH_SHORT).show();
                break;

            case ACK_SEND_BLOG_TIME_OUT:
                mActivitySelectimgSend.setEnabled(true);
                ll_progress_bar.setVisibility(View.GONE);
                Toast.makeText(this, "日志发送失败，检查网络", Toast.LENGTH_SHORT).show();
                break;
        }
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();
        imServiceConnector.disconnect(this);
        EventBus.getDefault().unregister(this);

//        每次发送完成清空Bimp数据
        Bimp.cnt = 0;
        Bimp.bmpPaths.clear();
        bmp.clear();
    }

}
