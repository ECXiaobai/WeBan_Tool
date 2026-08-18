# _WeBan_Tool_ 安全微课 安全微伴 大学安全教育（合并增强版）

## 介绍

如果本项目帮到了你，可以在右上角点亮 Star，谢谢你！

本仓库以 [hangone/WeBan](https://github.com/hangone/WeBan) 为主干，合并了
[konakona418/WeibanCourseHelper](https://github.com/konakona418/WeibanCourseHelper)
的轻量完课验证码破解技巧，实现了课程学习和根据题库自动考试，支持多用户多线程运行、自动验证码识别等。

运行前后会自动合并题库，如果一次没满分可以再考一次。可将 `answer/answer.json` 文件提交 PR 一起完善题库。

## 相比原版的改进（合并内容）

- **轻量完课验证码**：吸收 WeibanCourseHelper 的"纯请求固定坐标点选破解"技巧，完课时优先调用
  `getCaptcha/checkCaptcha` 接口（不启动浏览器），失败再回退浏览器自动化。通过配置
  `course_captcha_mode` 控制行为：`api`（纯请求，最快）/ `browser`（浏览器自动化，最稳）/ `auto`（先 api 后浏览器，默认）
- **离线分发**：移除了联网更新检查和远程配置模板下载，首次运行直接用打包内置的模板生成 `config.toml`，完全离线可用
- **一键打包**：新增 `build.bat`，Windows 本机一条命令即可打包单文件 exe

## 功能特性

- **课程学习**：自动遍历项目 → 分类 → 课程，模拟翻页、答题、等待学习时长后完课
- **自动考试**：基于题库自动答题，支持单选/多选，未匹配题目可随机作答或手动输入
- **验证码识别**：登录验证码 OCR 自动识别；完课验证码默认走轻量请求破解（不弹浏览器），失败自动回退浏览器自动化
- **多账号并发**：支持配置多个账号，可多线程同时执行
- **题库同步**：考试前后自动从服务器同步题库，支持多用户共享
- **断点续考**：追求满分模式下，一次未满分可再次考试
- **进度监控**：完课后自动检查进度是否更新，未更新则警告提示
- **调试模式**：开启 `debug` 可查看完整请求/响应日志

## 使用

从下面的几种方式下载后运行，配置说明可参考 [config.example.toml](config.example.toml)，账号级配置可覆盖全局设置。

### 构建产物（Windows）

从 [Releases](https://github.com/ECXiaobai/WeBan_Tool/releases/latest) 下载
`WeBan-windows-x64.exe` 运行，根据提示输入信息。也可以本地自行打包：

```bash
cmd /c build.bat   # 产物生成在 dist\WeBan-windows-x64.exe
```

### 源码运行

1. 安装 Python 3.12+ 和 Git

2. 克隆本仓库

```bash
git clone https://github.com/ECXiaobai/WeBan_Tool
```

3. 安装依赖

```bash
pip install -r requirements.txt
```

4. 运行

```bash
python main.py
```

### 浏览器检测

程序按以下优先级自动检测可用的浏览器（仅在完课验证码回退浏览器模式时需要），无需手动配置：

1. **用户指定**：环境变量 `CHROMIUM_BINARY` / 配置文件 `browser_path`
2. **CDP 远程调试**：配置文件 `cdp_host` + `cdp_port`
3. **Playwright 浏览器**：`pip install playwright && playwright install chromium`
4. **系统浏览器**：自动查找已安装的 Chrome / Chromium

## 配置文件

`config.toml`（首次运行自动从内置模板生成并打开）主要字段：

| 字段 | 说明 |
|------|------|
| `[[account]]` `tenant_name` / `username` / `password` | 学校全称 + 账号密码（password 留空默认=用户名） |
| `study_mode` | `true` 正常学习 / `force` 强制重新学习 / `false` 不学习 |
| `exam_mode` | `true` 正常考试 / `perfect` 追求满分 / `force` 强制重考 / `false` 不考试 |
| `course_captcha_mode` | **合并版新增**：`auto`（默认，先轻量请求破解再回退浏览器）/ `api`（只用轻量请求）/ `browser`（只用浏览器） |
| `max_workers` | 多账号并发线程数 |
| `browser_path` / `cdp_host` / `cdp_port` | 浏览器与 CDP 配置 |
| `[ai]` | AI 搜题兜底（题库未命中时调用 OpenAI 兼容接口答题） |

## 演示

![study](images/study.png)
![exam](images/exam.png)
![old](images/old.png)

## 常见问题

- ### 部分无法直接登录的学校/Token 登录方法

有些从迎新系统跳转的可以试试账号密码都是学号，也可以尝试使用 Token 登录，在电脑浏览器登录后按 F12 或者 Ctrl+Shift+I 打开开发者工具，找到本地存储，复制 user 的内容到 config.toml 配置文件（token 登录时需填写 `user_id` + `token` 字段）。

![chrome](images/chrome.png)
![firefox](images/firefox.png)

- ### 学习

1. 学习时长太低不会计入进度
2. 有腾讯云验证码的课程：默认 `course_captcha_mode = "auto"` 会先尝试轻量请求破解，失败时弹出浏览器窗口手动操作
3. 学习进度不更新可能是被风控，遇到了需要验证码的课程，请去网页上完成一次后重试

- ### 考试

1. 据观察，考试未提交是不会消耗考试次数的

## 鸣谢

- [hangone/WeBan](https://github.com/hangone/WeBan) 主干项目，提供题库和代码思路
- [konakona418/WeibanCourseHelper](https://github.com/konakona418/WeibanCourseHelper) 轻量完课验证码破解技巧
- [Coaixy/weiban-tool](https://github.com/Coaixy/weiban-tool) 提供题库和一些代码思路
- [pooneyy/WeibanQuestionsBank](https://github.com/pooneyy/WeibanQuestionsBank) 提供题库

## 其他

1. 本项目仅供学习交流使用，请勿用于商业用途，否则后果自负。
2. 欢迎 Star，欢迎 PR。
3. 截图时注意打码个人信息。
