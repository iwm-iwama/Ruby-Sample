#!/usr/bin/ruby
#coding:utf-8

VERSION = "iwm20230926"
TITLE = "デバイスをバックアップ"

require "io/console"

class ClassTerm
	def clear()
		print "\033[2J\033[H"
	end

	def reset()
		print "\033[0m"
	end

	def cursorOff()
		print "\033[?25l"
	end

	def cursorOn()
		print "\033[?25h"
	end
end
Term = ClassTerm.new()

Signal.trap(:INT) do
	Term.reset()
	exit
end

def SubBgn()
	puts(
		"\n" +
		"\033[97;104m #{TITLE} \033[0m"
	)
end

def SubEnd()
	Term.reset()
	print "\n(END)"
	STDIN.getch
	exit
end

# 必要なパッケージをインストール
system "iwm_SubPkgInstall 'pv' 'yad'"
Term.clear()

# User Name
USER = ENV["USER"]

# Device Dir
DEV = "/dev"

# [0]byte, [1]NAME, [2]SIZE, [3]FSTYPE, [4]LABEL
$AryFDisk = []

SubBgn()

puts "\033[97m複数選択するときは , で区切る (例) 2,3,5"
$i1 = 0;
%x(lsblk -l -o TYPE,NAME,SIZE,FSTYPE,LABEL #{DEV}/* 2>/dev/null).split("\n").each do |_s1|
	_a1 = _s1.strip.split(/\s+/)
	if $i1 == 0
		$AryFDisk << [0, _a1[1], _a1[2], _a1[3], _a1[4]]
		printf("     \033[93m%-16s%-8s%-8s%s\n", _a1[1], _a1[2], _a1[3], _a1[4])
		$i1 += 1
	elsif _a1[0] =~ /disk/i
		$AryFDisk << [-1, _a1[1], _a1[2], "", ""]
		printf("  \033[97;41m%-3d%-16s%-32s\033[0m\n", $i1, _a1[1], _a1[2])
		$i1 += 1
		# MBR 512byte
		$AryFDisk << [512, _a1[1], "MBR512", "", ""]
		printf("  \033[36m%-3d%-16s%s\n", $i1, _a1[1], "MBR512")
		$i1 += 1
		# MBR 512byte * 2048sector
		$AryFDisk << [(512 * 2048), _a1[1], "MBR512x2048", "", ""]
		printf("  \033[94m%-3d%-16s%s\n", $i1, _a1[1], "MBR512x2048")
		$i1 += 1
	elsif _a1[0] =~ /part/i
		$AryFDisk << [-1, _a1[1], _a1[2], _a1[3], _a1[4]]
		printf("  \033[97m%-3d%-16s%-8s\033[92m%-8s\033[97m%s\n", $i1, _a1[1], _a1[2], _a1[3], _a1[4])
		$i1 += 1
	end
end

# 番号選択
$ArySelectDevNum = []

# 複数指定する際は 空白 か "," で区切る
# (例) > "2,3 5" => [2, 3, 5]
print "\033[93m? \033[97m"
STDIN.gets.split(/[, ]/).each do |_s1|
	_i1 = _s1.to_i
	if _i1 > 0 && _i1 < $AryFDisk.length
		$ArySelectDevNum << _i1
	end
end

if $ArySelectDevNum.length == 0
	SubEnd()
end

title = "出力フォルダ ?"
$OD = %x(yad --file --filename="/home/#{USER}" --directory --title="#{title}" --width=320 --center --on-top).strip
if $OD.length == 0
	SubEnd()
end
puts(
	"\n" +
	"\033[93m#{title}\n" +
	"\033[97m> \033[95m#{$OD}"
)

$AryExec = []

puts(
	"\n" +
	"\033[93m出力ファイル"
)
$ArySelectDevNum.each do |_i1|
	_Obyte, _IF, _IfSize = $AryFDisk[_i1]

	_OF1 = "#{_IF}-#{_IfSize}.dd.gz"
	_OF2 = "#{_OF1}_restore.readme"

	puts(
		"\033[97m> #{_i1}\n" +
		"  \033[96m#{_OF1}\n" +
		"  \033[96m#{_OF2}"
	)

	# Rename
	_OF1 = "#{$OD}/#{_OF1}"
	_OF2 = "#{$OD}/#{_OF2}"

	$AryExec << [_Obyte, "#{DEV}/#{_IF}", _IfSize, _OF1, _OF2]
end

print(
	"\n" +
	"\033[93m実行しますか ? [Y/n] \033[97m"
)
if ! (STDIN.getch =~ /Y/i)
	puts
	SubEnd()
end

puts

Term.cursorOff()

$AryExec.each do |_a1|
	_Obyte, _IF, _IfSize, _OF1, _OF2 = _a1

	_CMD = "sudo dd if=#{_IF} conv=noerror"
	_CMD << (
		_Obyte < 0 ?
		" bs=4M" :
		" bs=#{_Obyte} count=1"
	)
	_CMD << " | pv | gzip -c > #{_OF1}"

	# Restore用 Readme作成
	File.open(_OF2, "w") do |_fs|
		_s1 = "gzip -d < ./#{File.basename(_OF1)} | pv | sudo dd of=#{_IF} conv=noerror "
		_s1 << (_Obyte < 0 ? "bs=4M" : "bs=#{_Obyte} count=1")
		_s1 << "\n\n"

		%x(lsblk -o NAME,SIZE,FSTYPE,LABEL #{_IF}).split("\n").each do |_s2|
			_s1 << "# #{_s2.gsub("└─"){"└"}}\n"
		end

		_fs.puts _s1
	end

	puts(
		"\n" +
		"\033[97m> \033[96m#{_OF1}"
	)

	# 開始時間
	timeBgn = Time.now
	puts "\033[34m#{timeBgn}"

	# Command 実行
	print "\033[36m"
	[
		_CMD,
		"sudo chown #{USER} #{_OF1} #{_OF2}",
		"sudo chgrp #{USER} #{_OF1} #{_OF2}",
		"sudo chmod 644 #{_OF1} #{_OF2}"
	].each do |_s1|
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
	puts "\033[34m#{timeEnd}"
	printf("[%02d:%02d:%02d]\n", iH, iM, iS)
end

Term.cursorOn()

SubEnd()
