package com.tenth.space.imservice.service;

import android.app.IntentService;
import android.content.Intent;
import android.graphics.Bitmap;
import android.os.Handler;
import android.util.Log;

import com.alibaba.sdk.android.oss.OSSClient;
import com.alibaba.sdk.android.oss.model.PutObjectResult;
import com.tenth.space.aliyun.AliyunUpload;
import com.tenth.space.aliyun.Config;
import com.tenth.space.aliyun.STSGetter;
import com.tenth.space.app.IMApplication;
import com.tenth.space.config.SysConstant;
import com.tenth.space.imservice.entity.BlogMessage;
import com.tenth.space.imservice.event.BlogInfoEvent;
import com.tenth.space.imservice.manager.IMLoginManager;
import com.tenth.space.ui.helper.PhotoHelper;
import com.tenth.space.utils.Logger;

import java.io.File;
import java.util.ArrayList;
import java.util.List;

import de.greenrobot.event.EventBus;

/**
 * Created by neil.yi on 2016/10/18.
 */

public class LoadImageService2 extends IntentService {
    private static Logger logger = Logger.getLogger(LoadImageService2.class);
    private int uploadOk = 0;
    private int uploadErr = 1;
    private Handler mHandler = new Handler();

    public LoadImageService2() {
        super("LoadImageService2");
    }

    public LoadImageService2(String name) {
        super(name);
    }

    /**
     * This method is invoked on the worker thread with a request to process.
     * Only one Intent is processed at a time, but the processing happens on a
     * worker thread that runs independently from other application logic.
     * So, if this code takes a long time, it will hold up other requests to
     * the same IntentService, but it will not hold up anything else.
     * When all requests have been handled, the IntentService stops itself,
     * so you should not call {@link #stopSelf}.
     *
     * @param intent The value passed to {@link
     *               android.content.Context#startService(android.content.Intent)}.
     */
    @Override
    protected void onHandleIntent(Intent intent) {
        final BlogMessage blogInfo = (BlogMessage) intent.getSerializableExtra(SysConstant.UPLOAD_IMAGE_INTENT_PARAMS);
        String result = null;
        final List<String> upUrls = new ArrayList<String>();
        final List<String> pathList = blogInfo.getPathList();
        try {
            for (int i = 0; i < pathList.size(); i++) {
                Bitmap cusbitmap=null;
                File file = new File(pathList.get(i));
                if (file.exists()) {
                    //压缩图像，转呗bitmap,然后发送byte[]数组
                    cusbitmap=PhotoHelper.revitionImage(pathList.get(i));
                    byte[] bytes = PhotoHelper.getBytes(cusbitmap);//图片变为byte[]
                    //创建请求客户端
                 //   OSSClient ossClient = new OSSClient(this, Config.endpoint, STSGetter.instance(), Config.getAliClientConf());
                    OSSClient ossClient = IMApplication.app.GetGlobleOSSClent();
                    String currentTime = System.currentTimeMillis() + "";
                     String imageName = Config.blogPicsPath + IMLoginManager.instance().getLoginId()+currentTime + ".png";
                    //构建上传请求
                    PutObjectResult resultcode = new AliyunUpload(ossClient, Config.bucketName, imageName, null, null, null).uploadBytes(bytes);
                   Log.i("GTAG","imname="+Config.endpointExtra+imageName);
                    if (resultcode!=null&&resultcode.getStatusCode()==200){
                        //上传成功
                        upUrls.add(Config.endpointExtra +imageName);
                        uploadOk++;
                        if (uploadOk == pathList.size()) {//所有图片上传成功的通知
                            //Log.i("GTAG","上传完成");
                            blogInfo.setUrlList(upUrls);
                            mHandler.post(new Runnable() {
                                @Override
                                public void run() {
                                    //上传成功调用通知(接受通知在IMBlogManager接收)
                                    EventBus.getDefault().post(new BlogInfoEvent(BlogInfoEvent.Event.IMAGE_UPLOAD_SUCCESS, blogInfo));
                                }
                            });
                        }
                    }else {
                        //上传失败
                        if (uploadErr == 1) {//只执行一次(任意一张图片上传不成功的)
                            mHandler.post(new Runnable() {
                                @Override
                                public void run() {
                                    EventBus.getDefault().post(new BlogInfoEvent(BlogInfoEvent.Event.IMAGE_UPLOAD_FAILD));
                                    uploadErr = 0;
                                }
                            });
                        }
                    }


                }
            }

        } catch (Exception e) {
            logger.e(e.getMessage());
        }
    }
}
