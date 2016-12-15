package com.tenth.space.aliyun;

import android.util.Log;

import com.alibaba.sdk.android.oss.common.OSSConstants;
import com.alibaba.sdk.android.oss.common.auth.OSSCredentialProvider;
import com.alibaba.sdk.android.oss.common.auth.OSSFederationCredentialProvider;
import com.alibaba.sdk.android.oss.common.auth.OSSFederationToken;
import com.alibaba.sdk.android.oss.common.utils.IOUtils;
import com.tenth.space.config.UrlConstant;
import com.tenth.space.utils.Utils;

import org.json.JSONObject;

import java.io.BufferedReader;
import java.io.DataOutputStream;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.net.HttpURLConnection;
import java.net.URL;
import java.net.URLEncoder;

/**
 * Created by Administrator on 2015/12/9 0009.
 * 重载OSSFederationCredentialProvider生成自己的获取STS的功能
 */
public class STSGetter extends OSSFederationCredentialProvider {

    static OSSCredentialProvider instance;

    @Override
    public OSSFederationToken getFederationToken() {
        try {
            String backString = getToken(Config.EndAliyun,Config.tokenUrl);
         //  InputStream input = conn.getInputStream();
         //   String jsonText = IOUtils.readStreamAsString(input, OSSConstants.DEFAULT_CHARSET_NAME);
           Log.i("GTAG","jsontext="+backString+"Config.EndAliyun="+Config.EndAliyun);
            if (!Utils.isStringEmpty(backString)){
                JSONObject jsonObjs = new JSONObject(backString);
                String ak = jsonObjs.optString("AccessKeyId");
                String sk = jsonObjs.optString("AccessKeySecret");
                String token = jsonObjs.optString("SecurityToken");
                String expiration = jsonObjs.optString("Expiration");
                int error_code = jsonObjs.optInt("error_code");
                if (error_code==0){
                    //成功后
                    return new OSSFederationToken(ak, sk, token, expiration);
                }else {
                    //从新获取toke
                    String temptoken = getToken(Config.nameAndPaw, UrlConstant.LOIN);
                    JSONObject object=new JSONObject(temptoken);
                    int recode = object.optInt("return_code");
                    if (recode==0){
                        Config.EndAliyun=object.optString("return_message");
                        getFederationToken();
                    }else {
                        return null;
                    }
                }

            }else {
                return null;
            }

        } catch (Exception e) {
            e.printStackTrace();
            //从新请求网络，获取返回值
        }
        return null;
    }

    synchronized public static OSSCredentialProvider instance() {
        if (instance == null) {
            instance = new STSGetter();
        }
        return instance;
    }



    public String getToken(String arg,String Url){
        try {
            URL stsUrl = new URL(Url);
            HttpURLConnection httpConn = (HttpURLConnection) stsUrl.openConnection();
            String param="arg="+ URLEncoder.encode(arg,"UTF-8");
            //设置参数
            httpConn.setDoOutput(true);   //需要输出
            httpConn.setDoInput(true);   //需要输入
            httpConn.setUseCaches(false);  //不允许缓存
            httpConn.setRequestMethod("POST");   //设置POST方式连接
            //设置请求属性
            httpConn.setRequestProperty("Content-Type", "application/x-www-form-urlencoded");
            httpConn.setRequestProperty("Connection", "Keep-Alive");// 维持长连接
            httpConn.setRequestProperty("Charset", "UTF-8");
            //连接,也可以不用明文connect，使用下面的httpConn.getOutputStream()会自动connect
            httpConn.connect();
            //建立输入流，向指向的URL传入参数
            DataOutputStream dos=new DataOutputStream(httpConn.getOutputStream());
            dos.writeBytes(param);
            dos.flush();
            dos.close();
            //获得响应状态
            int resultCode=httpConn.getResponseCode();
            StringBuffer sb = null;
            if(HttpURLConnection.HTTP_OK==resultCode){
                sb=new StringBuffer();
                String readLine=new String();
                BufferedReader responseReader=new BufferedReader(new InputStreamReader(httpConn.getInputStream(),"UTF-8"));
                while((readLine=responseReader.readLine())!=null){
                    sb.append(readLine).append("\n");
                }
                responseReader.close();
                return sb.toString();
            }
        }catch (Exception e){
            return "";
        }

        return "";
    }
}
