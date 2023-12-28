#!/usr/bin/ruby
#coding:utf-8
# Mruby互換

VERSION = "iwm20231217"
TITLE = "ファイル名を交換"

class ClassTerm
	def clear()
		print "\033[2J\033[H"
	end

	def reset()
		print "\033[0m"
	end
end
Term = ClassTerm.new()

def SubBgn()
	puts(
		"",
		"\033[97;104m #{TITLE} \033[49m"
	)
end

def SubEnd()
	Term.reset()
	puts "\033[0m\n(END)"
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
	return{
		'dir'  => a1[0],
		'file' => a1[1]
	}
end

def SubHelp()
	bn = RtnHashDirFile($0)['file']
	puts(
		"    \033[96mruby \033[97m#{bn} \033[91m[input1] [input2]",
		"",
		" \033[93m(例)",
		"    \033[96mruby \033[97m#{bn} \033[91m\"./file1\" \"./file2\""
	)
	SubEnd()
end

Signal.trap(:INT) do
	Term.reset()
	exit
end

Term.clear()
SubBgn()

if ARGV.length < 2 || ARGV[0] == "--help" || ARGV[0] == "-h"
	SubHelp()
end

$flg = true

i1 = 0
ARGV[0..1].each do |s1|
	i1 += 1
	begin
		# 存在しないときは例外発生
		File.open(s1, "rb") do |_IFs| end
	rescue
		puts "\033[91m[#{i1}] \"#{s1}\" は存在しない"
		$flg = false
	end
end

if ! $flg
	SubEnd()
end

puts(
	"\033[92m#{ARGV[0]}",
	"\033[92m  ↓\033[96m↑",
	"\033[96m#{ARGV[1]}"
)

puts
print "\033[93m実行しますか ? [Y/n] \033[97m"
sKey = STDIN.gets.strip

if ! (sKey =~ /Y/i)
	SubEnd()
end

tmpName = "#{$$}.tmp"
File.rename(ARGV[0], tmpName)
File.rename(ARGV[1], ARGV[0])
File.rename(tmpName, ARGV[1])

SubEnd()
