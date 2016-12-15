package com.tenth.space.ui.fragment;

import android.content.Context;
import android.content.Intent;
import android.graphics.Bitmap;
import android.graphics.Color;
import android.graphics.drawable.BitmapDrawable;
import android.net.Uri;
import android.os.Bundle;
import android.os.Environment;
import android.os.Handler;
import android.provider.MediaStore;
import android.util.Log;
import android.view.Gravity;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.view.animation.AnimationUtils;
import android.widget.Button;
import android.widget.EditText;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.PopupWindow;
import android.widget.RadioButton;
import android.widget.TextView;

import com.alibaba.sdk.android.oss.ClientException;
import com.alibaba.sdk.android.oss.OSSClient;
import com.alibaba.sdk.android.oss.ServiceException;
import com.alibaba.sdk.android.oss.callback.OSSCompletedCallback;
import com.alibaba.sdk.android.oss.callback.OSSProgressCallback;
import com.alibaba.sdk.android.oss.model.PutObjectRequest;
import com.alibaba.sdk.android.oss.model.PutObjectResult;
import com.google.protobuf.ByteString;
import com.nostra13.universalimageloader.core.listener.SimpleImageLoadingListener;
import com.tenth.space.DB.DBInterface;
import com.tenth.space.DB.entity.UserEntity;
import com.tenth.space.R;
import com.tenth.space.aliyun.AliyunUpload;
import com.tenth.space.aliyun.Config;
import com.tenth.space.aliyun.STSGetter;
import com.tenth.space.app.IMApplication;
import com.tenth.space.config.DBConstant;
import com.tenth.space.config.IntentConstant;
import com.tenth.space.imservice.event.PriorityEvent;
import com.tenth.space.imservice.event.UserInfoEvent;
import com.tenth.space.imservice.manager.IMBuddyManager;
import com.tenth.space.imservice.manager.IMLoginManager;
import com.tenth.space.imservice.manager.IMSocketManager;
import com.tenth.space.imservice.service.IMService;
import com.tenth.space.imservice.support.IMServiceConnector;
import com.tenth.space.protobuf.IMBaseDefine;
import com.tenth.space.protobuf.IMBuddy;
import com.tenth.space.ui.activity.DetailPortraitActivity;
import com.tenth.space.utils.FileUtil;
import com.tenth.space.utils.IMUIHelper;
import com.tenth.space.utils.ImageLoaderUtil;
import com.tenth.space.utils.LogUtils;
import com.tenth.space.utils.OkHttpUtils;
import com.tenth.space.utils.ToastUtils;
import com.tenth.space.utils.Utils;

import java.io.File;
import java.util.ArrayList;

import de.greenrobot.event.EventBus;

import static android.app.Activity.RESULT_OK;
import static android.media.MediaRecorder.VideoSource.CAMERA;
import static android.os.Build.VERSION_CODES.M;
import static com.tenth.space.R.id.msg;
import static com.tenth.space.imservice.event.UserInfoEvent.Event.USER_INFO_UPDATE;

/**
 * 1.18 添加currentUser变量
 */
public class UserInfoFragment extends MainFragment {

    private static final int FROM_CAMERA = 1;
    private static final int FROM_ALBUM = 2;
    private View curView = null;
    private IMService imService;
    private UserEntity currentUser;
    private int currentUserId;


    private IMServiceConnector imServiceConnector = new IMServiceConnector() {
        @Override
        public void onIMServiceConnected() {
            logger.i("detail#onIMServiceConnected");

            imService = imServiceConnector.getIMService();
            if (imService == null) {
                logger.e("detail#imService is null");
                return;
            }

            currentUserId = getActivity().getIntent().getIntExtra(IntentConstant.KEY_PEERID, 0);
            if (currentUserId == 0) {
                logger.e("detail#intent params error!!");
                return;
            }
            currentUser = imService.getContactManager().findContact(currentUserId);
            if (currentUser != null) {
                initBaseProfile();
                initDetailProfile();
            }
            ArrayList<Integer> userIds = new ArrayList<>(1);
            //just single type
            userIds.add(currentUserId);
            imService.getContactManager().reqGetDetaillUsers(userIds);
        }

        @Override
        public void onServiceDisconnected() {
        }
    };
    private Uri mUri;
    private ImageView portraitImageView;

    @Override
    public void onDestroyView() {
        super.onDestroyView();
        imServiceConnector.disconnect(getActivity());
    }

    @Override
    public void onDestroy() {
        super.onDestroy();
        EventBus.getDefault().unregister(this);
    }

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {

        imServiceConnector.connect(getActivity());
        if (null != curView) {
            ((ViewGroup) curView.getParent()).removeView(curView);
            return curView;
        }
        curView = inflater.inflate(R.layout.tt_fragment_user_detail, topContentView);
        super.init(curView);
        showProgressBar();
        initRes();
        EventBus.getDefault().register(this);
        return curView;
    }

    @Override
    public void onResume() {
        Intent intent = getActivity().getIntent();
        if (null != intent) {
            String fromPage = intent.getStringExtra(IntentConstant.USER_DETAIL_PARAM);
            setTopLeftText(fromPage);
        }
        super.onResume();
    }

    /**
     * @Description 初始化资源
     */
    private void initRes() {
        // 设置标题栏
        setTopTitle(getActivity().getString(R.string.page_user_detail));
        setTopLeftButton(R.drawable.tt_top_back);
        topLeftContainerLayout.setOnClickListener(new View.OnClickListener() {

            @Override
            public void onClick(View arg0) {
                getActivity().finish();
            }
        });
        topLetTitleTxt.setTextColor(getResources().getColor(R.color.default_bk));
        setTopLeftText(getResources().getString(R.string.top_left_back));
        final EditText signature = (EditText) curView.findViewById(R.id.et_signature);
        final RadioButton gender = (RadioButton) curView.findViewById(R.id.rb_man);
        final EditText nickName = (EditText) curView.findViewById(R.id.nickName);
        final EditText phone = (EditText) curView.findViewById(R.id.et_phone);
        curView.findViewById(R.id.tv_logo).setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                IMBaseDefine.UserInfo userInfo = IMBaseDefine.UserInfo.newBuilder()
                        .setUserId(IMLoginManager.instance().getLoginId())
                        .setSignInfo(signature.getText().toString())
                        .setUserGender(gender.isChecked()?1:2)
                        .setUserNickName(nickName.getText().toString())
                        .setUserTel(phone.getText().toString())
                        .setAvatarUrl("")
                        .setDepartmentId(0)
                        .setUserRealName("")
                        .setUserDomain("")
                        .setStatus(0)
                        .setEmail("")
                        .build();
                IMBuddy.IMUpdateUsersInfoReq msg = IMBuddy.IMUpdateUsersInfoReq.newBuilder()
                        .setUserInfo(userInfo)
                        .setUserId(IMLoginManager.instance().getLoginId() )
                        .build();
                int sid = IMBaseDefine.ServiceID.SID_BUDDY_LIST_VALUE;
                int cid = IMBaseDefine.BuddyListCmdID.CID_BUDDY_LIST_UPDATE_USER_INFO_REQUEST_VALUE;
                IMSocketManager.instance().sendRequest(msg, sid, cid);
            }
        });
    }

    @Override
    protected void initHandler() {
    }

    public void onEventMainThread(UserInfoEvent.Event event) {
        switch (event) {
            case USER_INFO_UPDATE:
                UserEntity entity = imService.getContactManager().findContact(currentUserId);
                if (entity != null && currentUser.equals(entity)) {
                    initBaseProfile();
                    initDetailProfile();
                }
        }
    }
    public void onEventMainThread(PriorityEvent event) {
        switch (event.event) {
            case MSG_UPDATE_USERINFO_SUCEED:
                IMBuddy.IMUpdateUsersInfoRsp obj = (IMBuddy.IMUpdateUsersInfoRsp)event.object;
                int resultCode = obj.getResultCode();
                if(resultCode==0)
                ToastUtils.show("个人信息提交成功");
        }
    }


    private void initBaseProfile() {
         portraitImageView = (ImageView) curView.findViewById(R.id.user_portrait);
        setTextViewContent(R.id.nickName, currentUser.getMainName());
        setTextViewContent(R.id.fans_cnt, currentUser.getFansCnt()+"");
//        setTextViewContent(R.id.userName, currentUser.getRealName());
        //头像设置
       ImageLoaderUtil.instance().displayImage(IMApplication.app.UrlFormat(currentUser.getAvatar()), portraitImageView, ImageLoaderUtil.getAvatarOptions(20, 0));
        portraitImageView.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                if (currentUserId == imService.getLoginManager().getLoginId()) {
                    //本人打开编辑
                    new MyPopupWindows(getActivity(), curView, currentUser.getAvatar());
                } else {
                    //别人，只有预览
                    if (!Utils.isStringEmpty(currentUser.getAvatar())) {
                        //缩放预览
                        Intent intent = new Intent(getActivity(), DetailPortraitActivity.class);
                        intent.putExtra(IntentConstant.KEY_AVATAR_URL, currentUser.getAvatar());
                        intent.putExtra(IntentConstant.KEY_IS_IMAGE_CONTACT_AVATAR, true);
                        startActivity(intent);
                    } else {
                        //提示
                        ToastUtils.show("该用户没有添加头像");
                    }
                }
            }
        });

        // 设置界面信息
//        Button chatBtn = (Button) curView.findViewById(R.id.chat_btn);
//        if (currentUserId == imService.getLoginManager().getLoginId()) {
//            chatBtn.setVisibility(View.GONE);
//        } else {
//            chatBtn.setOnClickListener(new View.OnClickListener() {
//                @Override
//                public void onClick(View arg0) {
//                    String sessionKey = currentUser.getSessionKey();
//                    IMUIHelper.openChatActivity(getActivity(), sessionKey);
//                    getActivity().finish();
//                }
//            });
//
//        }
    }

    private void openCamera() {
        String sdStatus = Environment.getExternalStorageState();
        // 检测sd卡是否可用
        if (!sdStatus.equals(Environment.MEDIA_MOUNTED)) {
            ToastUtils.show("请检查SD卡是否可用");
            return;
        } else {
            String path = Environment.getExternalStorageDirectory() + "/IM";
            File file1 = new File(path);
            if (!file1.exists()) {
                file1.mkdirs();
            }

            File file = new File(file1, "userAvatar.png");
            mUri = Uri.fromFile(file);

            Intent intent = new Intent(MediaStore.ACTION_IMAGE_CAPTURE);
            intent.putExtra(MediaStore.EXTRA_OUTPUT, mUri);// 指定调用相机拍照后的照片存储的路径
            startActivityForResult(intent, CAMERA);
        }
    }

    private void openAlbum() {
        // 激活系统图库，选择一张图片
        Intent intent = new Intent(Intent.ACTION_PICK,android.provider.MediaStore.Images.Media.EXTERNAL_CONTENT_URI);
        //intent.setType("image/*");
        startActivityForResult(intent, FROM_ALBUM);
    }

    @Override
    public void onActivityResult(int requestCode, int resultCode, Intent data) {
        super.onActivityResult(requestCode, resultCode, data);
        if (requestCode == CAMERA && resultCode == RESULT_OK) {//拍照返回
            String encodedPath = mUri.getEncodedPath();
            ToastUtils.show("上传中...");
            showProgressBar();
            uploadALiYun(encodedPath);
        } else if (requestCode == FROM_ALBUM&& null != data&& resultCode == RESULT_OK) {//相册选择
            Uri uri = data.getData();
            String filePath = FileUtil.getFilePathFromContentUri(uri, getActivity().getContentResolver());
            ToastUtils.show("上传中...");
            showProgressBar();
            uploadALiYun(filePath);
        }
    }


    private void uploadALiYun(final String path) {
        //Log.i("GTAG","path="+path);
       // OSSClient ossClient = new OSSClient(getActivity(), Config.endpoint, STSGetter.instance(), Config.getAliClientConf());
        OSSClient ossClient = IMApplication.app.GetGlobleOSSClent();
        final String imageName = Config.avatarPicsPath + currentUserId + ".png";
        new AliyunUpload(
                ossClient,
                Config.bucketName,
                imageName,
                path,
                new OSSProgressCallback<PutObjectRequest>() {
                    @Override
                    public void onProgress(PutObjectRequest putObjectRequest, long currentSize, long totalSize) {
//                        LogUtils.d("上传进度:" + currentSize + "/" + totalSize);
                    }
                },
                new OSSCompletedCallback<PutObjectRequest, PutObjectResult>() {
                    @Override
                    public void onSuccess(PutObjectRequest putObjectRequest, PutObjectResult putObjectResult) {
                        String url = Config.endpointExtra + imageName;

                        //上传到IM服务器
                        IMBuddyManager.instance().reqChangeAvatar(ByteString.copyFromUtf8(url));
                        hideProgressBar();
                        //清除本地缓存和内存缓存
                       Utils.clearDiskAndMemoryCache(IMApplication.app.UrlFormat(url),true,true);
                        EventBus.getDefault().postSticky(USER_INFO_UPDATE);
                        //改变自己的头像
                        getActivity().runOnUiThread(new Runnable() {
                            @Override
                            public void run() {
                                ImageLoaderUtil.instance().displayImage("file:/" +IMApplication.app.UrlFormat(path),portraitImageView);
                            }
                        });
                    }

                    @Override
                    public void onFailure(PutObjectRequest putObjectRequest, ClientException e, ServiceException e1) {
                        ToastUtils.show("上传头像失败");
                        hideProgressBar();
                    }
                }).asyncUpload();
    }

    private void initDetailProfile() {
        logger.i("detail#initDetailProfile");
        hideProgressBar();
//        setTextViewContent(R.id.telno, currentUser.getPhone());
//        setTextViewContent(R.id.email, currentUser.getEmail());
//        View phoneView = curView.findViewById(R.id.phoneArea);
//        View emailView = curView.findViewById(R.id.emailArea);
//        IMUIHelper.setViewTouchHightlighted(phoneView);
//        IMUIHelper.setViewTouchHightlighted(emailView);

//        emailView.setOnClickListener(new View.OnClickListener() {
//            @Override
//            public void onClick(View view) {
//                if (currentUserId == IMLoginManager.instance().getLoginId())
//                    return;
//                IMUIHelper.showCustomDialog(getActivity(), View.GONE, String.format(getString(R.string.confirm_send_email), currentUser.getEmail()), new IMUIHelper.dialogCallback() {
//                    @Override
//                    public void callback() {
//                        Intent data = new Intent(Intent.ACTION_SENDTO);
//                        data.setData(Uri.parse("mailto:" + currentUser.getEmail()));
//                        data.putExtra(Intent.EXTRA_SUBJECT, "");
//                        data.putExtra(Intent.EXTRA_TEXT, "");
//                        startActivity(data);
//                    }
//                });
//            }
//        });

//        phoneView.setOnClickListener(new View.OnClickListener() {
//            @Override
//            public void onClick(View v) {
//                if (currentUserId == IMLoginManager.instance().getLoginId())
//                    return;
//                IMUIHelper.showCustomDialog(getActivity(), View.GONE, String.format(getString(R.string.confirm_dial), currentUser.getPhone()), new IMUIHelper.dialogCallback() {
//                    @Override
//                    public void callback() {
//                        new Handler().postDelayed(new Runnable() {
//                            @Override
//                            public void run() {
//                                IMUIHelper.callPhone(getActivity(), currentUser.getPhone());
//                            }
//                        }, 0);
//                    }
//                });
//            }
//        });
//设置性别，暂时取消
      //  setSex(currentUser.getGender());
    }

    private void setTextViewContent(int id, String content) {
        TextView textView = (TextView) curView.findViewById(id);
        if (textView == null || content == null) {
            return;
        } else {
            textView.setText(content);
        }


    }

//    private void setSex(int sex) {
//        if (curView == null) {
//            return;
//        }
//
//        TextView sexTextView = (TextView) curView.findViewById(R.id.sex);
//        if (sexTextView == null) {
//            return;
//        }
//
//        int textColor = Color.rgb(255, 138, 168); //xiaoxian
//        String text = getString(R.string.sex_female_name);
//
//        if (sex == DBConstant.SEX_MAILE) {
//            textColor = Color.rgb(144, 203, 1);
//            text = getString(R.string.sex_male_name);
//        }
//
//        sexTextView.setVisibility(View.VISIBLE);
//        sexTextView.setText(text);
//        sexTextView.setTextColor(textColor);
//    }

    public class MyPopupWindows extends PopupWindow {

        public MyPopupWindows(Context mContext, View parent, final String avatar) {
            View view = View.inflate(mContext, R.layout.popup_avatar, null);
            setContentView(view);
            view.startAnimation(AnimationUtils.loadAnimation(mContext, R.anim.fade_ins));
            LinearLayout ll_popup = (LinearLayout) view.findViewById(R.id.ll_popup);
            ll_popup.startAnimation(AnimationUtils.loadAnimation(mContext, R.anim.push_bottom_in_2));
            View hideArea = (View) view.findViewById(R.id.v_hide);
            hideArea.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View v) {
                    dismiss();
                }
            });

            setWidth(ViewGroup.LayoutParams.MATCH_PARENT);
            setHeight(ViewGroup.LayoutParams.MATCH_PARENT);

            setFocusable(true);
            setOutsideTouchable(true);
            setBackgroundDrawable(new BitmapDrawable());
            showAtLocation(parent, Gravity.BOTTOM, 0, 0);
            update();

            Button bt1 = (Button) view.findViewById(R.id.btn_pre);
            final Button bt2 = (Button) view.findViewById(R.id.btn_camera);
            final Button bt3 = (Button) view.findViewById(R.id.btn_album);
            bt1.setOnClickListener(new View.OnClickListener() {
                public void onClick(View v) {
                    if (!Utils.isStringEmpty(avatar)) {
                        //缩放预览
                        Intent intent = new Intent(getActivity(), DetailPortraitActivity.class);
                        intent.putExtra(IntentConstant.KEY_AVATAR_URL, avatar);
                        intent.putExtra(IntentConstant.KEY_IS_IMAGE_CONTACT_AVATAR, true);
                        startActivity(intent);
                    } else {
                        //提示
                        ToastUtils.show("你还没有添加头像");
                    }
                    dismiss();
                }
            });
            bt2.setOnClickListener(new View.OnClickListener() {
                public void onClick(View v) {
                    openCamera();
                    dismiss();
                }
            });
            bt3.setOnClickListener(new View.OnClickListener() {
                public void onClick(View v) {
                    openAlbum();
                    dismiss();
                }
            });
        }
    }
}
