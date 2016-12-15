package com.tenth.space.aliyun;

import com.alibaba.sdk.android.oss.ClientException;
import com.alibaba.sdk.android.oss.OSS;
import com.alibaba.sdk.android.oss.ServiceException;
import com.alibaba.sdk.android.oss.callback.OSSCompletedCallback;
import com.alibaba.sdk.android.oss.callback.OSSProgressCallback;
import com.alibaba.sdk.android.oss.internal.OSSAsyncTask;
import com.alibaba.sdk.android.oss.model.PutObjectRequest;
import com.alibaba.sdk.android.oss.model.PutObjectResult;
import com.tenth.space.utils.LogUtils;

/**
 * Created by wsq on 2016/8/30.
 */
public class AliyunUpload {

    private OSS oss;
    private String bucket;
    private String objectKey;
    private String uploadFilePath;
    private OSSProgressCallback<PutObjectRequest> mProgressCallBack;
    private OSSCompletedCallback<PutObjectRequest, PutObjectResult> mOssCompletedCallback;
    private OSSAsyncTask mTask;

    public AliyunUpload(OSS client, String bucket, String objectKey, String uploadFilePath,
                        OSSProgressCallback<PutObjectRequest> progressCallBack,
                        OSSCompletedCallback<PutObjectRequest, PutObjectResult> ossCompletedCallback) {
        this.oss = client;
        this.bucket = bucket;
        this.objectKey = objectKey;
        this.uploadFilePath = uploadFilePath;
        this.mProgressCallBack = progressCallBack;
        this.mOssCompletedCallback = ossCompletedCallback;
    }

    // 从本地文件上传，使用非阻塞的异步接口
    public void asyncUpload() {
        // 构造上传请求
        PutObjectRequest put = new PutObjectRequest(bucket, objectKey, uploadFilePath);

        // 异步上传时可以设置进度回调
        put.setProgressCallback(mProgressCallBack);

        mTask = oss.asyncPutObject(put, mOssCompletedCallback);
//        try {
//            OSSResult result = mTask.getResult();
//
//
//        } catch (ClientException e) {
//            e.printStackTrace();
//        } catch (ServiceException e) {
//            e.printStackTrace();
//        }
    }

    //同步上传方法
    public void upload() {
        // 构造上传请求
        PutObjectRequest put = new PutObjectRequest(bucket, objectKey, uploadFilePath);

        // 异步上传时可以设置进度回调
        put.setProgressCallback(mProgressCallBack);

        try {
            PutObjectResult putObjectResult = oss.putObject(put);
            LogUtils.d(putObjectResult.getServerCallbackReturnBody() + "------------------" + putObjectResult.getETag());

        } catch (ClientException e) {
            e.printStackTrace();
        } catch (ServiceException e) {
            e.printStackTrace();
        }

//        mTask = oss.putObject(put, mOssCompletedCallback);
    }

    //同步上传方法
    public PutObjectResult uploadBytes(byte[] bytes) {
        // 构造上传请求
        PutObjectRequest put = new PutObjectRequest(bucket, objectKey, bytes);

        try {
            PutObjectResult putObjectResult = oss.putObject(put);
            LogUtils.d(putObjectResult.getServerCallbackReturnBody() + "------------------" + putObjectResult.getETag());

            return putObjectResult;
        } catch (ClientException e) {
            e.printStackTrace();
            return null;
        } catch (ServiceException e) {
            e.printStackTrace();
            return null;
        }

//        mTask = oss.putObject(put, mOssCompletedCallback);
    }

//        可撤销一次任务
//        task.cancel();
//        可以等待直到任务完成
//        task.waitUntilFinished();
//    请求结果等待
}
