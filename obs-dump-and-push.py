import os
import subprocess
from datetime import datetime
from dotenv import load_dotenv

load_dotenv()

db_user = os.getenv("DB_USER")
db_password = os.getenv("DB_PASSWORD")
db_host = os.getenv("DB_HOST")
db_name = os.getenv("DB_NAME")

obs_bucket = os.getenv("OBS_BUCKET")
backup_path_dir = os.getenv("BACKUP_PATH")

def install_package(package_name):
    subprocess.check_call(["pip", "install", package_name])

try:
    install_package("python-dotenv")
    print("python-dotenv installed successfully.")
except subprocess.CalledProcessError as e:
    print(f"Error installing package: {e}")

backup_filename = f"{db_name}_backup_{datetime.now().strftime('%Y%m%d_%H%M%S')}.sql"
backup_path = os.path.join(backup_path_dir, backup_filename)
obs_object_key = f"backups/{backup_filename}"

def dump_database():
    """Create File dump from database"""
    dump_command = [
        "mysqldump",
        "-u", db_user,
        f"-p{db_password}",
        "-h", db_host,
        db_name,
        "--single-transaction",
        "--quick",
        "--routines",
        "--triggers",
        "--events",
        "--add-drop-database",
        "--add-drop-table",
        "--hex-blob",
        "--result-file", backup_path
    ]
    
    try:
        print("Creating file dump...")
        subprocess.run(dump_command, check=True)
        print(f"Create file dump success: {backup_path}")
    except subprocess.CalledProcessError as e:
        print("Dump File Fail : ", e)
        return False
    return True

def upload_to_obs():
    """Upload file to OBS by obsutil"""
    upload_command = [
        "obsutil", 
        "cp", 
        backup_path, 
        f"obs://{obs_bucket}/{obs_object_key}"
    ]
    
    try:
        print("Uploading file to OBS...")
        subprocess.run(upload_command, check=True)
        print(f"Success upload file to OBS: {obs_object_key}")
    except subprocess.CalledProcessError as e:
        print("Uploadfile to OBS Fail:", e)
        return False
    return True

def remove_backup_file():
    """Remove file backup after upload"""
    try:
        os.remove(backup_path)
        print(f"Remove backup Success: {backup_path}")
    except OSError as e:
        print("Fail remove backup file:", e)

if __name__ == "__main__":
    if dump_database():
        if upload_to_obs():
            remove_backup_file()
