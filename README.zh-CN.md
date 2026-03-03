# SenseVoice Dictation（macOS）中文说明

## 1. 项目简介

这是一个 macOS 菜单栏语音输入工具：
- 按一次触发键开始录音
- 再按一次停止录音
- 使用 SenseVoice 转写
- 自动粘贴到当前输入框

## 2. 环境要求

- macOS 11+
- Python 3.11+
- Xcode Command Line Tools（用于构建 `.app` 启动器）

## 3. 安装

```bash
./install.sh
```

默认会执行：
1. 创建 `.venv`
2. 安装依赖
3. 自动生成 `config.toml`
4. 预下载模型
5. 创建应用和桌面启动器

可选参数：
- `--no-model`
- `--no-launcher`
- `--autostart`

## 4. 启动

```bash
./start_app.sh
```

## 5. 开机自启

启用：
```bash
./enable_autostart.sh
```

关闭：
```bash
./disable_autostart.sh
```

## 6. 启动器图标

创建：
```bash
./create_launcher.sh
```

删除：
```bash
./remove_launcher.sh
```

## 7. 模型更新

菜单里点击 `Update Model`。

## 8. 卸载清理

标准卸载（保留源码目录）：
```bash
./uninstall.sh
```

彻底卸载（包含源码目录）：
```bash
./uninstall.sh --delete-project-dir
```

## 9. 发布打包

```bash
./prepare_release.sh
```

输出：
- `sensevoice-dictation-macos-release.zip`
