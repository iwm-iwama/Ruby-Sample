#!/usr/bin/ruby
#coding:utf-8

VERSION = "iwm20240525"
TITLE = "ファイル１から２へ上書きコピー"

require "fileutils"

class ClassTerm
	def clear()
		print "\033[2J\033[1;1H"
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
		'd' => a1[0],
		'f' => a1[1]
	}
end

def SubHelp()
	bn = RtnHashDirFile($0)['f']
	puts(
		"    \033[96mruby \033[97m#{bn} \033[91m[input] [output ...]",
		"",
		" \033[93m(例)",
		"    \033[96mruby \033[97m#{bn} \033[91m\"./file1\" \"./file2\" ..."
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
ARGV.each do |s1|
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
	"\033[92m  ↓"
)
ARGV[1..].each do |s1|
	puts "\033[96m#{s1}"
end
puts
print "\033[93m実行しますか ? [Y/n] \033[97m"
sKey = STDIN.gets.strip

if ! (sKey =~ /Y/i)
	SubEnd()
end

ARGV[1..].each do |s1|
	FileUtils.cp(ARGV[0], s1)
end

SubEnd()
