package com.tenth.space.ui.activity;

import java.io.Serializable;

/**
 * 系统相册的一个图片对象
 * 
 * @author Administrator
 * 
 */
public class ImageItem implements Serializable {
	public String imageId;
	public String thumbnailPath;
	public String imagePath;
	public boolean isSelected = false;
}
