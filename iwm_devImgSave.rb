#!/usr/bin/env ruby
#coding:utf-8

require "reline"

VERSION = "iwm20250423"
TITLE   = "デバイスをバックアップ"

BG01 = " " * 70

class Class_Terminal
	def clear()
		$stderr.print "\033[2J", "\033[1;1H", "\033[0m", "\033[0G"
	end

	def reset()
		$stderr.print "\033[0m"
	end

	def begin(sTitle = "")
		if sTitle.length == 0
			return
		end
		$stderr.print "\n", "\033[97;44m ", sTitle, " \033[49m", "\n"
	end

	def end(bInput = true)
		$stderr.print "\033[0m", "(END)"
		if bInput == true
			STDIN.gets
		end
		$stderr.print "\n\n"
		exit
	end

	def abort()
		$stderr.print "\033[0m", "\033[0G", "\n\n"
		exit
	end

	def cursorOn()
		$stderr.print "\033[?25h"
	end

	def cursorOff()
		$stderr.print "\033[?25l"
	end
end
Term = Class_Terminal.new

at_exit do
	Term.cursorOn()
end

Signal.trap(:INT) do
	Term.abort()
end

class Class_Lsblk
	# lsblk -o 末尾 "PATH" は番兵
	X = %x(
		LANG=C lsblk --raw -o TYPE,KNAME,LABEL,FSTYPE,SIZE,PARTTYPENAME,PATH \
		| grep -E '^[^rom]' \
	)

	def getAry()
		rtn = []
		X.split("\n").each do |_s1|
			_s1 = _s1.gsub(" ", "\t").gsub("\\x20", " ")
			rtn << "#{_s1}".strip.split(/\t/)
		end
		return rtn
	end

	def p()
		getAry().each do |_a1|
			Kernel.p _a1
		end
	end
end
Lsblk = Class_Lsblk.new

# 必要なパッケージをインストール
%x(iwm_SubPkgInstall "pv" "yad")
Term.clear()

# User Name
USER = ENV["USER"]

# デバイス名とサイズの取得
$AryDevInfo = []

Term.begin()

print "\033[91m", "複数選択するときは [SPACE] で区切る", "\033[97m", " (例)", "\033[93m" " ?", "\033[97m", " 2 3 5", "\n"

$AryDevInfoId = 0;
Lsblk.getAry().each do |_a1|
	if $AryDevInfoId == 0
		# [1]KNAME, [4]SIZE
		$AryDevInfo << [$AryDevInfoId, -1, _a1[1], _a1[4]]
		print(
			"\033[93m",
			"\033[3G", "?",
			"\033[6G", _a1[1],
			"\033[18G", _a1[2],
			"\033[30G", _a1[3],
			"\033[38G", _a1[4],
			"\033[47G", _a1[5],
			"\n"
		)
	elsif _a1[0] =~ /disk/i
		$AryDevInfo << [$AryDevInfoId, -1, _a1[1], _a1[4]]
		print(
			"\033[48;2;20;10;80m", BG01,
			"\033[3G", "\033[97m", $AryDevInfoId.to_s,
			"\033[38;2;240;220;0m",
			"\033[6G", _a1[1],
			"\033[38G", _a1[4],
			"\033[0m",
			"\n"
		)
		$AryDevInfoId += 1
		# MBR 512byte
		$AryDevInfo << [$AryDevInfoId, 512, _a1[1], "MBR512"]
		print(
			"\033[3G", "\033[97m", $AryDevInfoId.to_s,
			"\033[38;2;0;150;250m",
			"\033[6G", _a1[1],
			"\033[18G", "MBR512",
			"\n"
		)
		$AryDevInfoId += 1
		# MBR 512byte * 2048sector
		$AryDevInfo << [$AryDevInfoId, (512 * 2048), _a1[1], "MBR512x2048"]
		print(
			"\033[3G", "\033[97m", $AryDevInfoId.to_s,
			"\033[38;2;0;150;250m",
			"\033[6G", _a1[1],
			"\033[18G", "MBR512x2048",
			"\n"
		)
	elsif _a1[0] =~ /part/i
		$AryDevInfo << [$AryDevInfoId, -1, _a1[1], _a1[4]]
		print(
			"\033[3G", "\033[97m", $AryDevInfoId.to_s,
			"\033[6G", "\033[95m", _a1[1],
			"\033[18G", "\033[97m", _a1[2],
			"\033[30G", "\033[92m", _a1[3],
			"\033[38G", "\033[97m", _a1[4],
			"\033[47G", "\033[32m", _a1[5],
			"\n"
		)
	end

	$AryDevInfoId += 1
end

# 番号選択
$ArySelectDevNum = []

# 複数指定する際は [SPACE] か ',' で区切る
# (例) > "2 3 5" => [2, 3, 5]
Reline.readline("\033[93m? \033[97m", false).strip.split(/[ ,]/).each do |_s1|
	_i1 = _s1.to_i
	if _i1 > 0 && _i1 < $AryDevInfo.length
		$ArySelectDevNum << _i1
	end
end

if $ArySelectDevNum.length == 0
	Term.end()
end

$title = "出力フォルダ"
$OD = %x(
	yad --file \
		--directory \
		--filename="#{Dir.getwd}" \
		--button="Cancel:1" --button="OK:0" \
		--title="#{$title}" \
		--width="640" --borders="4" --center --on-top \
		2>/dev/null \
).strip

if $OD.length == 0
	Term.end()
end

puts(
	"",
	"\033[93m#{$title}",
	"\033[97m> \033[94m#{$OD}"
)

# 出力するファイル
$AryOF = []

puts(
	"",
	"\033[93m出力ファイル"
)

$ArySelectDevNum.each do |_i1|
	_OByte, _IF, _IfSize = $AryDevInfo[_i1][1..3]

	_OF1 = "#{_IF}_#{_IfSize}.dd.gz"
	_OF2 = "#{_OF1}_restore.readme"

	print(
		"\033[97m> ", _i1, "\n",
		"\033[3G", "\033[92m", _OF1, "\n",
		"\033[3G", "\033[32m", _OF2, "\n"
	)

	$AryOF << [_OByte, "/dev/#{_IF}", "#{$OD}/#{_OF1}", "#{$OD}/#{_OF2}"]
end

print(
	"\n",
	"\033[95m実行しますか \033[97m\033[45m Yes=1 \033[49m\n\033[95m?\033[97m "
)
if STDIN.gets.strip == "1"
	Term.cursorOff

	$AryOF.each do |_a1|
		_OByte, _IF, _OF1, _OF2 = _a1

		_CMD = "sudo dd if=#{_IF} conv=noerror"
		_CMD << (
			_OByte < 0 ?
			" bs=4M" :
			" bs=#{_OByte} count=1"
		)
		_CMD << " | pv | gzip -c > #{_OF1}"

		# Restore用 Readme作成
		File.open(_OF2, "w") do |_fs|
			_s1 = "gzip -d < ./#{File.basename(_OF1)} | pv | sudo dd of=#{_IF} conv=noerror "
			_s1 << (_OByte < 0 ? "bs=4M" : "bs=#{_OByte} count=1")
			_s1 << "\n\n"

			%x(lsblk -l -o NAME,SIZE,FSTYPE,LABEL #{_IF})
			.split("\n").each do |_s2|
				_s1 << "# #{_s2}\n"
			end

			_fs.puts _s1
		end

		puts(
			"",
			"\033[97m> \033[96m#{_OF1}"
		)

		# 開始時間
		timeBgn = Time.now
		puts "\033[37m#{timeBgn}"

		print "\033[37m"

		# Command 実行
		[
			_CMD,
			"sudo chown #{USER} #{_OF1} #{_OF2}",
			"sudo chgrp #{USER} #{_OF1} #{_OF2}",
			"sudo chmod 644 #{_OF1} #{_OF2}"
		]
		.each do |_s1|
			system _s1
		end

		# 終了時間
		timeEnd = Time.now
			_d1 = timeEnd - timeBgn
				iH = (_d1 / 3600).to_i
			_d1 -= iH * 3600
				iM = (_d1 / 60).to_i
			_d1 -= iM * 60
				iS = _d1.to_i
		puts "\033[37m#{timeEnd}"
		printf("[%02d:%02d:%02d]\n", iH, iM, iS)
	end

	Term.cursorOn
end

Term.end()
