
#include "aliyun_oss.h"

CAliyunOss* CAliyunOss::s_aliyun_oss = NULL;


CAliyunOss::CAliyunOss()
{
}

CAliyunOss::~CAliyunOss()
{
	aos_http_io_deinitialize();
}

CAliyunOss* CAliyunOss::getInstance()
{
	if (!s_aliyun_oss) {
		s_aliyun_oss = new CAliyunOss();
		if (s_aliyun_oss->Init()) {
			delete s_aliyun_oss;
			s_aliyun_oss = NULL;
		}
	}

	return s_aliyun_oss;
}

int CAliyunOss::Init()
{
	if (aos_http_io_initialize(NULL, 0) != AOSE_OK) {
	    return -1;
	}
	return 1;
}

void CAliyunOss::init_sample_request_options(oss_request_options_t *options, int is_cname, OSS_TYPE type)
{
    options->config = oss_config_create(options->pool);
    if(type == INTERNAL){
    	aos_str_set(&options->config->endpoint, OSS_ENDPOINT_INTERNAL);
    }else{
    	aos_str_set(&options->config->endpoint, OSS_ENDPOINT);
    }
    aos_str_set(&options->config->access_key_id, ACCESS_KEY_ID);
    aos_str_set(&options->config->access_key_secret, ACCESS_KEY_SECRET);
    options->config->is_cname = is_cname;

    options->ctl = aos_http_controller_create(options->pool, 0);
}

bool CAliyunOss::delete_object(string object_name, OSS_TYPE type)
{
    aos_pool_t *p = NULL;
    aos_string_t bucket;
    aos_string_t object;
    int is_cname = 0;
    oss_request_options_t *options = NULL;
    aos_table_t *resp_headers = NULL;
    aos_status_t *s = NULL;

    aos_pool_create(&p, NULL);
    options = oss_request_options_create(p);
    init_sample_request_options(options, is_cname, type);
    aos_str_set(&bucket, BUCKET_NAME);
    aos_str_set(&object, object_name.c_str());

    s = oss_delete_object(options, &bucket, &object, &resp_headers);

    bool ret = true;
    if (!aos_status_is_ok(s)) {
        ret = false;
        //printf("%d %s %s %s ", s->code, s->error_code, s->error_msg, s->req_id);
    }

    aos_pool_destroy(p);

    return ret;
}


bool CAliyunOss::put_object_from_buffer(string object_name, unsigned char *byte_stream, unsigned int len, OSS_TYPE type)
{
	bool ret = true;
    aos_pool_t *p = NULL;
    aos_string_t bucket;
    aos_string_t object;
    int is_cname = 0;
    aos_table_t *headers = NULL;
    aos_table_t *resp_headers = NULL;
    oss_request_options_t *options = NULL;
    aos_list_t buffer;
    aos_buf_t *content = NULL;
    aos_status_t *s = NULL;

    aos_pool_create(&p, NULL);
    options = oss_request_options_create(p);
    init_sample_request_options(options, is_cname, type);
    headers = aos_table_make(p, 1);
    apr_table_set(headers, "x-oss-meta-author", "oss");
    aos_str_set(&bucket, BUCKET_NAME);
    aos_str_set(&object, object_name.c_str());

    aos_list_init(&buffer);
    content = aos_buf_pack(options->pool, byte_stream, len);
    aos_list_add_tail(&content->node, &buffer);

    s = oss_put_object_from_buffer(options, &bucket, &object,
                   &buffer, headers, &resp_headers);

    if (!aos_status_is_ok(s)) {
        ret = false;
    }

    aos_pool_destroy(p);

    return ret;
}

