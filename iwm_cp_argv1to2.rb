#!/usr/bin/env ruby
#coding:utf-8

VERSION = "iwm20241014"
TITLE = "ファイル [1] から [2] へ上書きコピー"

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

	def clear
		print "\033[2J\033[1;1H"
	end

	def reset
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
		"\033[5G", "\033[96mruby \033[97m#{bn} \033[91m[input] [output ...]",
		"\n",
		"\n",
		"\033[2G", "\033[93m(例)",
		"\n",
		"\033[5G", "\033[96mruby \033[97m#{bn} \033[91m\"./file1\" \"./file2\" ...",
		"\n"
	)
	Term.end
end

Signal.trap(:INT) do
	Term.reset
	exit
end

Term.clear
Term.begin

if ARGV.length < 2 || ARGV[0] == "--help" || ARGV[0] == "-h"
	SubHelp()
end

print(
	"\033[97m[1] \033[92m#{ARGV[0]}",
	"\n",
	"\033[5G", "\033[97m↓",
	"\n"
)
ARGV[1..].each do |s1|
	puts "\033[97m[2] \033[96m#{s1}"
end

print(
	"\n",
	"\033[95m実行しますか \033[97m\033[45m Yes=1 \033[49m\n\033[95m?\033[97m "
)
if STDIN.gets.strip == "1"
	begin
		# オープン可能なファイルか？
		File.open(ARGV[0], "r") do end

		ARGV[1..].each do |s1|
			# 上書き先が存在しないときは作成
			FileUtils.cp(ARGV[0], s1)
		end
	rescue => e
		puts "\033[91m#{e.to_s}"
	end
end

Term.end
