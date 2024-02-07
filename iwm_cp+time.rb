#!ruby
#coding:utf-8

VERSION = "iwm20240206"
TITLE   = "時間を付与してコピーを作成"

require "fileutils"

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
		'd' => a1[0],
		'f' => a1[1]
	}
end

def SubHelp()
	bn = RtnHashDirFile($0)['f']
	puts(
		"    \033[96mruby \033[97m#{bn} \033[91m[input] ...",
		"",
		" \033[93m(例)",
		"    \033[96mruby \033[97m#{bn} \033[91m\"./file1\" ..."
	)
	SubEnd()
end

def RtnFnWithStr(
	sIFn = "",
	sAdd = ""
)
	if sAdd.length == 0
		return sIFn
	end

	a1 = sIFn.split(/[\\\/]/)
	a2 = a1[a1.length - 1].split(".")
	i1 = (a2.length < 2 ? 1 : 2)
	a2[a2.length - i1] << "_#{sAdd}"
	return a2.join(".")
end

Signal.trap(:INT) do
	Term.reset()
	exit
end

Term.clear()
SubBgn()

if ARGV.length == 0
	SubHelp()
end

$Argv = []
ARGV.each do |s1|
	begin
		if(! File.exist?(s1) || File.directory?(s1))
			puts "\033[95m ファイル名？ '#{s1}'\033[0m"
			raise
		end
		File.open(s1, "rb")
		$Argv << s1
	rescue
	end
end

if $Argv.length == 0
	SubEnd()
end

TM = Time.now.strftime("%Y%m%d_%H%M%S")
DT = TM[0, 8]

AryMenu = [
	[1, "日",       DT],
	[2, "時",       TM],
	[3, "任意入力", ""]
]

puts "\033[93m付与する情報"
AryMenu.each do |a1|
	printf("\033[93m%3d  \033[97m%s  \033[92m%s\n", a1[0], a1[1], a1[2])
end
print "\033[93m?\033[97m "
sKey = STDIN.gets.strip

$AddStr = ""
$AddStr << case sKey.to_i
	when 1
		AryMenu[0][2]
	when 2
		AryMenu[1][2]
	when 3
		puts
		print "\033[95m付与文字列 ? \033[97m"
		# Windows禁止文字を変換
		sKey = STDIN.gets.strip
		sKey.strip.gsub(/[\\\/\:\*\?\"\<\>\|]/){""}
	else
		SubEnd()
end

$AryFiles = []
$Argv.each do |sIFn|
	hDF = RtnHashDirFile(sIFn)
	sOFn = RtnFnWithStr(sIFn, $AddStr)
	puts(
		"",
		"\033[95m= \033[97m#{hDF['d']}\033[95m#{hDF['f']}",
		"\033[95m+ #{sOFn}",
	)
	$AryFiles << [sIFn, sOFn]
end
puts
print "\033[93m実行しますか ? [Yes=1／No=0] \033[97m"
iKey = STDIN.gets.to_i

if iKey != 1
	SubEnd()
end

$AryFiles.each do |a1|
	FileUtils.cp(
		a1[0],
		RtnHashDirFile(a1[0])['d'] + a1[1]
	)
end

SubEnd()
