#!/usr/bin/env ruby
#coding:utf-8

VERSION = "iwm20250423"
TITLE = "ファイル [1] から [2] へ上書きコピー"

require "fileutils"

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
	Term.end(false)
end

Term.clear()
Term.begin(TITLE)

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

Term.end(false)
