# Windows Developer Config（个人 fork）

本仓库 fork 自 [microsoft/WindowsDeveloperConfig](https://github.com/microsoft/WindowsDeveloperConfig)，在官方 Windows Dev Config 一键脚本的基础上去掉了不需要的内容，并重新划分了标准版和完整版。分隔线以下是官方 README 原文。

## 一键安装

打开任意 PowerShell 窗口运行下面的命令。过程中会弹出一次 UAC 提权，不需要重启。

**标准版**：常用开发工具 + 系统设置

```powershell
irm https://raw.githubusercontent.com/GrayArashiAI/WindowsDeveloperConfig/main/src/windows-dev-config/setup-standard.ps1 | iex
```

**完整版**：标准版 + .NET SDK 10、PowerToys、WinUI 模板、远程桌面

```powershell
irm https://raw.githubusercontent.com/GrayArashiAI/WindowsDeveloperConfig/main/src/windows-dev-config/setup-full.ps1 | iex
```

**卸载**：删除安装的软件，并把设置恢复为 Windows 默认值

```powershell
irm https://raw.githubusercontent.com/GrayArashiAI/WindowsDeveloperConfig/main/src/windows-dev-config/uninstall.ps1 | iex
```

运行前请注意：

- 可以重复运行，已经完成的步骤会自动跳过；中途出错的话，再运行一次即可。
- 部分资源管理器和任务栏设置，要注销后重新登录才会生效。
- 安装文件和日志保存在 `%ProgramData%\CalmOS`。
- 卸载会删除下表中的所有软件（Windows Terminal 和 VC++ 运行库除外），**安装前就已存在的也会被删除**；设置会恢复为 Windows 默认值，而不是安装前的值。
- 官方 README 里的 `aka.ms/devconfig/...` 链接运行的是微软原版，不包含本仓库的改动。

## 安装内容

| 类别 | 标准版 | 完整版额外包含 |
| --- | --- | --- |
| 软件 | Windows Terminal、Intelligent Terminal、PowerShell 7、Git、GitHub CLI、VS Code、Python 3.14 + uv、VC++ 运行库、Node.js LTS + nvm、Coreutils、Windows App CLI | .NET SDK 10、PowerToys、WinUI `dotnet new` 模板 |
| 系统 | Sudo（内联模式）、开发者模式、长路径支持 | 开启远程桌面（不开放防火墙） |
| 资源管理器 | 显示文件扩展名和隐藏文件、标题栏显示完整路径、默认打开"此电脑"、快速访问不显示最近使用的文件 / 常用文件夹 / 推荐文件、不显示同步提供程序（如 OneDrive）的提示、显示详细信息窗格 | — |
| 任务栏、开始菜单、搜索 | 任务栏右键"结束任务"、隐藏蓝牙图标、关闭开始菜单推荐和账户通知、关闭网页搜索和搜索亮点、关闭小组件 | — |
| Edge | 跳过首次运行向导 | — |
| 终端 | 默认配置设为 PowerShell 7 | — |

## 与官方原版的区别

**两个版本都去掉了**

- **Copilot**：GitHub Copilot CLI、Windows Terminal 里的 Copilot 配置、win-dev-skills 插件市场和 WinUI Copilot 插件
- **WSL**：WSL 平台和 Ubuntu，安装过程因此不再需要重启
- **Oh My Posh**：程序本身和 PowerShell profile 里的初始化代码（包括其中的 UTF-8 控制台编码设置）
- **Cascadia Nerd Font**：终端默认字体本来就是 Cascadia Mono，NF 版只多了图标字形，不装 Oh My Posh 用不上
- **Azure CLI**
- **强制深色主题**
- **勿扰模式**
- **Edge 新标签页设为空白页**：这条策略只在加入域或 MDM 管理的电脑上生效，个人电脑上会被 Edge 忽略

相应地，卸载时也不再清理上面这些内容。

**标准版和完整版的划分不同**：官方标准版也会安装 .NET SDK 10 和 PowerToys，但不包含 Sudo、开发者模式、Edge 设置，以及隐藏蓝牙图标、关闭网页搜索 / 搜索亮点 / 小组件、快速访问不显示推荐文件这几项。

**运行方式**：一键命令运行的是本仓库 `main` 分支上 `src/windows-dev-config/` 里**未签名**的源码，不做微软签名校验；官方运行的是固定到某个 commit、经过微软签名的根目录副本。这意味着，能推送到本仓库 `main` 分支的人，就能控制以管理员权限运行的代码。

## 同步上游

首次同步前添加上游仓库：

```bash
git remote add upstream https://github.com/microsoft/WindowsDeveloperConfig
```

之后每次同步：

```bash
git fetch upstream
git merge upstream/main
```

- GitHub 网页上的 "Sync fork" 无法处理冲突，要用命令行合并。
- 三个入口脚本里的 `$payloadRef` 官方每次发版都会改，merge 时必然冲突，保留本仓库的版本即可。
- 如果上游改了 `.github/workflows/` 下的文件，推送前需要给 GitHub CLI 补上 `workflow` 权限：`gh auth refresh -h github.com -s workflow`。

本仓库改过的文件如下（另外还有本 README 开头这部分），冲突只会出现在这些文件里：

| 文件（位于 `src/windows-dev-config/`） | 改动 |
| --- | --- |
| `setup-standard.ps1`、`setup-full.ps1`、`uninstall.ps1` | 下载地址换成本仓库、ref 改为 `main`、去掉签名校验、加上 `-AllowUnsigned` |
| `bootstrap.ps1` | 仓库地址换成本仓库；`-AllowUnsigned` 时也传 `-ExecutionPolicy RemoteSigned`，否则在执行策略为 Restricted 的新机器上无法运行 |
| `steps/_elevation.ps1` | 脚本重新启动自身时同样传执行策略 |
| `workloads/devconfig.ps1` | 去掉 Copilot、Oh My Posh、Azure CLI、WSL 和字体；调整标准版包含的软件和阶段 |
| `steps/terminal.ps1` | 去掉强制深色主题 |
| `steps/registry-taskbar-search.ps1` | 去掉勿扰模式；调整标准版包含的设置 |
| `steps/edge.ps1` | 去掉新标签页策略 |
| `steps/registry-system.ps1`、`steps/registry-explorer.ps1` | 调整标准版包含的设置 |

---

## 📄 以下为官方 README 原文（未按本 fork 的改动更新，内容不一定准确）

<p align="center">
  <img src="./doc/images/devconfigs.svg" alt="Windows Developer Config logo" width="96" />
</p>

<h1 align="center">Windows Developer Config</h1>

<p align="center">
  Opinionated setups for Windows dev boxes. Idempotent. CI-tested.
</p>

<h3 align="center">
  <a href="#%EF%B8%8F-windows-dev-config">Windows Dev Config</a>
  <span> · </span>
  <a href="#-wsl-comfort">WSL Comfort</a>
  <span> · </span>
  <a href="#-workloads">Workloads</a>
  <span> · </span>
  <a href="#-ai-tooling">AI tooling</a>
  <span> · </span>
  <a href="#-troubleshooting">Troubleshooting</a>
</h3>

---

Set up a new Windows dev box in minutes, not hours. Pick a setup, run one command, get back to building. Everything here is safe to re-run.

## 🎯 Pick your setup

| You want... | Go to |
| --- | --- |
| A full dev workstation: tools, Windows settings, WSL, and terminal. One command, one restart. | [Windows Dev Config](#%EF%B8%8F-windows-dev-config) |
| A nicer WSL shell: zsh/bash, Starship, CLI tools, and a themed terminal profile. | [WSL Comfort](#-wsl-comfort) |
| One language or toolchain. | [Workloads](#-workloads) |
| Local AI: PyTorch for your GPU, plus Ollama, llama.cpp, or Foundry Local. | [AI tooling](#-ai-tooling) |

## 🖥️ Windows Dev Config

Installs dev tools, applies opinionated Windows settings, and sets up WSL + Ubuntu — restart included. Nothing to clone, nothing to install first.

Open any PowerShell window — elevated or not — and run:

<details>
<summary><strong>What you get</strong></summary>

### Standard Experience
- **Dev tools:** Windows Terminal, PowerShell 7, Git, GitHub CLI, GitHub Copilot CLI, VS Code, .NET SDK 10, Python 3.14 + uv, Node.js LTS + nvm, Coreutils for Windows, Windows App CLI, Oh My Posh, and PowerToys.
- **Terminal:** PowerShell 7 as the default profile, Oh My Posh in your prompt, Cascadia Mono NF as the default font, and a GitHub Copilot profile in the dropdown.
- **Windows settings:** Dark theme, long paths, File Explorer defaults, Start/Search settings, and Do Not Disturb
- **WSL:** WSL platform + Ubuntu, including the restart and the automatic resume afterwards.

### Full Experience
- **Everything from standard**
- **Windows settings:** Developer Mode, Sudo, widgets off, and Edge policies, additional Start/Search/System Tray settings
- **Remote Desktop:** Enabled and firewall settings set
</details>

### Standard Experience
```powershell
irm https://aka.ms/devconfig/standard/setup.ps1 | iex
```

### Full Experience
```powershell
irm https://aka.ms/devconfig/full/setup.ps1 | iex
```

> ⚠️ **Heads up — it may restart your PC.** WSL needs virtualization turned on, so save your work first. Setup picks up where it left off after the reboot.

Every tool and setting, how to undo them, and troubleshooting: [Windows Dev Config README](./src/windows-dev-config/README.md).

<br/>

## 🐧 WSL Comfort

*Also known as Comfort Shell. A polished Windows + WSL shell setup — zsh/bash, Starship prompt, modern CLI tools, themed terminal.*

```powershell
.\wsl-comfort\install.ps1
```

Interactive by default — pick and choose components as it runs. Use `-NonInteractive` for unattended installs. The Linux half (`comfort-shell-bootstrap.sh`) is standalone, so you can also copy it onto any Ubuntu host and run it directly.

<details>
<summary><strong>What you can pick</strong></summary>

- Your choice of shell: **zsh** or **bash**.
- Optional **Starship** prompt.
- Optional modern CLI tools: `fzf`, `rg`, `fd`, `bat`, `eza`, `zoxide`, `jq`.
- Optional clipboard and `open` shims (`pbcopy`, `pbpaste`, `open`).
- Optional **Homebrew**.
- Optional Git defaults.
- A themed **Windows Terminal** profile using Cascadia Code Nerd Font.

</details>

Full details: [`wsl-comfort/readme.md`](./wsl-comfort/readme.md).

<br/>

## 🧪 Workloads

Just want one toolchain? Each of these is a single command.

| Workload | Run via IRM Powershell call |
| --- | --- |
| WinUI 3 | `irm https://aka.ms/devconfig/winui/setup.ps1 \| iex` |
| WinForms | `irm https://aka.ms/devconfig/winforms/setup.ps1 \| iex` |
| WinAppCLI | `irm https://aka.ms/devconfig/winappcli/setup.ps1 \| iex` |
| .NET | `irm https://aka.ms/devconfig/dotnet/setup.ps1 \| iex` |
| Go | `irm https://aka.ms/devconfig/go/setup.ps1 \| iex` |
| Rust | `irm https://aka.ms/devconfig/rust/setup.ps1 \| iex` |
| PHP | `irm https://aka.ms/devconfig/php/setup.ps1 \| iex` |

| Workload | Run via Winget configure |
| --- | --- |
| TypeScript | `winget configure -f .\Workloads\typescript\configuration.winget --accept-configuration-agreements --disable-interactivity` |
| Java | `winget configure -f .\Workloads\java\configuration.winget --accept-configuration-agreements --disable-interactivity` |
| Python | `winget configure -f .\Workloads\python\configuration.winget --accept-configuration-agreements --disable-interactivity` |
| SQL | `winget configure -f .\Workloads\sql\configuration.winget --accept-configuration-agreements --disable-interactivity` |
| PowerShell | `winget configure -f .\Workloads\powershell\configuration.winget --accept-configuration-agreements --disable-interactivity` |

The `winget configure` will soon move to one-line style. Currently, to run them from a clone of this repo. What each one installs: [Workloads](./src/windows-dev-config/workloads.md).

<br/>

## 🤖 AI tooling

Detects your GPU, installs the matching PyTorch build (CUDA, ROCm, Intel XPU, or CPU), and proves it works. Add a local model runtime if you want one.

| Workload | Run |
| --- | --- |
| Local AI (PyTorch for your hardware) | `irm https://aka.ms/devconfig/local-ai/setup.ps1 \| iex` |
| Local AI + Ollama | `irm https://aka.ms/devconfig/local-ai/ollama/setup.ps1 \| iex` |
| Local AI + llama.cpp | `irm https://aka.ms/devconfig/local-ai/llama.cpp/setup.ps1 \| iex` |
| Local AI + Foundry Local | `irm https://aka.ms/devconfig/local-ai/foundry/setup.ps1 \| iex` |

Individual pieces (CUDA, ROCm, Intel AI, PyTorch, llama.cpp, Ollama, Foundry Local), hardware support, and options: [AI tooling workloads](./src/windows-dev-config/ai-workloads.md).

<br/>

## 🩺 Troubleshooting

<details>
<summary><strong>"Unrecognized command: configure"</strong></summary>

Run `winget configure --enable`. If `winget configure` is still not recognized after that, [`Workloads/_common/assert-winget-configure.ps1`](./Workloads/_common/assert-winget-configure.ps1) tells you whether App Installer is too old, policy has disabled configuration, or something else needs fixing.

</details>

<details>
<summary><strong><code>winget configure</code> fails with "internal error" / error code <code>-2146233079</code></strong></summary>

The Visual C++ Redistributable is missing. Install it, then re-run:

```powershell
# x64:
winget install Microsoft.VCRedist.2015+.x64

# ARM64:
winget install Microsoft.VCRedist.2015+.arm64
```

[`Workloads/_common/enable-winget-configure.ps1`](./Workloads/_common/enable-winget-configure.ps1) installs it automatically as part of enabling `winget configure`.

</details>

<details>
<summary><strong>A workload says it succeeded but <code>python</code> / <code>node</code> / the tool isn't on PATH</strong></summary>

Open a new terminal, or run the matching `install.ps1` shim to refresh PATH in the current session.

</details>

<details>
<summary><strong>Windows Dev Config rebooted the machine and looks stuck</strong></summary>

A scheduled task resumes the run about 30 seconds after you sign back in and finishes the WSL setup. Nothing after a couple of minutes? Run the one-liner again — it's safe to re-run and skips everything already done. More detail in [`windows-dev-config/README.md`](./src/windows-dev-config/README.md#troubleshooting).

</details>

<details>
<summary><strong>Comfort Shell bootstrap fails because WSL is missing</strong></summary>

Run `.\wsl-comfort\install.ps1` on the Windows side instead. It installs WSL first.

</details>

<details>
<summary><strong>WSL install fails with <code>wsl --install ... failed with exit code -1</code></strong></summary>

WSL needs hardware virtualization available to the OS. Two common root causes:

- **On bare metal:** virtualization (VT-x / AMD-V) is disabled in BIOS/UEFI. Reboot into firmware settings, enable it, save, and reboot back into Windows. The exact label varies by vendor — check your motherboard or laptop manufacturer's documentation if you can't find it.
- **Inside a VM:** the host hasn't exposed nested virtualization to the guest. For a Hyper-V host, run this from an elevated PowerShell session **on the host** (with the guest VM powered off):

  ```powershell
  Set-VMProcessor -VMName <VM_NAME> -ExposeVirtualizationExtensions $true
  ```

  Other hypervisors have their own equivalent settings — check your hypervisor's documentation.

</details>

<br/>

## 🐛 Reporting issues

Hit a bug, a stale doc, or a setup that fails on your machine? Open an issue at [github.com/microsoft/WindowsDeveloperConfig/issues](https://github.com/microsoft/WindowsDeveloperConfig/issues). Include your Windows build (`winver`), the exact command you ran, and the failing output. This helps us triage faster.

<br/>

## ❤️ Contributing

Contributions of all kinds are welcome: bug reports, doc fixes, new workloads, voice-and-tone tweaks. Start with [`CONTRIBUTING.md`](./CONTRIBUTING.md), then read [`src/docs/development.md`](./src/docs/development.md) for the CI matrix, the "how to add a language" walkthrough, and how the sign pipeline works.

> **Note on the repo layout:** the [`src/`](./src/) tree is the source of truth. The top-level `windows-dev-config/`, `Workloads/`, and `wsl-comfort/` folders are Authenticode-signed release copies regenerated by the sign pipeline, so please don't edit them directly. Full details in [`src/docs/development.md`](./src/docs/development.md#repo-layout-signed-vs-source).

The single source of truth for every flow (paths, build/run commands, ids, language metadata) is [`src/manifest.yml`](./src/manifest.yml). The Command Palette extension, the CI harness, and the per-flow shims all read from it, so keep it in sync when you add or rename a flow.
