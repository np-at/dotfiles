#!/usr/bin/env python3
import argparse
import requests
import shutil
import os
from pathlib import Path
from subprocess import check_output as os_exec

manifest = None
def get_remote_zig_info(version:str = 'master'):
    global manifest
    if not manifest:
        zig_manifest_url = "https://ziglang.org/download/index.json"
        zig_manifest = requests.get(zig_manifest_url)
        manifest = zig_manifest.json()
    return manifest[version]


def identify_current_zig_version():
    zig_ex = shutil.which('zig')
    if not zig_ex:
        return None
    v = os_exec([zig_ex, 'version'])
    return v.strip().strip(b'\n').decode('utf-8')


def create_arg_parser():
    parser = argparse.ArgumentParser(description='Grab latest version of zig binary and download to designated directory')
    parser.add_argument('-d', '--directory', help='Directory to download zig binary to', required=False, default=None)
    parser.add_argument('-v', '--version', help='Version of zig to download; defaults to latest', required=False, default="master")
    parser.add_argument('-p', '--platform', help='Platform to download zig binary for; defaults to current', required=False)
    parser.add_argument('-o', '--os', help='OS to download zig binary for; defaults to current', required=False)
    parser.add_argument('-a', '--arch', help='Architecture to download zig binary for; defaults to current', required=False)
    return parser

def main():
    parser = create_arg_parser();
    args = parser.parse_args()

    # if no directory is specified, default to ~/.local/bin
    if not args.directory:
        if home := os.environ.get('HOME'):
            args.directory = os.path.join(home,'.local','bin')
        elif home := os.environ.get('USERPROFILE'):
            args.directory = os.path.join(home,'.local','bin')
    else:
        args.directory = os.path.abspath(args.directory)


    if not os.path.isdir(args.directory):
        if os.path.isfile(args.directory):
            print(f"Error: {args.directory} is a file")
            return
        Path(args.directory).mkdir(parents=True, exist_ok=True)
    if not args.platform:
        args.platform = os_exec(['uname', '-s']).decode('utf-8').strip().lower()
        if args.platform == 'darwin':
            args.platform = 'macos'
    if not args.os:
        args.os = os_exec(['uname', '-o']).decode('utf-8').strip().lower()
    if not args.arch:
        args.arch = os_exec(['uname', '-m']).decode('utf-8').strip().lower()
        if args.arch == 'arm64':
            args.arch = 'aarch64'

    print(f"Platform: {args.platform}")
    print(f"OS: {args.os}")
    print(f"Arch: {args.arch}")
    
    current_zig_version = identify_current_zig_version()
    
    zig_info = get_remote_zig_info(args.version)

    print(f"Current zig version: {current_zig_version}")
    print(f"Latest zig version (from user input {args.version}): {zig_info['version']}")
    if current_zig_version != zig_info['version']:
        print(f"Downloading zig version: {args.version}")
        platform = args.platform if args.platform else zig_info['platform']
        os_name = args.os if args.os else zig_info['os']
        arch = args.arch if args.arch else zig_info['arch']
        zig_download_url = zig_info[f"{arch}-{platform}"]['tarball']
        print(f"Downloading from: {zig_download_url}")
        zig_download = requests.get(zig_download_url, stream=True)
        zig_download.raise_for_status()

        # get temp directory to download to
        import tempfile
        temp_dir = tempfile.TemporaryDirectory()
        zig_download_file = os.path.join(temp_dir.name, f"zig-{args.version}-{platform}-{os_name}-{arch}.tar.xz")
        with open(zig_download_file, 'wb') as f:
            for chunk in zig_download.iter_content(chunk_size=8192):
                f.write(chunk)
        print(f"Downloaded to: {zig_download_file}")
        untar(zig_download_file, args.directory)
        print(f"Extracted to: {args.directory}")
        temp_dir.cleanup()
    else:
        print("Already up to date")
        exit(0)


    
def untar(tar_file, dest_dir):
    import tarfile
    t_dir =     os.path.dirname(tar_file)

    with tarfile.open(tar_file) as ex:
        ex.extractall(t_dir)
    for dir in os.scandir(t_dir):
        if dir.name.startswith('zig'):
            os.rename(dir.path, os.path.join(t_dir, 'ziglib'))
            break
    if not os.path.exists(os.path.join(t_dir,'ziglib')):
        raise Exception("Could not find ziglib directory in tar file")

    if os.path.exists(os.path.join(dest_dir,'zig')):
        os.remove(os.path.join(dest_dir,'zig'))
    if os.path.exists(os.path.join(dest_dir,'ziglib')):
        shutil.rmtree(os.path.join(dest_dir,'ziglib'))
    shutil.move(os.path.join(t_dir,'ziglib'), os.path.join(dest_dir,'ziglib'))
    Path(os.path.join(dest_dir,'zig')).symlink_to(os.path.join(dest_dir,'ziglib','zig'))
    # os.link(os.path.join(dest_dir,'ziglib','zig'), os.path.join(dest_dir,'zig'))
    # shutil.move(os.path.join(t_dir,'zig'), os.path.join(dest_dir,'ziglib')
#    shutil.link(os.path.join(dest_dir,'ziglib','zig'), os.path.join(dest_dir,'zig'))



    # with tarfile.open(tar_file) as ex:
    #     with os.open(os.path.join(dest_dir, 'zig'), os.O_CREAT | os.O_WRONLY) as dest:
    #         shutil.copyfileobj(ex, dest)
    # os.chmod(os.path.join(dest_dir, 'zig'), 0o755)
    #
        
if __name__ == "__main__":
    # print(identify_current_zig_version())
    
    main()


