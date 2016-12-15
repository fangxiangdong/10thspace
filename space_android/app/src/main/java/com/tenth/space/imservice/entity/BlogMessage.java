package com.tenth.space.imservice.entity;

import com.tenth.space.DB.entity.BlogEntity;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.io.Serializable;
import java.util.List;

/**
 * Created by neil.yi on 2016/10/18.
 */

public class BlogMessage extends BlogEntity implements Serializable {

    private List<String> pathList;//上传前的文件路径
    private List<String> urlList;//上传后的链接
    private String blogText = "";

    @Override
    public String getBlogText() {
        return blogText;
    }

    @Override
    public void setBlogText(String blogText) {
        this.blogText = blogText;
    }

    public void setPathList(List<String> pathList) {
        this.pathList = pathList;
    }

    public List<String> getPathList() {
        return pathList;
    }

    public List<String> getUrlList() {
        return urlList;
    }

    public void setUrlList(List<String> list) {
        urlList = list;
    }

    public String getBlogContent() {
        JSONArray jsonArray = new JSONArray(urlList);
        JSONObject obj = new JSONObject();
        try {
            obj.put("BlogText", blogText);
            obj.put("BlogImages", jsonArray);
        } catch (JSONException e) {
            e.printStackTrace();
        }

        return obj.toString();
    }
    
    public static BlogMessage buildForSend(String blogText, List<String> list) {
        BlogMessage blogMessage = new BlogMessage();
        blogMessage.blogText = blogText;
        blogMessage.pathList = list;

        return blogMessage;
    }
}
