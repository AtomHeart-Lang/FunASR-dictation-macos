# FunASR Dictation for macOS（中文说明）

[English README](README.md)

## 目录
- [应用介绍](#应用介绍)
- [DMG 安装](#dmg-安装)
- [快速开始](#快速开始)
- [日常使用](#日常使用)
- [快捷键设置](#快捷键设置)
- [模型参数设置](#模型参数设置)
- [菜单栏状态](#菜单栏状态)
- [开发者说明](#开发者说明)

<a id="应用介绍"></a>
## 应用介绍

FunASR Dictation 是一个基于 [Fun-ASR-Nano-2512](https://github.com/FunAudioLLM/Fun-ASR) 的 macOS 菜单栏语音输入工具。

核心流程：
- 按一次触发键开始录音
- 再按一次停止录音
- 在本地完成转写
- 自动粘贴到当前输入框

相较于系统自带语音识别或常见通用工具，本应用的重点优势是：
- 本地推理，不依赖固定云端往返
- 更适合真实中英混合文本输入场景
- 全局触发、一键录音/停止、自动粘贴到任意文本框
- 安装器和卸载器都使用原生 macOS 进度窗口，不需要终端

<a id="dmg-安装"></a>
## DMG 安装

普通用户建议直接使用 DMG 安装包。

DMG 安装器会自动完成：
- 下载独立 Python runtime
- 安装 Python 依赖
- 下载当前支持的最新模型
- 将运行文件安装到 `~/Library/Application Support/FunASRDictation/app`
- 创建 `~/Applications/FunASR Dictation.app`
- 创建 `~/Applications/Uninstall FunASR Dictation.app` 图形化卸载器

安装步骤：
1. 从 Releases 下载最新的 `funasr-dictation-installer-1.0.4.dmg`
2. 打开 DMG
3. 双击 `Install FunASR Dictation.app`
4. 等待原生安装窗口完成下载与部署
5. 如果需要桌面快捷方式，点击安装窗口中的 `创建桌面快捷方式`
6. 点击 `打开应用`

说明：
- DMG 本身不包含模型缓存
- 目标机器不需要预装 Homebrew 或 Python
- 如果创建了桌面快捷方式，卸载时 macOS 可能要求你手动删除它

<a id="快速开始"></a>
## 快速开始

首次启动时，请在 macOS 提示中为 `FunASR Dictation` 授权：
- 麦克风
- 辅助功能
- 输入监控

之后：
- 应用常驻在菜单栏
- 正常使用时不会保留 Dock 图标
- 界面语言可在菜单里切换：`System / 中文 / English`

主菜单项：
- `Toggle Dictation`
- `Hotkey Settings`
- `Model Config`
- `Update Model`
- `Enable Dictation On App Start`
- `Enable Launch At Login`
- `Quit App`

<a id="日常使用"></a>
## 日常使用

典型使用流程：
1. 在菜单中开启听写
2. 把光标放到任意文本框
3. 按一次触发键开始录音
4. 说话
5. 再按一次相同触发键停止录音
6. 应用自动转写并粘贴文本

日常可用功能：
- 键盘触发或鼠标触发
- 菜单栏状态提示：加载 / 就绪 / 录音 / 转写 / 错误
- 菜单中直接更新模型
- 菜单中直接设置开机自动启动
- 菜单中直接设置应用启动时是否自动开启听写

<a id="快捷键设置"></a>
## 快捷键设置

在菜单中打开 `Hotkey Settings`。

窗口会显示：
- 当前触发方式
- 当前键盘快捷键
- 当前鼠标按键

设置流程：
1. 点击 `设置键盘快捷键` 或 `设置鼠标快捷键`
2. 选择自动捕获或手动输入
3. 保存按键
4. 选择当前生效的触发方式是键盘还是鼠标
5. 点击 `保存`

这些设置会持久化到：
- `~/Library/Application Support/SenseVoiceDictation/ui_settings.json`

<a id="模型参数设置"></a>
## 模型参数设置

在菜单中打开 `Model Config` 可直接修改运行参数。

本版本推荐默认值：
- `language = "auto"`
- `sample_rate = 16000`
- `channels = 1`
- `paste_delay_ms = 20`
- `idle_unload_seconds = 300`
- `enable_beep = true`
- `use_itn = true`
- `merge_vad = false`
- `hotwords = ""`
- `remove_emoji = true`
- `batch_size_s = 0`（运行时固定内部值，UI 不提供修改）

各项说明：
- `识别语言`：中英混说时建议保持 `auto`
- `采样率`：建议 `16000`，只有设备要求时再改为 `44100/48000`
- `声道数`：建议 `1`，真实双声道输入设备才使用 `2`
- `粘贴延迟`：如果偶发粘贴失败，可以适当调高
- `空闲卸载模型秒数`：设为 `0` 表示始终常驻模型
- `数字与日期规范化`：让数字、日期、单位等输出更规整
- `合并长停顿片段`：长语音可能更快，但断句通常不如关闭自然
- `高频词`：适合加入人名、品牌名、技术术语
- `过滤表情符号`：移除最终粘贴文本中的 emoji

生效方式：
- 在 UI 中保存
- 从下一次录音开始生效

<a id="菜单栏状态"></a>
## 菜单栏状态

- `○` 关闭
- `…` 加载中
- `⇡` 更新中
- `✓` 就绪
- `●` 录音中
- `↻` 转写中
- `!` 错误

<a id="开发者说明"></a>
## 开发者说明

本章集中放置所有直接调用脚本/命令的内容。

### 源码安装

环境要求：
- macOS 11+
- Python 3.11+
- 当没有内置 launcher 二进制时，需要 Xcode Command Line Tools

源码安装：

```bash
./install.sh
```

源码运行：

```bash
./start_app.sh
```

可选命令：

```bash
./create_launcher.sh
./create_desktop_shortcut.sh
./enable_autostart.sh
./disable_autostart.sh
./uninstall.sh
```

### 构建 DMG

```bash
./build_dmg.sh
```

产物：

```bash
./funasr-dictation-installer-1.0.4.dmg
```

### 脚本说明

- `install.sh`：安装环境、依赖、模型和启动器辅助文件
- `start_app.sh`：从源码直接启动菜单栏应用
- `create_launcher.sh`：创建 `~/Applications` 启动器
- `create_desktop_shortcut.sh`：创建可选桌面快捷方式符号链接
- `create_uninstaller.sh`：创建 `~/Applications` 图形化卸载器
- `enable_autostart.sh`：启用 LaunchAgent 开机自启
- `disable_autostart.sh`：关闭 LaunchAgent 开机自启
- `remove_launcher.sh`：删除启动器和桌面快捷方式
- `uninstall.sh`：卸载运行环境、模型缓存、启动器和相关支持文件
- `build_dmg.sh`：构建面向终端用户的 DMG 安装包
- `install_from_dmg.command`：DMG 内部使用的安装入口脚本
- `download_python_runtime.sh`：下载并校验 DMG 安装所需的独立 Python runtime
- `prepare_release.sh`：清理本地产物并打包 release zip
- `task_runner/TaskProgressApp.m`：安装器 / 卸载器原生任务窗口实现
- `launcher/FunASRLauncher.c`：launcher 源码，负责 runtime 路径解析与 TCC 引导
- `funasr_nano_runtime/`：`Fun-ASR-Nano-2512` 所需的内置运行时代码

### 卸载与清理

```bash
./uninstall.sh
```

会清理：
- LaunchAgent
- 正在运行的相关进程
- `~/Library/Application Support/FunASRDictation` 下的运行文件
- `~/Applications` 下的启动器和卸载器
- Fun-ASR 模型缓存以及历史 SenseVoice 缓存（如果存在）

如果 macOS 阻止自动删除桌面快捷方式，卸载仍会完成，你可以手动从桌面删除该快捷方式。
