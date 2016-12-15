package com.tenth.space.utils.pinyin;


import com.tenth.space.aliyun.Config;

import javax.crypto.Cipher;
import javax.crypto.spec.IvParameterSpec;
import javax.crypto.spec.SecretKeySpec;

/**
 * Created by wsq on 2016/9/9.
 */
public class AESUtils {
    private static String ivParameter = Config.getKAIv();//偏移量,可自行修改


    // 加密
    public static String encrypt(String sSrc, String sKey) {
        if (sSrc == null || sSrc == null)
            return null;
        Cipher cipher = null;
        try {
            cipher = Cipher.getInstance("AES/CBC/PKCS5Padding");
            byte[] raw = sKey.getBytes();
            SecretKeySpec skeySpec = new SecretKeySpec(raw, "AES");
            IvParameterSpec iv = new IvParameterSpec(ivParameter.getBytes());// 使用CBC模式，需要一个向量iv，可增加加密算法的强度
            cipher.init(Cipher.ENCRYPT_MODE, skeySpec, iv);
            byte[] encrypted = cipher.doFinal(sSrc.getBytes("utf-8"));
//        return new BASE64Encoder().encode(encrypted);// 此处使用BASE64做转码。
            return Base64.encode(encrypted);// 此处使用BASE64做转码。

        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    // 解密
    public static String decrypt(String sSrc, String sKey) {
        if (sSrc == null )
           return null;
        try {
            byte[] raw = sKey.getBytes("ASCII");
            SecretKeySpec skeySpec = new SecretKeySpec(raw, "AES");
            Cipher cipher = Cipher.getInstance("AES/CBC/PKCS5Padding");
            IvParameterSpec iv = new IvParameterSpec(ivParameter.getBytes());
            cipher.init(Cipher.DECRYPT_MODE, skeySpec, iv);
//            byte[] encrypted1 = new BASE64Decoder().decodeBuffer(sSrc);// 先用base64解密
            byte[] encrypted1 = Base64.decode(sSrc);// 先用base64解密
            byte[] original = cipher.doFinal(encrypted1);
            String originalString = new String(original, "utf-8");
            return originalString;
        } catch (Exception ex) {
            //此处不要置为null，会导致文本信息无法显示
            return " ";
        }
    }

    //    public static String aesEncrypt(String str, String key) {
//        if (str == null || key == null)
//            return null;
//        Cipher cipher = null;
//        try {
//            cipher = Cipher.getInstance("AES/ECB/PKCS5Padding");
//            cipher.init(Cipher.ENCRYPT_MODE, new SecretKeySpec(key.getBytes("utf-8"), "AES"));
//            byte[] bytes = cipher.doFinal(str.getBytes("utf-8"));
////            return new BASE64Encoder().encode(bytes);
//            return Base64.encode(bytes);
//        } catch (Exception e) {
//            e.printStackTrace();
//        }
//        return null;
//    }
//
//    public static String aesDecrypt(String str, String key) {
//        if (str == null || key == null)
//            return null;
//        Cipher cipher = null;
//        try {
//            cipher = Cipher.getInstance("AES/ECB/PKCS5Padding");
//            cipher.init(Cipher.DECRYPT_MODE, new SecretKeySpec(key.getBytes("utf-8"), "AES"));
////            byte[] bytes = new BASE64Decoder().decodeBuffer(str);
//            byte[] bytes = Base64.decode(str);
//            bytes = cipher.doFinal(bytes);
//            return new String(bytes, "utf-8");
//        } catch (Exception e) {
//            e.printStackTrace();
//        }
//
//        return null;
//    }
}
