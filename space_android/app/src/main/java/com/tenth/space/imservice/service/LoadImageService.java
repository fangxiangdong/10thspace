package com.tenth.space.imservice.service;

import android.app.IntentService;
import android.content.Intent;
import android.graphics.Bitmap;
import android.text.TextUtils;

import com.alibaba.sdk.android.oss.OSSClient;
import com.alibaba.sdk.android.oss.model.PutObjectResult;
import com.tenth.space.aliyun.AliyunUpload;
import com.tenth.space.aliyun.Config;
import com.tenth.space.aliyun.STSGetter;
import com.tenth.space.app.IMApplication;
import com.tenth.space.config.SysConstant;
import com.tenth.space.imservice.entity.ImageMessage;
import com.tenth.space.imservice.event.MessageEvent;
import com.tenth.space.ui.helper.PhotoHelper;
import com.tenth.space.utils.FileUtil;
import com.tenth.space.utils.Logger;

import java.io.File;
import java.io.IOException;

import de.greenrobot.event.EventBus;

/**
 * @author : yingmu on 15-1-12.
 * @email : yingmu@mogujie.com.
 *
 */
public class LoadImageService extends IntentService {

    private static Logger logger = Logger.getLogger(LoadImageService.class);

    public LoadImageService(){
        super("LoadImageService");
    }

    public LoadImageService(String name) {
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
        ImageMessage messageInfo = (ImageMessage)intent.getSerializableExtra(SysConstant.UPLOAD_IMAGE_INTENT_PARAMS);
        String result = null;
        Bitmap bitmap;
        try {
            File file= new File(messageInfo.getPath());
            if(file.exists() && FileUtil.getExtensionName(messageInfo.getPath()).toLowerCase().equals(".gif"))
            {
               // MoGuHttpClient httpClient = new MoGuHttpClient();
               // SystemConfigSp.instance().init(getApplicationContext());
               // result = httpClient.uploadImage3(SystemConfigSp.instance().getStrConfig(SystemConfigSp.SysCfgDimension.MSFSSERVER), FileUtil.File2byte(messageInfo.getPath()), messageInfo.getPath());
                result=upLoadToAliYUN(FileUtil.File2byte(messageInfo.getPath()),result,messageInfo.getPath());
            }
            else
            {
                bitmap = PhotoHelper.revitionImage(messageInfo.getPath());
                if (null != bitmap) {
                    byte[] bytes = PhotoHelper.getBytes(bitmap);
                    result=upLoadToAliYUN(bytes,result,messageInfo.getPath());
                   // MoGuHttpClient httpClient = new MoGuHttpClient();
                   // byte[] bytes = PhotoHelper.getBytes(bitmap);
                    //此处上传到阿里云上url=http://120.25.229.33:8700/
                    // picturename=/storage/emulated/0/DCIM/Camera/IMG_20161116_190701.jpg
                   // result = httpClient.uploadImage3(SystemConfigSp.instance().getStrConfig(SystemConfigSp.SysCfgDimension.MSFSSERVER), bytes, messageInfo.getPath());
                }
            }

            if (TextUtils.isEmpty(result)) {
                logger.i("upload image faild,cause by result is empty/null");
                EventBus.getDefault().postSticky(new MessageEvent(MessageEvent.Event.IMAGE_UPLOAD_FAILD
                ,messageInfo));
            } else {
                logger.i("upload image succcess,imageUrl is %s",result);
                String imageUrl = result;
                messageInfo.setUrl(imageUrl);
                EventBus.getDefault().postSticky(new MessageEvent(
                        MessageEvent.Event.IMAGE_UPLOAD_SUCCESS
                        ,messageInfo));
            }
        } catch (IOException e) {
            logger.e(e.getMessage());
        }
    }
    private String upLoadToAliYUN(byte[] bytes,  String result,String picName) {
        //上传到aliyun服务器
       // OSSClient ossClient = new OSSClient(this, Config.endpoint, STSGetter.instance(), Config.getAliClientConf());
        OSSClient ossClient = IMApplication.app.GetGlobleOSSClent();
        final String imageName = picName;
        //构建上传请求
        PutObjectResult resul = new AliyunUpload(ossClient, Config.bucketName, Config.chatPicsPath + imageName, null, null, null).uploadBytes(bytes);
        int resultCode = resul.getStatusCode();
        if (resultCode==200){
            return result=Config.endpointExtra+Config.chatPicsPath + imageName;
        }else {
            return result=null;
        }
    }
}
