#!/usr/bin/env ruby
#coding:utf-8

VERSION = "iwm20241014"
TITLE = "ファイル名 [1] と [2] を交換"

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
		"\033[5G", "\033[96mruby \033[97m#{bn} \033[91m[input1] [input2]",
		"\n",
		"\n",
		"\033[2G", "\033[93m(例)",
		"\n",
		"\033[5G", "\033[96mruby \033[97m#{bn} \033[91m\"./file1\" \"./file2\"",
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
	"\033[5G", "\033[97m↓↑",
	"\n",
	"\033[97m[2] \033[96m#{ARGV[1]}",
	"\n"
)

print(
	"\n",
	"\033[95m実行しますか \033[97m\033[45m Yes=1 \033[49m\n\033[95m?\033[97m "
)
if STDIN.gets.strip == "1"
	tmpName = "#{$$}.tmp"
	begin
		# オープン可能なファイルか？
		File.open(ARGV[0], "r") do end
		File.open(ARGV[1], "r") do end

		File.rename(ARGV[0], tmpName)
		File.rename(ARGV[1], ARGV[0])
		File.rename(tmpName, ARGV[1])
	rescue => e
		puts "\033[91m#{e.to_s}"
		if File.exist?(tmpName)
			File.rename(tmpName, ARGV[0])
		end
	end
end

Term.end
