import os
from dotenv import load_dotenv
from huaweicloudsdkobs.obs_client import ObsClient

load_dotenv()

access_key = os.getenv("ACCESS_KEY")
secret_key = os.getenv("SECRET_KEY")

def upload_file_with_sdk(bucket_name, object_key, file_path):
    client = ObsClient(
        access_key_id=access_key,
        secret_access_key=secret_key,
        server="https://obs.ap-southeast-2.myhuaweicloud.com"
    )
    
    with open(file_path, 'rb') as file:
        resp = client.putObject(bucket_name, object_key, file)
        if resp.status < 300:
            print("File uploaded successfully.")
        else:
            print(f"Failed with status code: {resp.status}")

upload_file_with_sdk("heart-obs/test", "my-object", "/path/to/local/file.txt")
