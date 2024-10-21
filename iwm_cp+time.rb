#!/usr/bin/env ruby
#coding:utf-8

VERSION = "iwm20241014"
TITLE   = "時間を付与してコピーを作成"

require "fileutils"

class ClassTerminal
	def begin()
		print(
			"\n",
			"\033[97;104m ", TITLE, " \033[49m",
			"\n"
		)
	end

	def end()
		Term.reset
		print(
			"\n",
			"(END)",
			"\n\n"
		)
		exit
	end

	def clear()
		print "\033[2J\033[1;1H"
	end

	def reset()
		print "\033[0m"
	end
end
Term = ClassTerminal.new

def RtnHashDirFile(
	sIFn = ""
)
	a1 = /(.+[\\\/])*(.+?)$/.match(sIFn)[1..].to_a
	i1 = 0
	while i1 < a1.length
		if a1[i1] == nil
			a1[i1] = ""
		end
		i1 += 1
	end
	return { 'd' => a1[0], 'f' => a1[1] }
end

def SubHelp()
	bn = RtnHashDirFile($0)['f']
	print(
		"\033[5G", "\033[96mruby \033[97m#{bn} \033[91m[input] ...",
		"\n",
		"\n",
		"\033[2G", "\033[93m(例)",
		"\n",
		"\033[5G", "\033[96mruby \033[97m#{bn} \033[91m\"./file1\" ...",
		"\n"
	)
	Term.end
end

def RtnFnWithStr(
	sIFn = "",
	sAdd = ""
)
	if sAdd.length == 0
		return sIFn
	end
	a1 = sIFn.split(/[\\\/]/)
	a2 = a1[-1].split(".")
	i1 = (a2.length < 2 ? 1 : 2)
	a2[-i1] << "_#{sAdd}"
	return a2.join(".")
end

Signal.trap(:INT) do
	Term.reset
	exit
end

Term.clear
Term.begin

if ARGV.length == 0
	SubHelp()
end

$Argv = []
ARGV.each do |s1|
	begin
		# オープン可能なファイルか？
		File.open(s1, "r") do
			$Argv << s1
		end
	rescue
		puts "\033[3G\033[95mファイル名？ '#{s1}'\033[0m"
	end
end
if $Argv.length == 0
	Term.end
end

TM = Time.now.strftime("%Y%m%d_%H%M%S")
DT = TM[0, 8]

puts "\033[93m付与する情報"
AryMenu = [
	[1, "日",       DT],
	[2, "時",       TM],
	[3, "任意入力", ""]
]
AryMenu.each do |a1|
	print(
		"\033[3G", "\033[93m", a1[0],
		"\033[6G", "\033[97m", a1[1],
		"\033[10G", "\033[96m", a1[2],
		"\n"
	)
end
$AddStr = nil
print "\033[93m?\033[97m "
case STDIN.gets.strip.to_i
	when 1
		$AddStr = AryMenu[0][2]
	when 2
		$AddStr = AryMenu[1][2]
	when 3
		puts
		sKey = nil
		while true
			print "\033[95m付与文字列 ? \033[97m"
			sKey = STDIN.gets.strip
			if sKey.length > 0
				break
			end
			# 再入力を促す
			print "\033[1A", "\033[2K"
			sleep 0.75
		end
		# Windows禁止文字を変換
		$AddStr = sKey.strip.gsub(/[\\\/\:\*\?\"\<\>\|]/){""}
	else
		Term.end
end

$AryFiles = []
$Argv.each do |sIFn|
	hDF = RtnHashDirFile(sIFn)
	sOFn = RtnFnWithStr(sIFn, $AddStr)
	print(
		"\n",
		"\033[97m", "= ", "\033[37m", hDF['d'], "\033[36m", hDF['f'],
		"\n",
		"\033[97m", "+ ", "\033[96m", sOFn,
		"\n"
	)
	$AryFiles << [sIFn, sOFn]
end

print(
	"\n",
	"\033[95m実行しますか \033[97m\033[45m Yes=1 \033[49m\n\033[95m?\033[97m "
)
if STDIN.gets.strip == "1"
	$AryFiles.each do |a1|
		FileUtils.cp(
			a1[0],
			RtnHashDirFile(a1[0])['d'] + a1[1]
		)
	end
end

Term.end
