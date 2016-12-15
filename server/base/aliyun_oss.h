
#ifndef __ALIYUN_OSS_H__
#define __ALIYUN_OSS_H__

#include <string>

#include "base_config.h"

#include "aos_log.h"
#include "aos_util.h"
#include "aos_string.h"
#include "aos_status.h"
#include "oss_auth.h"
#include "oss_util.h"
#include "oss_api.h"

using namespace std;

typedef enum _oss_type{
	NORMAL,
	INTERNAL
}OSS_TYPE;

class CAliyunOss
{
public:
	CAliyunOss();
	virtual ~CAliyunOss();
    
	static CAliyunOss* getInstance();

	int Init();

	void init_sample_request_options(oss_request_options_t *options, int is_cname, OSS_TYPE type);
	bool delete_object(string object_name, OSS_TYPE type = INTERNAL);
	bool put_object_from_buffer(string object_name, unsigned char* byte_stream, unsigned int len, OSS_TYPE type = INTERNAL);

private:
	static CAliyunOss*		s_aliyun_oss;

};

#endif
