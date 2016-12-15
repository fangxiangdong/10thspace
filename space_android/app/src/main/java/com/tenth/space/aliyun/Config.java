package com.tenth.space.aliyun;

import com.alibaba.sdk.android.oss.ClientConfiguration;
import com.tenth.space.utils.Utils;

/**
 * Created by wsq on 2016/10/28.
 */

public class Config {
    public  static String EndAliyun="";
    public static final String endpoint = "http://oss-cn-shenzhen.aliyuncs.com";
    public static final String endpointExtra = "http://maomaojiang.oss-cn-shenzhen.aliyuncs.com/";
    public static String pictrueUrl = "http://tenth.oss-cn-shenzhen.aliyuncs.com/" + Config.livePicsPath;//私有图片路径
    public static final String bucketName = "maomaojiang";
    public static final String privateBucketName = "tenth";
    public static final String tokenUrl = "http://www.10thcommune.com:86/sts";
    public static final String blogPicsPath = "im/blog/" + Utils.getCurrentYear() + "/" + Utils.getCurrentMonth() + "/";//此处用于给每年、每个月的图片添加一个文件夹，在上传图片的时候带上
    public static final String avatarPicsPath = "im/avatar/";//用户头像
    public static final String livePicsPath = "im/live/";//
    public static final String chatPicsPath = "im/chat/";//聊天过程中图片保存阿里云位置
    public static  String nameAndPaw="";//获取token所需的请求参数
    public  static boolean debug=true;
    public static ClientConfiguration conf;

    //阿里云网络配置
    public static ClientConfiguration getAliClientConf() {
        if (conf == null) {
            ClientConfiguration conf = new ClientConfiguration();
            //连接超时，默认15秒
            conf.setConnectionTimeout(15 * 1000);
            //socket超时，默认15秒
            conf.setSocketTimeout(15 * 1000);
            //最大并发请求书，默认5个
            conf.setMaxConcurrentRequest(10);
            //失败后最大重试次数，默认2次
            conf.setMaxErrorRetry(3);
            return conf;
        }
        return conf;
    }

    //getKEY_AES加密解密明文密钥
    public static String getKA() {
        StringBuffer sb = new StringBuffer();
        sb.append("smkldospdosldaaa");
        return sb.toString();
    }
    //getIV_AES
    public static String getKAIv() {
        StringBuffer sb = new StringBuffer();
        sb.append("0392039203920300");
        return sb.toString();
    }

}
