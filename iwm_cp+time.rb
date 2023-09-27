#!/usr/bin/ruby
#coding:utf-8

VERSION = "iwm20230925"
TITLE = "時間を付与してコピーを作成"

require "fileutils"
require "io/console"

class ClassTerm
	def clear()
		print "\033[2J\033[H"
	end

	def reset()
		print "\033[0m"
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
	puts "\n(END)"
	exit
end

def SubHelp()
	bn = File.basename($0)
	puts(
		"    \033[97m#{bn} \033[91m[input] ...\n" +
		"\n" +
		" \033[93m(例)\n" +
		"    \033[97m#{bn} \033[91m\"./file1\" ..."
	)
	SubEnd()
end

SubBgn()

ARGV.delete_if do |_s1|
	! File.file?(_s1)
end

if ARGV.length < 1 || ARGV[0] == "--help" || ARGV[0] == "-h"
	SubHelp()
end

TM = Time.now.strftime("%Y%m%d_%H%M%S")
DT = TM[0, 8]

AryMenu = [
	[1, "日",       DT],
	[2, "時",       TM],
	[3, "任意入力", ""]
]

$AddStr = "_"

puts "\033[93m付与する情報"
AryMenu.each do |_a1|
	printf("\033[93m%3d\033[97m  %s %s\n", _a1[0], _a1[1], _a1[2])
end
print "\033[93m?\033[97m "
$AddStr << case STDIN.gets.to_i
	when 1
		AryMenu[0][2]
	when 2
		AryMenu[1][2]
	when 3
		print "\n\033[95m付与文字列 ? \033[97m"
		# 禁止文字を変換
		(
			# Windows は要エンコード
			if Dir.exist?("c:\\windows")
				STDIN.set_encoding("cp932")
				STDIN.gets.encode("cp65001", invalid: :replace, replace: "")
			else
				STDIN.gets
			end
		).strip.gsub(/[\\\/\:\*\?\"\<\>\|]/){""}
	else
		SubEnd()
end

$AryFiles = []

ARGV.each do |_s1|
	$IDF   = File.expand_path(_s1)
	$IDir  = File.dirname($IDF)
	$IFile = File.basename($IDF)

	$OFile = File.basename($IDF, ".*")
	$OFile << $AddStr
	$OFile << File.extname($IDF)

	puts(
		"\n" +
		"\033[92m=\033[97m #{$IDir}/\033[92m#{$IFile}\n" +
		"\033[96m+\033[97m #{$IDir}/\033[96m#{$OFile}"
	)

	$AryFiles << ["#{$IDF}", "#{$IDir}/#{$OFile}"]
end

print(
	"\n" +
	"\033[93m実行しますか ? [Y/n] \033[97m"
)
if ! (STDIN.getch =~ /Y/i)
	puts
	SubEnd()
end

$AryFiles.each do |_a1|
	FileUtils.cp(_a1[0], _a1[1])
end

puts
SubEnd()
