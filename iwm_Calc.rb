#!/usr/bin/env ruby
#coding:utf-8

require "reline"

VERSION = "iwm20240416"

class Terminal
	def clear()
		print "\033[2J\033[1;1H"
	end

	def reset()
		print "\033[0m"
	end
end
Term = Terminal.new()

Signal.trap(:INT) do
	Term.reset()
	exit
end

def SubEnd()
	Term.reset()
	exit
end

WIDTH = 60
LN = "-" * WIDTH

# \t区切り
HELP = <<EOD
#{LN}
	基本操作
		[Enter]	計算実行
		[↑／↓]	履歴
#{LN}
	コマンド
		.q	終了
		.r	再起動
		.rd	再起動／履歴消去
		.u	ユーザ設定　一覧
		.ud	〃　全消去
		.ud[NUM]	〃　[NUM]を消去
		.i	入力履歴　一覧
#{LN}
	数式
		*	3 * 2	=> 6
		/	3.0 / 2.0	=> 1.5
			3 / 2	=> 1
		%	3 % 2	=> 1
		+	3 + 2	=> 5
		-	3 - 2	=> 1
		**	3 ** 2 	=> 9
		:pi	3.141592653589793
		:sqrt(n)	sqrt(4)	=> 2.0
		:sin(n°)	sin(30)	=> 0.5
		:cos(n°)	cos(60)	=> 0.5
		:tan(n°)	tan(45)	=> 1.0
#{LN}
	例１
		> i1 = :pi ↲
		> i2 = 180 ↲
		> i1 / i2 ↲
		i1 = Math::PI; i2 = 180; i1 / i2;
		0.017453292519943295

	例２
		> def foo() :pi / 180 end ↲
		> foo() ↲
		def foo() Math::PI / 180 end; foo();
		0.017453292519943295
#{LN}
EOD

def SubHelp()
	puts "\033[97;44m Ver.#{VERSION} \033[49m"
	_BG = " " * WIDTH
	HELP.split("\n").each do |_s1|
		print "\033[44m", _BG
		a1 = _s1.split("\t")
		if a1[0] then print "\033[1G",  "\033[97m", a1[0] end
		if a1[1] then print "\033[2G",  "\033[96m", a1[1] end
		if a1[2] then print "\033[5G",  "\033[93m", a1[2] end
		if a1[3] then print "\033[18G", "\033[97m", a1[3] end
		if a1[4] then print "\033[29G", "\033[95m", a1[4] end
		puts "\033[49m"
	end
	Term.reset()
end

# Math::PI / 180
PiPerDeg = 0.017453292519943295

# User Defined
$AryUserDefined = []

def main()
	Term.clear()
	Term.reset()

	SubHelp()

	while true
		# 空白データ 排除
		input = Reline.readline("> ", false).strip

		# 複数空白を集約
		input.gsub!(/\s{2,}/, " ")

		if input.length > 0
			# 重複データ 排除
			Reline::HISTORY.delete(input)
			Reline::HISTORY << input
		end

		case input
			# ""
			when ""
				print

			# .q
			when /\.q$/i
				break

			# .r
			when ".r"
				main()
				break

			# .rd
			when ".rd"
				$AryUserDefined.clear
				Reline::HISTORY.clear
				main()
				break

			# .u
			when ".u"
				puts "\033[37;41m User Defined \033[49m"
				print "\033[92m"
				if $AryUserDefined.length == 0
					puts "[]"
				else
					i1 = 1
					$AryUserDefined.each do |_s|
						puts "[#{i1}] #{_s}"
						i1 += 1
					end
				end

			# .ud
			when ".ud"
				$AryUserDefined = []

			# .ud[NUM]
			when /\.ud\d+/
				begin
					i1 = input[3].to_i
					$AryUserDefined.delete_at(i1 - 1)
				rescue => e
 				end

			# .i
			when /\.i$/i
				puts "\033[37;41m Input History \033[49m"
				print "\033[92m"
				Reline::HISTORY.each do |_s|
					print "  ", _s, "\n"
				end

			# def
			when /^(def)/
				if input =~ /^(def\s.+\send$)/
					# 関数 置換
					s1 = input.split(/\s*\(/)[0]
					$AryUserDefined.delete_if{ |_s| _s =~ /^#{s1}/ }
					$AryUserDefined << input
				else
					Reline::HISTORY.delete(input)
				end

			# =
			when /.+\=.*/
				# 変数 置換
				a1 = input.split(/\s*\=/)
				if a1[1]
					$AryUserDefined.delete_if{ |_s| _s =~ /^#{a1[0]}/ }
					$AryUserDefined << input
				end

			# Calculate
			else
				s1 = ""
				$AryUserDefined.each do |_s|
					s1 << "  "
					s1 << _s
					s1 << "\n"
				end
				s1 << "  "
				s1 << input

				# Math 置換
				s1.gsub!(/:pi/i, "Math::PI")
				s1.gsub!(/:sqrt\(/i, "Math::sqrt(")
				s1.gsub!(/:sin\((.+?)\)/i){ "Math::sin(#{$1} * #{PiPerDeg}).round(4)" }
				s1.gsub!(/:cos\((.+?)\)/i){ "Math::cos(#{$1} * #{PiPerDeg}).round(4)" }
				s1.gsub!(/:tan\((.+?)\)/i){ "Math::tan(#{$1} * #{PiPerDeg}).round(4)" }

				puts "\033[96m#{s1}\033[93m"

				# 計算
				begin
					print "    ", eval(s1).to_s
				rescue => e
					print "\033[91m[Err] #{e.to_s.strip}"
 				end
				puts
		end

		Term.reset()
	end
end

main()
