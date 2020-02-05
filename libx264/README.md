# x264

[x264 home](http://www.videolan.org/developers/x264.html)

## Download source code

```Bash
git clone http://git.videolan.org/git/x264.git
```

## Build for Android

```Bash
./build.sh [android-abi]
```

The `android-abi` can be: armeabi-v7a, arm64-v8a (default), x86 and x86_64

## References

1. [x264 for Android 的编译](http://www.voidcn.com/article/p-ssgtnoox-bqc.html)

2. [使x264支持NV21格式输入](https://gitee.com/airx/x264-android)

  - 使用说明： 针对android摄像头，使x264支持NV21格式，编码参数指定i_csp = X264_CSP_NV21即可

  - 基于[dreifachstein/x264](https://github.com/dreifachstein/x264)在其基础上，修改了x264_picture_alloc函数，添加了X264_CSP_NV21支持

3. [mirror/x264](https://github.com/mirror/x264): ?