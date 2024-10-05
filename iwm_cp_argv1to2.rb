#!/usr/bin/env ruby
#coding:utf-8

VERSION = "iwm20241005"
TITLE = "ファイル [1] から [2] へ上書きコピー"

require "fileutils"

class ClassTerm
	def clear
		print "\033[2J\033[1;1H"
	end

	def reset
		print "\033[0m"
	end
end
Term = ClassTerm.new

def SubBgn()
	print(
		"\n",
		"\033[97;104m ", TITLE, " \033[49m",
		"\n"
	)
end

def SubEnd()
	Term.reset
	print(
		"\n",
		"(END)",
		"\n\n"
	)
	exit
end

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
	SubEnd()
end

Signal.trap(:INT) do
	Term.reset
	exit
end

Term.clear
SubBgn()

if ARGV.length < 2 || ARGV[0] == "--help" || ARGV[0] == "-h"
	SubHelp()
end

i1 = 0
ARGV.each do |s1|
	i1 += 1
	begin
		# オープン可能なファイルか？
		File.open(s1, "r") do end
	rescue
		puts "\033[91m[#{i1}] \"#{s1}\" は存在しない"
		SubEnd()
	end
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
	"\033[93m", "実行しますか [Yes=1／No=0]",
	"\n",
	"? ",
	"\033[97m"
)
sKey = STDIN.gets.strip
if sKey.downcase == "y" || sKey.to_i == 1
	ARGV[1..].each do |s1|
		FileUtils.cp(ARGV[0], s1)
	end
end

SubEnd()
