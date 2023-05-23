# 前情提要

在macOS上利用iverilog+vscode实现基本的前仿真开发环境，后续综合、布线在Vivado上实现，等拿到板子再编写tcl脚本来自动化上板

# 安装

vscode插件：

- [Verilog-HDL/SystemVerilog/Bluespec SystemVerilog - Visual Studio Marketplace](https://marketplace.visualstudio.com/items?itemName=mshr-h.VerilogHDL)
- [SystemVerilog - Language Support - Visual Studio Marketplace](https://marketplace.visualstudio.com/items?itemName=eirikpre.systemverilog)
- [Code Runner - Visual Studio Marketplace](https://marketplace.visualstudio.com/items?itemName=formulahendry.code-runner)

```
brew install icarus-verilog
brew install --cask xquartz
brew insatll --cask gtkwave
```

安装gtkwave的时候注意：

> ## Perl Switch
>
> Using Perl’s package manager, install Switch:
>
> ```
> cpan install Switch
> perl -V:'installsitelib'
> ```
>
> The last command prints out the location of where Switch is installed. If it is something like `/usr/local/Cellar/perl/...`, then Switch must be coppied to the correct location in `/Library/Perl/5.*/`:
>
> ```
> sudo cp /usr/local/Cellar/perl/5.*/lib/perl5/site_perl/5.*/Switch.pm /Library/Perl/5.*/
> ```

安装verible用于代码高亮：

```
brew tap chipsalliance/verible
brew install verible
```

第一次安装会报错，修改`/opt/homebrew/Library/Taps/chipsalliance/homebrew-verible/Formula/verible.rb`，在`def install`前加上：

```
env :std
```

如果报类似`error: use of undeclared identifier 'GOOGLE_DCHECK'`，就

```
brew uninstall protobuf
```

# vscode配置

工作区设置：

```json
	"settings": {
		"verilog.linting.linter": "iverilog",
		"verilog.linting.iverilog.arguments": "-g2012 -DIVERILOG -Y .sv -y src/cpu -y testbench/cpu -I src -grelative-include",
		"verilog.formatting.veribleVerilogFormatter.path": "/opt/homebrew/Cellar/verible/0.0-3087-gaac4fadc/bin/verible-verilog-format",
		"verilog.formatting.verilogHDL.formatter": "verible-verilog-format",
		"verilog.languageServer.veribleVerilogLs.enabled": true,
		"verilog.languageServer.veribleVerilogLs.path": "/opt/homebrew/Cellar/verible/0.0-3087-gaac4fadc/bin/verible-verilog-ls",
		"verilog.formatting.veribleVerilogFormatter.arguments": "--indentation_spaces=4",
		"code-runner.executorMapByFileExtension": {
			".sv": "cd $workspaceRoot && iverilog -o build/wave -g2012 -DIVERILOG -Y .sv -y src/cpu -y testbench/cpu -I src -grelative-include `ls testbench/cpu/*_tb.sv` && vvp -n build/wave -lxt2 && gtkwave build/wave.vcd",
		},
		"systemverilog.formatCommand": "/opt/homebrew/Cellar/verible/0.0-3087-gaac4fadc/bin/verible-verilog-format --indentation_spaces=4 --assignment_statement_alignment=align",
		"[verilog]": {
			"editor.defaultFormatter": "eirikpre.systemverilog"
		},
		"[systemverilog]": {
			"editor.defaultFormatter": "eirikpre.systemverilog"
		},
	}
```